R = require 'ramda'
ramdaExtras = require 'ramda-extras'
mock = require './mock-db/mock'
serverHelpers = require './helpers/serverHelpers'
routerHelpers = require './helpers/routerHelpers'

{doit} = ramdaExtras
{login, logout, authenticate} = serverHelpers


router = (app) ->
	{buildRoutes, endpoint, get, post, all} = routerHelpers(app)
	ep = endpoint

	buildRoutes null,
		ep 'auth', null,
			post 'login', (email, password)				-> login email, password, @
			get 'logout', 												-> logout @
			get 'self', 													-> doit authenticate(@req, @res), @user
		ep '*', null,
			all 																	authenticate
		ep 'employee', null,
			get 																	-> mock.employee


module.exports = router
