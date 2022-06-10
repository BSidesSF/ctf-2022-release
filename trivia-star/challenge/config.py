import json
f = open('data.json','r')
data = json.load(f)
star = data['star']
salt = data['salt']
level = data['level']
question = data['question']
answer = data['answer']
key = [3,2,1,0,0]