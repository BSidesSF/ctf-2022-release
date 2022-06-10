import base64
import functools
import hashlib
import furl
import json
import jwt
import random
import flask
import flask_redis
import flask_session as session
import redis
import urllib.parse
from passlib.hash import argon2
from werkzeug.middleware import proxy_fix


# Initialize the app
app = flask.Flask(__name__)
app.wsgi_app = proxy_fix.ProxyFix(app.wsgi_app)
app.config.from_object('config.Config')
redis_client = flask_redis.FlaskRedis(app)
app.config['SESSION_COOKIE_NAME'] = 'todo_session'
app.config.setdefault('SESSION_TYPE', 'redis')
app.config.setdefault('SESSION_KEY_PREFIX', 'todo_session:')
app.config['SESSION_REDIS'] = redis_client
app.config['PERMANENT_SESSION_LIFETIME'] = 3600
app.config.setdefault('SUPPORT_URL', 'http://localhost:3124/')
session.Session(app)

jwt_privkey = open('./keys/privkey.pem', 'r').read()


MAX_TODOS = 100


class User:

    UID_NAME = 'uid'
    USER_PATTERN = 'todolist_user_{}'
    TODO_HASH_PATTERN = 'todolist_todos_{}'
    USER_EXPIRATION = 7200

    def __init__(self, email=""):
        self.email = email
        self.password = None
        self.uid = self.make_uid(email)
        self.is_admin = False

    def to_json(self):
        rv = {}
        for k in ('email', 'password', 'uid', 'is_admin'):
            rv[k] = getattr(self, k, None)
        return rv

    def set_password(self, password):
        self.password = argon2.hash(password)

    def verify_password(self, password):
        return argon2.verify(password, self.password)

    def save(self, create=False, expire=True, force=False):
        val = json.dumps(self.to_json())
        if create and not force:
            opts = {'nx': True}
        elif not force:
            opts = {'xx': True}
        else:
            opts = {}
        if expire and not self.is_admin:
            opts['ex'] = self.USER_EXPIRATION
        rv = redis_client.set(self.USER_PATTERN.format(self.uid), val, **opts)
        return rv == 1

    def set_session(self):
        flask.session[self.UID_NAME] = self.uid

    @property
    def hash_pattern(self):
        return self.TODO_HASH_PATTERN.format(self.uid)

    def get_todos(self):
        rv = {}
        data = redis_client.hgetall(self.hash_pattern)
        for k, v in data.items():
            if b'_state' in k:
                k = k.replace(b'_state', b'')
                rv.setdefault(k.decode(), {})['state'] = v.decode()
            else:
                rv.setdefault(k.decode(), {})['text'] = v.decode()
        return rv

    def add_todo(self, text):
        # TODO: address TOCTOU
        if redis_client.hlen(self.hash_pattern) >= MAX_TODOS:
            return None
        rnd = random.randrange(2**32)
        data = {
                '{}'.format(rnd): text,
                '{}_state'.format(rnd): 'TODO',
        }
        redis_client.hset(self.hash_pattern, mapping=data)
        redis_client.expire(self.hash_pattern, time=self.USER_EXPIRATION)
        self.save()
        return rnd

    def mark_todo_done(self, tid):
        redis_client.hset(self.hash_pattern, '{}_state'.format(tid), 'DONE')

    def prune_done(self):
        # Prune finished TODOs
        done_keys = []
        rv = {}
        data = redis_client.hgetall(self.hash_pattern)
        for k, v in data.items():
            if b'_state' not in k:
                continue
            if v.decode() == 'DONE':
                k = k.decode()
                done_keys.append(k)
                k = k.replace('_state', '')
                done_keys.append(k)
        redis_client.hdel(self.hash_pattern, *done_keys)

    @staticmethod
    def make_uid(email):
        return hashlib.sha256(email.lower().encode()).hexdigest()

    @classmethod
    def get_current(cls):
        if hasattr(flask.g, 'user'):
            return flask.g.user
        uid = flask.session.get(cls.UID_NAME, None)
        if uid is None:
            return None
        data = redis_client.get(cls.USER_PATTERN.format(uid))
        if not data:
            return None
        data = json.loads(data)
        rv = cls.from_dict(data)
        flask.g.user = rv
        return rv

    @classmethod
    def from_dict(cls, data):
        i = cls()
        for k, v in data.items():
            setattr(i, k, v)
        return i

    @classmethod
    def get_from_userpass(cls, username, password):
        uid = cls.make_uid(username)
        data = redis_client.get(cls.USER_PATTERN.format(uid))
        if not data:
            return None
        data = json.loads(data)
        rv = cls.from_dict(data)
        if rv.verify_password(password):
            flask.g.user = rv
            return rv
        return None


