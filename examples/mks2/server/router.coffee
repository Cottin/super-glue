R = require 'ramda'
{doit} = require 'ramda-extras'
mock = require './mock-db/mock'
serverHelpers = require './helpers/serverHelpers'
routerHelpers = require './helpers/routerHelpers'
config = require '../config'
lo = require 'lodash'

{login, logout, authenticate, mockAuth, addLatency} = serverHelpers


router = (app) ->
	{buildRoutes, endpoint, get, post, put, all} = routerHelpers(app)
	ep = endpoint

	buildRoutes null,
		ep 'auth', null,
			post 'login', ({email, password})				-> login email, password, @
			get 'logout', 													-> logout @
			# post 'mock', (user)										-> mockAuth @
			# get 'self', 													-> doit authenticate(@req, @res), @user
		if config.addLatency 
			ep '*', null,
				all 																	addLatency
		ep '*', null,
			all 																	authenticate
		ep 'employee', null,
			get 																	-> mock.employee
			put ':id', (employee, {id})						-> doit lo.set(mock, "employee[#{id}]", employee), employee
		ep 'issue', null,
			get 																	-> mock.employee


module.exports = router
