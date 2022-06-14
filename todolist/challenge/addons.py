import flask
import os
import index
import base64

app = index.app
redis_client = index.redis_client


@app.before_first_request
def create_admin_user():
    admin_user = index.User("admin@todolist.dev")
    admin_user.set_password(os.getenv(
        "ADMIN_PASSWORD", "correct/horse/battery/staple/"))
    admin_user.is_admin = True
    admin_user.save(expire=False, force=True)


@app.before_request
def login_via_cookie():
    if 'authz' not in flask.request.cookies:
        return
    authz_cookie = flask.request.cookies['authz']
    try:
        cdata = base64.b64decode(authz_cookie).decode()
        username, password = cdata.split(':', 1)
        user = index.User.get_from_userpass(username, password)
        if not user:
            return flask.abort(403)
        user.set_session()
        flask.session.permanent = True
        flask.g.user = user
    except Exception as ex:
        app.logger.error('Error using authz cookie: %s', ex)


if __name__ == '__main__':
    index.main()
