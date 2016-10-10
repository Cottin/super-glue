{add, always, any, evolve, mapObj, merge} = require 'ramda' #auto_require:ramda
{cc} = require 'ramda-extras'
{ajax} = require 'jquery'
appBase = require '../base/appBase'

#:: o -> o -> Thenable(any)
xhr = (options) -> 
	evolves =
		url: add 'http://localhost:3002/'
		data: JSON.stringify

	# optionsWithAllKeys = merge mapObj(always({}), evolves), options

	merges = 
		contentType: 'application/json'
		xhrFields:
      withCredentials: true
		# error: (a, status, c) ->
		# 	debugger

	newOptions = cc merge(merges), evolve(evolves), options
	ajax(newOptions).fail (xhrObject) ->
		{status} = xhrObject
		if status == 401
			appBase.set 'auth', null

module.exports = xhr
