config = require '../../config'
R = require 'ramda'
siu = require 'siu'
appHelpers = require './appHelpers'

{last, append, join, get, path, functions} = R # auto_require:funp

objects = (app) ->
	{object, action, buildObjectTree, get, post} = siu.helpers app
	{loginSuccess, loginError, logoutSuccess, logoutError, selfError} = appHelpers app

	buildObjectTree null,
		object 'auth', null,
			action 'login',	(email, password)     -> post('auth/login', @path, {email, password}).success(loginSuccess).error(loginError)
			action 'logout', 											-> get('auth/logout', @path).success(logoutSuccess).error(logoutError)
			action 'self',												-> get('auth/self', @path).error(selfError)
		object 'employees', null,
			action 'getAll', 											-> get 'employee', @path

module.exports = objects

# ----------- deprecation line
# objects = (app) ->
# 	{get, post, loginSuccess, loginError, logoutSuccess, logoutError} = helpers app

# 	_mixins:
# 		dataObjects:
# 			_matcher: functionGraph.matchers.allChildrenAreFunctions
# 			value: -> path append('value', @path), app.data
# 			# functions prefixed by __ is only to be used by developer in console or REPL
# 			__clear: -> app.transact.set append('value', @path), null, "developer cleared"
# 		xhrState:
# 			_matcher: (o, p) -> isa(Function, o)
# 			_before:	(params...) -> infoGroup "ACTION #{join('.', @path)}", params
# 			value: -> path @path, app.data
# 			clear: -> app.transact.set @path, null, "xhr-clear(#{last(@path)})"
# 	auth:
# 		login: (email, password)				-> post('auth/login', @path, {email, password}).success(loginSuccess).error(loginError)
# 		logout: 												-> get('auth/logout', @path).success(logoutSuccess).error(logoutError)
# 		self:														-> get('auth/self', @path)
# 	employees:
# 		getAll:													-> get 'employee', @path
