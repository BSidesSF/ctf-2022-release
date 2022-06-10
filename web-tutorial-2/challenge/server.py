from flask import Flask, render_template, request, redirect, send_from_directory
from flask_csp.csp import csp_header
from werkzeug.middleware import proxy_fix
import requests
import urllib

app = Flask(__name__)
app.wsgi_app = proxy_fix.ProxyFix(app.wsgi_app)

# tutorial 2 (sourcing script) use cookie 4a65cc5144d0024bde9ba6980480fb519261149fff80ec190ce49c801a4c5356
@app.route('/')
@app.route('/xss-two')
@csp_header({'connect-src':"*",'style-src-elem':"'self' fonts.googleapis.com fonts.gstatic.com",'font-src':"'self' fonts.gstatic.com fonts.googleapis.com",'script-src':"*"})
def xssOne():
	return render_template('xss-two.html')

@app.route('/xss-two-result', methods = ['POST','GET'])
@csp_header({'connect-src':"*",'style-src-elem':"'self' fonts.googleapis.com fonts.gstatic.com",'font-src':"'self' fonts.gstatic.com fonts.googleapis.com",'script-src':"*"})
def xssOneResult():
	payload = "None"
	if request.method == 'POST':
		payload = request.form['payload']
		r = requests.post('http://127.0.0.1:3000/submit', data={'url': request.base_url + "?payload=" + urllib.parse.quote(payload)})
	if request.method == 'GET' and 'admin' in request.cookies and request.cookies.get("admin") == u"4a65cc5144d0024bde9ba6980480fb519261149fff80ec190ce49c801a4c5356":
		payload = request.args.get('payload')
	elif request.method == 'GET':
	    app.logger.warning('GET request without valid admin cookie.')
	return render_template('xss-two-result.html', payload = payload)

@app.route('/xss-two-flag', methods = ['GET'])
def xssOneFlag():
	if 'admin' in request.cookies and request.cookies.get("admin") == u"4a65cc5144d0024bde9ba6980480fb519261149fff80ec190ce49c801a4c5356":
		return "CTF{XS5-n3xt-l3ve1}"
	else:
		return "Sorry, admins only!"

app.run(host='0.0.0.0', port=8000)
