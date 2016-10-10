{ajax} = require 'jquery'
{add, any, evolve, merge} = require 'ramda' #auto_require:ramda
{cc} = require 'ramda-extras'

#:: o -> Thenable(any)
xhr = (options) -> 
	evolves =
		url: add 'http://localhost:3002/'

	merges = 
		contentType: 'application/json'
		xhrFields:
			withCredentials: true

	newOptions = cc merge(merges), evolve(evolves), options
	ajax newOptions

module.exports = xhr
