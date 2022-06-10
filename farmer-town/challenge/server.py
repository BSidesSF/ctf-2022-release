
import requests
import os
from uuid import uuid4, UUID
from flask import Flask, render_template, request, redirect, flash
from flask_csp.csp import csp_header
from flask_wtf import FlaskForm, CSRFProtect
from wtforms import StringField, PasswordField, SubmitField, TextAreaField
from wtforms.validators import DataRequired, EqualTo, ValidationError, Regexp, Length
from flask_login import UserMixin, logout_user, login_user, LoginManager, login_required, current_user
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.orm import relationship
from werkzeug.security import generate_password_hash, check_password_hash
from flask_wtf.csrf import CSRFError
from sqlalchemy.exc import InterfaceError 
from werkzeug.middleware import proxy_fix

# Flask App initialization 
app = Flask(__name__)
app.wsgi_app = proxy_fix.ProxyFix(app.wsgi_app)

# Flask_login initialization
login_manager = LoginManager()
login_manager.init_app(app)

# Secret key, also used for CSRF token
app.secret_key = b'N3ww00fer5!'
csrf = CSRFProtect(app)

# Database setup 
app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///database.sqlite"
db = SQLAlchemy(app)

def generateUUID():
	return str(uuid4())

## User model
class User(db.Model, UserMixin):
    __tablename__ = 'user'
    id = db.Column(db.Integer, primary_key=True, index=True)
    uuid = db.Column(db.String(50),default=generateUUID, unique=True,)
    # email = db.Column(db.String(255), nullable=False, unique=True)
    username = db.Column(db.String(50), nullable=False, unique=True)
    password_hash = db.Column(db.String(255), nullable=False)
    value = db.Column(db.Integer, default=5, nullable=False)
    initialized = db.Column(db.Boolean, default=False, nullable=False)
    plants = relationship("Plant", uselist=False, backref="user")
    cans = relationship("Can", uselist=False, backref="user")
    def set_password(self, password):
        self.password_hash = generate_password_hash(password)
    def check_password(self, password):
        return check_password_hash(self.password_hash, password)
    def add_funds(self, amount):
    	self.value = self.value + amount
    def remove_funds(self, amount):
    	self.value = self.value - amount
    def initialize(self):
    	self.initialized = True
    def __repr__(self):
        return self.username
    

## Watering can model
class Can(db.Model):
    __tablename__ = 'can'
    id = db.Column(db.Integer, primary_key=True, index=True)
    broken = db.Column(db.Boolean, default=False, nullable=False)
    value = db.Column(db.Integer, default=2, nullable=False)
    parent_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    def trashcan(self):
    	self.broken = True
    	self.value = 1

## Plant model 
class Plant(db.Model):
	 __tablename__ = 'plant'
	 id = db.Column(db.Integer, primary_key=True, index=True)
	 stage = db.Column(db.Integer, default=0, nullable=False)
	 parent_id = db.Column(db.Integer, db.ForeignKey('user.id'))
	 def grow(self):
	 	if self.stage >=0 and self.stage < 2:
	 		self.stage = self.stage + 1

db.create_all()

# Forms used by the application

class LoginForm(FlaskForm):
    class Meta:
        csrf=False
    username = StringField('Username', validators=[DataRequired(), Regexp('^\w+$', message="Username must be AlphaNumeric")])
    password = PasswordField('Password', validators=[DataRequired()])
    submit = SubmitField('Login')

class RegistrationForm(FlaskForm):
    class Meta:
        csrf=False
    username = StringField('Username', validators=[DataRequired(), Regexp('^\w+$', message="Username must be AlphaNumeric")])
    # email = StringField('Email Address', validators=[DataRequired(), Email()])
    password = PasswordField('New Password', 
        validators=[DataRequired()])
    confirm = PasswordField('Repeat Password', validators=[DataRequired(), EqualTo('password', message='Passwords must match')])
    submit = SubmitField('Register')

    def validate_username(self, username):
        user = User.query.filter_by(username=username.data).first()
        if user is not None:
            raise ValidationError('Please use a different username.')

# Application routes 

## Login
@app.route('/')
@app.route('/login', methods=['GET', 'POST'])
@csrf.exempt
@csp_header({'default-src':"'self'",'style-src-elem':"'self' https://fonts.googleapis.com",'font-src':"https://fonts.gstatic.com"})
def login():
	form = LoginForm()
	if request.method == 'POST':
		if form.validate_on_submit():
			user = User.query.filter_by(username=form.username.data).first()
			if user is None or not user.check_password(form.password.data):
				flash('Invalid username or password', 'error')
				return redirect('/login')
			login_user(user)
			return redirect('/home')
	return render_template('login.html', form=form)

