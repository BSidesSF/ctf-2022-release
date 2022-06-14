
import requests
import os
from flask import Flask, render_template, request, redirect, session, make_response
from werkzeug.middleware import proxy_fix
import hashlib
import config

# Flask App initialization
app = Flask(__name__)
app.secret_key = "3aca57d98e6572a99a90bf5cb82fdf1a510be532492661ae15ba52783b177248"
app.wsgi_app = proxy_fix.ProxyFix(app.wsgi_app)

# Session management
@app.route('/')
@app.route('/start')
@app.route('/setsession')
def setSession():
    if 'GoogleHC' in request.headers.get('User-Agent', ''):
        return 'OK', 200
    session['level'] = config.level[0]
    response = make_response(redirect('/home'))
    response.set_cookie('star', config.star[0])
    return response

# Home page
@app.route('/home', methods=['GET'])
def home():
    msg = request.args.get('msg')
    levelValue = getSessionValues()
    starValue = request.cookies.get('star')
    levelId = getLevelId(levelValue)
    starId = getStarId(starValue)
    q = {"id":levelId,"value":config.question[levelId]}
    answerStr = config.answer[levelId]
    a = answerStr.split(',')
    return render_template('home.html',question=q,answer=a,star=starId,msg=msg)

# Flag
@app.route('/flag', methods=['GET'])
def flag():
    levelValue = getSessionValues()
    starValue = request.cookies.get('star')
    starId = getStarId(starValue)
    if starId == 50:
        flag = "CTF{Bl0ckcha1nSt4r}"
        return render_template('flag.html',error=None,flag=flag)
    else:
        error = "You need to solve all the levels!"
        return render_template('flag.html',error=error,flag=None)

# Handle answer
@app.route('/check-answer', methods=['GET'])
def checkAnswer():
    levelValue = getSessionValues()
    starValue = request.cookies.get('star')
    levelId = getLevelId(levelValue)
    starId = getStarId(starValue)
    answerValue = request.args.get('answer')
    answerOptions = config.answer[levelId]
    answers = answerOptions.split(',')
    newStarValue = starValue
    try:
        answerId = answers.index(answerValue)
    except ValueError:
        print ("Invalid answer")
    if answerId == config.key[levelId]:
        starValue = config.salt[starId] + starValue
        print("Star Value:", starValue)
        if levelId == 4:
            setSessionValues(config.level[levelId])
            newStarValue = hashlib.sha256(bytes(starValue,'utf-8')).hexdigest()
            response = make_response(redirect('/endgame'))
            response.set_cookie('star', newStarValue)
            return response
        else:
            setSessionValues(config.level[levelId+1])
            newStarValue = hashlib.sha256(bytes(starValue,'utf-8')).hexdigest()
        response = make_response(redirect('/home?msg=correct'))
        response.set_cookie('star', newStarValue)
        return response
    response = make_response(redirect('/home?msg=incorrect'))
    response.set_cookie('star', newStarValue)
    return response

@app.route('/endgame', methods=['GET'])
def endgame():
    session.pop('level',None)
    response = make_response(render_template('end.html'))
    response.set_cookie('star', '', expires=0)
    return response

def getSessionValues():
    levelValue = config.level[0]
    if 'level' in session:
        levelValue = session['level']
    return levelValue

def setSessionValues(levelValue):
    session['level'] = levelValue

def getLevelId(levelValue):
    try:
        levelId = config.level.index(levelValue)
        if levelId in range(0,5,1):
            return levelId
    except ValueError:
        print ("Level value not found")
        return -1
    return -1

def getStarId(starValue):
    try:
        starId = config.star.index(starValue)
        if starId in range(0,51,1):
            print(starId)
            return starId
    except ValueError:
        print ("Star value not found")
        return -1
    return -1

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
    app._static_folder = ''
