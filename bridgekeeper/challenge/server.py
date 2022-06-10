from Crypto.Signature import PKCS1_v1_5
from Crypto.Hash import SHA256
from Crypto.PublicKey import RSA
import base64
from flask import Flask, request
import requests
from werkzeug.middleware import proxy_fix
import firebase_admin
from firebase_admin import credentials, auth, firestore

app = Flask(__name__)
app.wsgi_app = proxy_fix.ProxyFix(app.wsgi_app)


@app.route('/')
@app.route('/get-flag')
def verifySign():
    id_token = request.args.get('token')
    if id_token:
        decoded_token = auth.verify_id_token(id_token)
        uid = decoded_token['uid']
        user_dict = fetchValues(uid)
        if validateSign(user_dict['cert'],user_dict['data'], user_dict['signature']):
            if user_dict['data'] == '{"Level_1":"egg","Level_2":"darkness","Level_3":"cold"}':
                return "Flag is CTF{Hardwar3BackedK3y5FTW}", 200
            else:
                return "You need to solve all the levels!", 200
        else:
            return "Signature is invalid", 200
    else:
        return "Missing Token", 200

def fetchValues(user):
    user_dict = {'cert': '', 'data': '', 'signature': ''}
    firestore_db = firestore.client()
    cert_ref = firestore_db.collection(u'certs').document(user)
    cert = cert_ref.get()
    if cert.exists:
        user_dict['cert'] = cert.to_dict()['cert']
    else:
        print(u'No such document!')
    user_ref = firestore_db.collection(u'users').document(user)
    user = user_ref.get()
    if user.exists:
        user_dict['data'] = user.to_dict()['data']
        user_dict['signature'] = user.to_dict()['signature']
    else:
        print(u'No such document!')
    return user_dict

def validateSign(key, data, signature):
    message = data
    h = SHA256.new(message.encode('utf-8'))
    signature = base64.urlsafe_b64decode(signature)
    #print(key)
    key_pem = base64.urlsafe_b64decode(key)
    #print(key_pem)
    Signkey = RSA.importKey(key_pem)
    verifier = PKCS1_v1_5.new(Signkey)
    return verifier.verify(h, signature)

cred = credentials.Certificate("bsidessf2022-bridgekeeper-c0314b4117d3.json")
firebase_admin.initialize_app(cred)
app.run(host='0.0.0.0', port=8000)