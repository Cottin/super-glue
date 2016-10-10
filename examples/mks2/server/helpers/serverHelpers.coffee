R = require 'ramda'
mock = require '../mock-db/mock'
errors = require '../../shared/errors'
config = require '../../config'

{find, max, min, omit, whereEq} = R # auto_require:ramda

# ------------------------------------------------------------------------------------------------------
# AUTH
# ------------------------------------------------------------------------------------------------------
login = (email, password, x) ->
	e = find whereEq({email, password}), mock.employee
	x.req.session.user = e
	console.log 'x.req.session', x.req.session
	if e then return omit(['password'], e)
	else errors.api.auth_failed

mockAuth = (user, x) ->
	x.req.session.user = user
	return omit(['password'], user)

logout = (x) ->
	if x.req.session then x.req.session.destroy()
	return true

isAuthenticated = (req) ->
	console.log 'req.session:', req.session
	req?.session?.user?
	
authenticate = (req, res, next) ->
	# TODO: should this options thing be needed?
	if req.method == 'OPTIONS' then return next?()
	if isAuthenticated(req) then next?()
	else
		if req.session then req.session.destroy()
		res.status(401).send({code: 401, message: 'not authenticated'})

_getRandomInt = (min, max) -> Math.floor(Math.random() * (max - min)) + min
addLatency = (req, res, next) -> setTimeout(next, _getRandomInt(0, 1000))

addRandom500 = (req, res, next) ->
	if config.addRandom500 && _getRandomInt(0, 5) == 0
		res.status(500).send()
	else next() 


# ------------------------------------------------------------------------------------------------------
# GENERAL
# ------------------------------------------------------------------------------------------------------
cors = (req, res, next) ->
	res.set 'Access-Control-Allow-Origin', req.headers.origin
	res.set 'Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, Content-Length, Accept, Origin'
	res.set 'Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, HEAD, DELETE'
	res.set 'Access-Control-Allow-Credentials', 'true'
	res.set 'Access-Control-Max-Age', 5184000
	next()


# ------------------------------------------------------------------------------------------------------
# DEV
# ------------------------------------------------------------------------------------------------------
logResponseBody = (req, res, next) ->
	oldWrite = res.write
	oldEnd = res.end
	chunks = []

	res.write = (chunk) ->
		chunks.push chunk
		oldWrite.apply res, arguments
		return

	res.end = (chunk) ->
		if chunk
			chunks.push chunk
		body = Buffer.concat(chunks).toString('utf8')
		console.log "RESPONSE BODY: ", body
		oldEnd.apply res, arguments
		return

	next()
	return

module.exports = {login, logout, authenticate, cors, logResponseBody, addLatency, addRandom500}
