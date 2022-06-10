import base64
import urllib.parse
import argparse

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--cookie', default='authz', help='Name of cookie')
    parser.add_argument('--user', default='admin@todolist.dev', help='Username')
    parser.add_argument('--password', default='correct/horse/battery/staple/',
            help='Password')
    parser.add_argument('--url', default='http://localhost:3123/',
            help='URL for cookie')
    args = parser.parse_args()

    encoded = base64.b64encode('{}:{}'.format(
        args.user, args.password).encode())
    encoded = urllib.parse.quote(encoded)
    cookie = '{}={};httpOnly;sameSite=Lax;url={}'.format(
            args.cookie, encoded, args.url)
    print(cookie)


if __name__ == '__main__':
    main()
