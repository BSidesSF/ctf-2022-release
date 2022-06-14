from flask import Flask, render_template, request, redirect, send_from_directory
from flask_csp.csp import csp_header
from werkzeug.middleware import proxy_fix
import requests
import urllib

app = Flask(__name__)
app.wsgi_app = proxy_fix.ProxyFix(app.wsgi_app)

# csp one (data uri) use cookie 14648f6579bd07059177940f8a5bddba8fe9e9cdda09500cd73402a580ad8b2a
@app.route('/')
@app.route('/xss-one')
@csp_header({'connect-src':"*",'script-src':"'self' 'unsafe-inline'"})
def xssOne():
	return render_template('xss-one.html')

@app.route('/xss-one-result', methods = ['POST','GET'])
@csp_header({'connect-src':"*",'script-src':"'self' 'unsafe-inline'"})
def xssOneResult():
	payload = "None"
	if request.method == 'POST':
		payload = request.form['payload']
		r = requests.post('http://127.0.0.1:3000/submit', data={'url': request.base_url + "?payload=" + urllib.parse.quote(payload)})
	if request.method == 'GET' and 'admin' in request.cookies and request.cookies.get("admin") == u"14648f6579bd07059177940f8a5bddba8fe9e9cdda09500cd73402a580ad8b2a":
		payload = request.args.get('payload')
	elif request.method == 'GET':
	    app.logger.warning('GET request without valid admin cookie.')
	return render_template('xss-one-result.html', payload = payload)

@app.route('/xss-one-flag', methods = ['GET'])
def xssOneFlag():
	if 'admin' in request.cookies and request.cookies.get("admin") == u"14648f6579bd07059177940f8a5bddba8fe9e9cdda09500cd73402a580ad8b2a":
		return "CTF{XS5-W0rks-h3r3}"
	else:
		return "Sorry, admins only!"

app.run(host='0.0.0.0', port=8000)