R = require 'ramda'
mock = require '../mock-db/mock'
errors = require '../../shared/errors'

{push, concat, apply, find, where} = R # auto_require:funp

# ------------------------------------------------------------------------------------------------------
# AUTH
# ------------------------------------------------------------------------------------------------------
login = (email, password, x) ->
	e = find where({email, password}), mock.employee
	x.req.session.user = e
	return e || errors.api.auth_failed

logout = (x) ->
	if x.req.session then x.req.session.destroy()
	return true

isAuthenticated = (req) -> req?.session?.user?
authenticate = (req, res, next) ->
	# TODO: should this options thing be needed?
	if req.method == 'OPTIONS' then next?()
	if isAuthenticated(req) then next?()
	else
		if req.session then req.session.destroy()
		res.status(401).send({code: 401, message: 'not authenticated'})


# ------------------------------------------------------------------------------------------------------
# GENERAL
# ------------------------------------------------------------------------------------------------------
cors = (req, res, next) ->
		res.set 'Access-Control-Allow-Origin', req.headers.origin
		res.set 'Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, Content-Length, Accept, Origin'
		res.set 'Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE'
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

module.exports = {login, logout, authenticate, cors, logResponseBody}
