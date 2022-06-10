import base64
import flask
import flask_redis
import flask_session as session
import functools
import furl
import hashlib
import json
import jwt
import markupsafe
import random
import redis
import requests
import urllib.parse
import os
import uuid
from werkzeug.middleware import proxy_fix


# Initialize the app
app = flask.Flask(__name__)
app.wsgi_app = proxy_fix.ProxyFix(app.wsgi_app)
app.config.from_object('config.Config')
redis_client = flask_redis.FlaskRedis(app)
app.config['SESSION_COOKIE_NAME'] = 'sup_session'
app.config.setdefault('SESSION_TYPE', 'redis')
app.config.setdefault('SESSION_KEY_PREFIX', 'sup_session:')
app.config['SESSION_REDIS'] = redis_client
app.config['PERMANENT_SESSION_LIFETIME'] = 3600
session.Session(app)


@app.before_request
def add_g_user():
    flask.g.user = flask.session.get('email', None)


def login_required(f):
    @functools.wraps(f)
    def func(*args, **kwargs):
        if flask.session.get('email', None) is None:
            if flask.request.path.startswith('/api'):
                return flask.make_response(
                        'Login Required', 403)
            return flask.redirect(
                    flask.url_for('login', next=flask.request.url))
        return f(*args, **kwargs)
    return func


def get_sso_key(_static={}):
    if 'sso_key' in _static:
        return _static['sso_key']
    res = requests.get(app.config.get(
        'SSO_KEY_URL', 'http://localhost:3123/pubkey.pem'))
    res.raise_for_status()
    rv = res.text
    _static['sso_key'] = rv
    return rv


@app.route('/')
def index():
    return flask.render_template(
            "index.html", user=flask.session.get('email', None))


def _get_audience():
    # TODO: check behind proxy?
    aud = flask.request.host_url
    app.logger.info('Expected audience: %s', aud)
    return aud


@app.route('/login')
def login():
    token = flask.request.args.get('token', '')
    nexturl = flask.request.args.get('next', '')
    fnexturl = furl.furl(nexturl)
    requrl = furl.furl(flask.request.base_url)
    if (fnexturl.host != "" and
            fnexturl.host != None and
            fnexturl.host != requrl.host):
        app.logger.error('Next contains host %s, request for host %s',
                fnexturl.host, requrl.host)
        return flask.abort(400)
    if token:
        # Attempt to login with this token
        try:
            decoded = jwt.decode(
                    token, key=get_sso_key(), algorithms=['RS256'],
                    audience=_get_audience())
        except jwt.PyJWTError as ex:
            app.logger.error('Error decoding jwt: %s', ex)
            return 'Login Error', 403
        # At this point we should be good to trust
        flask.session['email'] = decoded['sub']
        flask.session.permanent = True
        f = furl.furl('/login')
        if nexturl:
            f.args['next'] = nexturl
        return flask.redirect(str(f))
    if flask.session.get('email', None):
        if nexturl:
            return flask.redirect(nexturl)
        return flask.redirect('/')
    sso_url = furl.furl(app.config.get('SSO_URL', ''))
    sso_url.args['dest'] = flask.request.url
    return flask.redirect(str(sso_url))


@app.route('/logout')
@login_required
def logout():
    flask.session.clear()
    return flask.redirect('/')


@app.route('/message', methods=['GET'])
@login_required
def message():
    return flask.render_template('message.html')


@app.route('/message', methods=['POST'])
@login_required
def message_post():
    def _render_error(error):
        return flask.render_template('message.html', error=error)

    msg = flask.request.form.get('message')
    if not msg:
        return _render_error("Missing message")

    # Validate pow
    pow_iv = flask.request.form.get('pow')
    if not pow_iv:
        return _render_error("Missing proof of work")
    difficulty = app.config.get("POW_DIFFICULTY", 4)
    mask = "0" * difficulty
    iv = bytes.fromhex(pow_iv)
    powsum = hashlib.sha256(msg.encode() + iv).hexdigest()
    if powsum[:len(mask)] != mask:
        app.logger.info("Invalid proof of work, got %s", powsum)
        return _render_error("Proof of work failed")

    msgdata = {
            'from': flask.g.user,
            'message': msg,
            'user_agent': flask.request.headers.get('User-Agent'),
            'remote_addr': flask.request.remote_addr,
            }
    msgstr = json.dumps(msgdata)
    while True:
        key = str(uuid.uuid4())
        if redis_client.set(key, msgstr, ex=3600, nx=True):
            break
    msg = markupsafe.Markup(
            '<a href="/viewmessage/{}">Message</a> Submitted').format(key)
    trigger_xssbot(key)
    return flask.render_template('message.html', success=msg)


def trigger_xssbot(mid):
    f = furl.furl(flask.request.url_root)
    f.path = '/viewmessage/{}'.format(mid)
    xssbot = app.config.get(
            'XSSBOT_URL', os.getenv('XSSBOT_URL',
                'http://localhost:3000/submit'))
    try:
        app.logger.info('Sending request to visit %s to xssbot.', f)
        requests.post(xssbot, data={'url': str(f)})
    except Exception as ex:
        app.logger.error('Error sending request to xssbot: %s', ex)


@app.route('/viewmessage/<mid>')
@login_required
def viewmessage(mid):
    msgstr = redis_client.get(mid)
    if not msgstr:
        return flask.abort(404)
    msgdata = json.loads(msgstr)
    return flask.render_template('viewmessage.html', **msgdata)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port='3124', debug=True)
