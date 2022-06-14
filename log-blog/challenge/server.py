
import requests
import os
from flask_csp.csp import csp_header
from flask import Flask, render_template, request, redirect, session, make_response
from werkzeug.middleware import proxy_fix
from flask_mail import Mail, Message
import urllib

# Flask App initialization 
app = Flask(__name__)
app.secret_key = "c99118cbf9c7ab6c6ae1f00c7cc1f7d9b6367d09f7c106c187f968153272455d"
app.wsgi_app = proxy_fix.ProxyFix(app.wsgi_app)
app.config['MAIL_SERVER']='in-v3.mailjet.com'
app.config['MAIL_PORT'] = 587
app.config['MAIL_USERNAME'] = '...snip...'
app.config['MAIL_PASSWORD'] = '...snip...'
app.config['MAIL_DEFAULT_SENDER'] = '...snip...'
app.config['MAIL_USE_TLS'] = True
app.config['MAIL_USE_SSL'] = False
mail = Mail(app)

# For admin use cookie bf2b084a16d854065952ee3edba3e5e22391e0088cea348783b5f4f5208c35ec
# Session management 
@app.route('/')
@csp_header({'connect-src':"'self'",'default-src':"'self'",'frame-src':"'none'",'script-src':"'self' 'unsafe-inline'", 'style-src':"'self' 'unsafe-inline'"})
def blogPage():
	return render_template('blog.html')

@app.route('/send-message', methods = ['POST'])
def sendMessage():
	message = request.form['message']
	passMessage(message)
	return redirect('/')

@app.route('/send-copy', methods = ['POST'])
def sendCopy():
	email = request.form['email']
	message = request.form['message']
	msg = Message('Copy from Log Blog', sender = 'logblog@ctf.bsidessf.net', recipients = [email])
	msg.body = message
	mail.send(msg)
	if 'admin' not in request.cookies:
		passMessage(message)
	return redirect('/')

@app.route('/display-message', methods=['GET'])
@csp_header({'connect-src':"'self'",'default-src':"'self'",'frame-src':"'none'",'script-src':"'self' 'unsafe-inline'", 'style-src':"'self' 'unsafe-inline'"})
def displayMessage():
	message = request.args.get('message')
	print(message)
	print(request.cookies)
	if 'admin' in request.cookies and request.cookies.get("admin") == u"bf2b084a16d854065952ee3edba3e5e22391e0088cea348783b5f4f5208c35ec":
		print('Admin is here')
		flag = "CTF{3mail5F0rExf1l}"
		return render_template('message.html', message=message, flag=flag)
	else:
		return redirect('/')

def passMessage(message):
	# r = requests.post('http://webbot:3000/submit', data={'url': 'http://logblog:8000/display-message?message=' + urllib.parse.quote(message)})
	r = requests.post('http://127.0.0.1:3000/submit', data={'url': 'https://log-blog-15ba06e9.challenges.bsidessf.net/display-message?message=' + urllib.parse.quote(message)})

if __name__ == '__main__':
	app.run(host='0.0.0.0', port=8000)
	app._static_folder = ''
