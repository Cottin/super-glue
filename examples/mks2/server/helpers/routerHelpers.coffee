util = require 'util'

{all, forEach, has, join, map, path, type} = require 'ramda' # auto_require:ramda
{isa} = require 'ramda-extras'
{getParamNames} = require 'sometools'

routerHelpers = (app) ->

	action = (verb, nameOrF, f = null) ->
		isName = isa(String, nameOrF)
		f = if isName then f else nameOrF
		name = if isName then nameOrF else null
		# paramNames = getParamNames f
		return {verb, name, f}

	get = (nameOrF, f = null) -> action 'get', nameOrF, f
	post = (nameOrF, f = null) -> action 'post', nameOrF, f
	put = (nameOrF, f = null) -> action 'put', nameOrF, f
	all = (nameOrF, f = null) -> action 'all', nameOrF, f

	endpoint = (endpointName, type, actions...) ->
		createHandler = (a) ->
			{verb, name, f} = a
			console.log 'verb:', verb
			if verb == 'all'
				console.log 'endpointName:', endpointName
				console.log 'name:', name
				console.log 'f:', util.inspect(f, null)
				app[verb] '*', f
				return

			handler = (req, res) ->
				console.log 'body', req.body
				# params = map ((x)->req.body[x]), paramNames
				# console.log 'params:', params
				user = req.session.user
				result = f.apply {user, req, res}, [req.body, req.params]
				console.log 'req.session:', req.session
				if result? && has('code', result) 
					res.status(result.code).send(result)
				else
					res.send result

			console.log 'verb:', verb, ' path:', '/'+join('/', [endpointName, name])
			app[verb] '/'+join('/', [endpointName, name]), handler

		console.log 'endpoint:', endpointName, ' actions:', actions
		forEach createHandler, actions

	buildRoutes = (_, endpoints...) -> undefined

	return {action, get, post, put, all, endpoint, buildRoutes}

module.exports = routerHelpers