def login_required(f):
    @functools.wraps(f)
    def func(*args, **kwargs):
        if flask.session.get(User.UID_NAME, None) is None:
            if flask.request.path.startswith('/api'):
                return flask.make_response(
                        'Login Required', 403)
            return flask.redirect(
                    flask.url_for('login', next=flask.request.url))
        return f(*args, **kwargs)
    return func


@app.route('/')
def index():
    return flask.render_template("index.html", user=User.get_current())


@app.route('/robots.txt')
def robots():
    rtxt = "User-agent: *\nDisallow: /index.py\nDisallow: /flag\n"
    resp = flask.make_response(rtxt)
    resp.content_type = 'text/plain'
    return resp


@app.route('/index.py')
def index_py():
    return flask.send_file(__file__, mimetype='text/plain', as_attachment=True)


@app.route('/login', methods=['GET'])
def login():
    u = User.get_current()
    if u is not None:
        return flask.redirect("/todos")
    return flask.render_template("login.html", user=u)


@app.route('/login', methods=['POST'])
def login_post():
    def render_error(err):
        return flask.render_template("login.html", error=err)
    pw = flask.request.form.get("password")
    if pw == "":
        return render_error("Please provide the password.")
    email = flask.request.form.get("email")
    if email == "":
        return render_error("Please provide your email.")
    user = User.get_from_userpass(email, pw)
    if not user:
        return render_error(
            "Invalid username/password.  "
            "(Accounts are periodically cleaned.)")
    user.set_session()
    flask.session.permanent = True
    user.save()
    return flask.redirect("/todos")


@app.route('/logout')
@login_required
def logout():
    flask.session.clear()
    return flask.redirect("/")


@app.route('/register', methods=['GET'])
def register():
    u = User.get_current()
    if u is not None:
        return flask.redirect("/todos")
    return flask.render_template("register.html", user=u)


@app.route('/register', methods=['POST'])
def register_post():
    def render_error(err):
        return flask.render_template("login.html", error=err)
    pw = flask.request.form.get("password")
    pw2 = flask.request.form.get("password2")
    if pw != pw2 or pw == "":
        return render_error("Please provide the same password twice.")
    email = flask.request.form.get("email")
    if email == "":
        return render_error("Please provide your email.")
    user = User(email)
    user.set_password(pw)
    if user.save(create=True):
        user.set_session()
        return flask.redirect("/todos")
    return render_error("Unable to save: perhaps user already exists?")


@app.route('/todos')
@login_required
def todos():
    return flask.render_template("todos.html", user=User.get_current())


@app.route('/api/todos', methods=['GET'])
@login_required
def api_todos():
    user = User.get_current()
    if not user:
        return '{}'
    return user.get_todos()


@app.route('/api/todos', methods=['POST'])
@login_required
def api_todos_post():
    user = User.get_current()
    if not user:
        return '{}'
    todo = flask.request.form.get("todo")
    if not todo:
        return 'Missing TODO', 400
    num = user.add_todo(todo)
    if num:
        return {'{}'.format(num): todo}
    return 'Too many TODOs', 428


@app.route('/api/todos/<int:tid>', methods=['POST'])
@login_required
def api_todos_update(tid):
    user = User.get_current()
    if not user:
        return 'Error', 403
    user.mark_todo_done(tid)
    return 'OK'


@app.route('/api/prune', methods=['POST', 'GET'])
@login_required
def prune_done():
    user = User.get_current()
    if not user:
        return 'Error', 403
    user.prune_done()
    return 'OK'


@app.route('/flag', methods=['GET'])
@login_required
def flag():
    user = User.get_current()
    if not (user and user.is_admin):
        return 'Access Denied', 403
    return flask.send_file(
            'flag.txt', mimetype='text/plain', as_attachment=True)


@app.route('/pubkey.pem', methods=['GET'])
def pubkey():
    return flask.send_file(
            'keys/pubkey.pem', mimetype='application/x-pem-file')


@app.route('/api/sso')
@login_required
def sso():
    user = User.get_current()
    if not user:
        return flask.redirect('/logout')
    dest = flask.request.args.get('dest', '')
    try:
        u = furl.furl(dest)
    except ValueError:
        return flask.abort(400)
    if u.host not in (
            'localhost',
            '127.0.0.1',
            'todolist-513d9272.challenges.bsidessf.net',
            'todolist-support-ebc7039e.challenges.bsidessf.net',
            ):
        app.logger.info('Invalid hostname for sso: %s', u.host)
        return flask.abort(400)
    claims = {
            "aud": "{}://{}/".format(u.scheme, u.netloc),
            "sub": user.email,
    }
    signed_jwt = jwt.encode(claims, jwt_privkey, algorithm='RS256')
    u.args['token'] = signed_jwt
    return flask.redirect(str(u))


@app.route('/support')
def support():
    return flask.redirect(app.config.get('SUPPORT_URL'))


def main():
    app.run(host='0.0.0.0', port='3123', debug=True)


if __name__ == '__main__':
    main()
