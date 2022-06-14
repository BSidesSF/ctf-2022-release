from flask import Flask, request, redirect, send_file
from werkzeug.middleware import proxy_fix
import requests
from urllib.parse import urlparse
from google.cloud import storage
import datetime

app = Flask(__name__)
app.wsgi_app = proxy_fix.ProxyFix(app.wsgi_app)


@app.route('/')
@app.route('/get-nft', methods = ['GET'])
def getNft():
    if request.method == 'GET':
        url = request.args.get('url')
        if not url:
            return "No URL", 200
        result = urlparse(url)
        if (result.netloc == "bsidessfctf2022.page.link"):
            nfturl = requests.get(url, allow_redirects=False)
            return fetchObject(nfturl.headers['Location'].rsplit('/',1)[-1])
        else:
            return "NFT not found", 400

@app.route('/get_image')
def get_image():
    return send_file("tree.png", mimetype='image/png')

def fetchObject(name):
    # to-do update service account and bucket name
    serviceAccount = "bsidessf2022-arboretum-key.json"
    bucketName = "arboretum-images-2022"
    url_lifetime = 3600
    # end update

    storage_client = storage.Client.from_service_account_json(serviceAccount)
    bucket = storage_client.bucket(bucketName)
    blob = bucket.get_blob(name)
    signedUrl = blob.generate_signed_url(
        version="v4",
        # This URL is valid for 5 minutes
        expiration=datetime.timedelta(minutes=5),
        # Allow GET requests using this URL.
        method="GET",
    )
    return redirect(signedUrl, code=302)


app.run(host='0.0.0.0', port=8000)