## Registration
@app.route('/register', methods=['GET', 'POST'])
@csp_header({'default-src':"'self'",'style-src-elem':"'self' https://fonts.googleapis.com",'font-src':"https://fonts.gstatic.com"})
@csrf.exempt
def register():
    form = RegistrationForm()
    if form.validate_on_submit():
        user = User(username=form.username.data)
        user.set_password(form.password.data)
        db.session.add(user)
        db.session.commit()
        flash('Thanks for registering')
        return redirect('/login')
    return render_template('register.html', form=form)

## Home page
@app.route('/home', methods = ['POST','GET'])
@csp_header({'default-src':"'self'",'style-src-elem':"'self' https://fonts.googleapis.com",'font-src':"https://fonts.gstatic.com"})
def landing():
	store = {'Can':10,'Seed':10}
	user = User.query.filter_by(id=current_user.id).one_or_none()
	if user.initialized == False:
		user.initialize()
		plant = Plant(parent_id=current_user.id)
		db.session.add(plant)
		can = Can(parent_id=current_user.id)
		db.session.add(can)
		db.session.commit()
	plant = Plant.query.filter_by(parent_id=current_user.id).one_or_none()
	can = Can.query.filter_by(parent_id=current_user.id).one_or_none()
	money = user.value
	return render_template('home.html',user=current_user, plant=plant, can=can, money=money, store=store)

## Buy 
@app.route('/buy', methods=['GET'])
def buy():
	store = {'Can':10,'Seed':10}
	itemid = request.args.get("id")
	can = Can.query.filter_by(parent_id=current_user.id).one_or_none()
	user = User.query.filter_by(id=current_user.id).one_or_none()
	if itemid == "Seed" and user.value >= store[itemid]:
		user.remove_funds(store[itemid])
		db.session.commit()
		error = "Your seed money was used up to cover operation costs, sorry!"
		return render_template('canned.html',error=error)
	if can is not None:
		error = "You can only own one can at a time!"
		return render_template('canned.html',error=error)
	else:
		if user.value >= store[itemid]:
			user.remove_funds(store[itemid])
			can = Can(parent_id=current_user.id)
			db.session.add(can)
			db.session.commit()
		else:
			error = "You don't have enough funds for this!"
			return render_template('canned.html',error=error)
	return redirect('/home', code=302)

## Sell
@app.route('/sell', methods=['GET'])
def sell():
	canid = request.args.get("id")
	uuid = request.args.get("wallet_id")
	targetUser = User.query.filter_by(uuid=uuid).one_or_none()
	if targetUser is None:
		error = "User not found!"
		return render_template('canned.html',error=error)
	else:
		userid = targetUser.id
	can = Can.query.filter_by(parent_id=current_user.id).one_or_none()
	if can is None:
		error = "You don't own a can!"
		return render_template('canned.html',error=error)
	else:
		fetchedCan = Can.query.filter_by(id=canid).one_or_none()
		if fetchedCan is None:
			error = "That can doesn't exist!"
			return render_template('canned.html',error=error)
		elif fetchedCan.id != can.id:
			error = "That can isn't yours!"
			return render_template('canned.html',error=error)
		else:
			user = User.query.filter_by(id=userid).one_or_none()
			if user is None:
				error = "Invalid user"
				return render_template('canned.html',error=error)
			else:
				Can.query.filter_by(id=can.id).delete()
				user.add_funds(can.value)
				db.session.commit()		
	return redirect('/home', code=302)

## Water
@app.route('/water', methods=['GET'])
def water():
	plant = Plant.query.filter_by(parent_id=current_user.id).one_or_none()
	can = Can.query.filter_by(parent_id=current_user.id).one_or_none()
	if can is None:
		error = "You don't own a can!"
		return render_template('canned.html',error=error)
	elif can.broken == True:
		error = "Your can is broken, you need a new one!"
		return render_template('canned.html',error=error)
	else:
		can.trashcan()
		plant.grow()
		db.session.commit()
	return redirect('/home', code=302)

## Flag
@app.route('/flag', methods=['GET'])
def flag():
	flagStr = 'CTF{Id0rIsSt1llH3r3}'
	plant = Plant.query.filter_by(parent_id=current_user.id).one_or_none()
	if plant.stage != 2:
		error = "Your plant has to be in the third stage!"
		return render_template('canned.html',error=error)
	if plant.stage == 2:
		return render_template('flag.html',flag=flagStr)

## Logout
@app.route('/logout', methods=['GET'])
def logout():
    logout_user()
    return redirect('/login')

# Helper functions
@login_manager.user_loader
def load_user(id):
    return User.query.get(int(id))

@app.errorhandler(CSRFError)
def handle_csrf_error(e):
    return render_template('csrf_error.html', reason=e.description), 400

app.run(host='0.0.0.0', port=8000)
app._static_folder = ''