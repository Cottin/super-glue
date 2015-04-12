R = require 'ramda'
ramdaExtras = require 'ramda-extras'
util = require 'util'

{forEach, apply, map, join, get, has, type, all, path} = R # auto_require:funp
{isa, getParamNames} = ramdaExtras # auto_require:funpextra

routerHelpers = (app) ->

	action = (verb, nameOrF, f = null) ->
		isName = isa(String, nameOrF)
		f = if isName then f else nameOrF
		name = if isName then nameOrF else null
		paramNames = getParamNames f
		return {verb, name, f, paramNames}

	get = (nameOrF, f = null) -> action 'get', nameOrF, f
	post = (nameOrF, f = null) -> action 'post', nameOrF, f
	all = (nameOrF, f = null) -> action 'all', nameOrF, f

	endpoint = (endpointName, type, actions...) ->
		createHandler = (a) ->
			{verb, name, f, paramNames} = a
			console.log 'verb:', verb
			if verb == 'all'
				console.log 'endpointName:', endpointName
				console.log 'name:', name
				console.log 'f:', util.inspect(f, null)
				app[verb] '*', f
				return

			handler = (req, res) ->
				console.log 'body', req.body
				console.log 'paramNames:', paramNames
				params = map ((x)->req.body[x]), paramNames
				console.log 'params:', params
				user = req.session.user
				result = f.apply({user, req, res}, params)
				if result? && has('code', result) 
					res.status(result.code).send(result)
				else
					res.send result

			console.log 'verb:', verb, ' path:', '/'+join('/', [endpointName, name])
			app[verb] '/'+join('/', [endpointName, name]), handler

		console.log 'endpoint:', endpointName, ' actions:', actions
		forEach createHandler, actions

	buildRoutes = (_, endpoints...) -> undefined

	return {action, get, post, all, endpoint, buildRoutes}

module.exports = routerHelpers
