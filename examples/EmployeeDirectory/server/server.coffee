express = require 'express'
session = require 'express-session'
bodyParser = require 'body-parser'
Table = require('cli-table')
R = require 'ramda'
ramdaExtras = require 'ramda-extras'
errors = require '../shared/errors'
serverHelpers = require './helpers/serverHelpers'
morgan = require('morgan')
router = require './router'

{forEach, head, append, push, apply, compose, map, filter, contains, join, get, has, keys, all, path} = R # auto_require:funp
{cc, isa, doit} = ramdaExtras # auto_require:funpextra

# ------------------------------------------------------------------------------------------------------
# MIDDLEWARE
# ------------------------------------------------------------------------------------------------------
app = express()
app.use(morgan('dev'))

app.all '*', (req, res, next) ->
	console.log "\n#{req.method} #{req.path}"
	next()

app.set 'trust proxy', 1
# trust first proxy

sessionConfig = 
	secret: 'keyboard cat'
	resave: true
	saveUninitialized: true
	cookie: {secure: false}
	name: 'my_app_key'

app.use session(sessionConfig)
app.all '*', serverHelpers.cors
app.use bodyParser.json()
app.use serverHelpers.logResponseBody


# ------------------------------------------------------------------------------------------------------
# ROUTES
# ------------------------------------------------------------------------------------------------------
app.get '/', (req, res) -> res.send 'Hello World from api!'

app.get '/routes', (req, res) ->
	table = new Table {head: ['verb', 'path'], colWidths: [10, 70]}
	M = ['route', 'methods']
	P = ['route', 'path']

	extractVerb = compose head, keys, path(M)
	extractPath = path P
	extractVerbAndPath = (x) -> [extractVerb(x), extractPath(x)]
	notUndefined = (x) -> path(P, x) != undefined

	result = cc map(extractVerbAndPath), filter(notUndefined), app._router.stack
	table.push result...
	console.log table.toString()
	res.send 'Check your console for printed routing table'


router(app)


# ------------------------------------------------------------------------------------------------------
# START
# ------------------------------------------------------------------------------------------------------
server = app.listen 8088, ->
	host = server.address().address
	port = server.address().port
	console.log 'Example app listening at http://%s:%s', host, port

# start = (port) ->
# 	server = app.listen port, ->
# 		host = server.address().address
# 		port = server.address().port
# 		console.log 'Example app listening at http://%s:%s', host, port

module.exports = app





# deprecation line ----------
# routesOld =
# 	employee:
# 		get:							mock.employee
# 	auth:
# 		login:
# 			post: (email, password)				-> login(email, password, @)
# 		self:
# 			get:													->
# 				console.log 'this', this
# 				console.log 'user', @user
# 				@user
		# logout:
		# 	get:													-> logout



# buildEndpoint_ = (app, k, n, path) ->
# 	createHandler = (o) ->
# 		paramNames = sometools.getParamNames o
# 		if isa Function, o
# 			(req, res) ->
# 				console.log 'body', req.body
# 				console.log 'paramNames:', paramNames
# 				params = map ((x)->req.body[x]), paramNames
# 				console.log 'params:', params
# 				user = req.session.user
# 				result = o.apply({user, req}, params)
# 				if result? && has('code', result) 
# 					res.status(result.code).send(result)
# 				else
# 					res.send result
# 		else (req, res) -> res.send o

# 	app[k] '/'+join('/', path), createHandler n[k]

# buildRoutes_ = (app, n, path = []) ->
# 	verbs = ['get', 'post', 'put', 'delete']
# 	handleNode = (k) ->
# 		if contains k, verbs then buildEndpoint_ app, k, n, path
# 		else buildRoutes_ app, n[k], append(k, path)
# 	forEach handleNode, keys n
	
# # buildRoutes_ app, routesOld
