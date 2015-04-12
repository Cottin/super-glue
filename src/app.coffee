R = require 'ramda'
lo = require 'lodash'
$ = require 'jQuery'
moment = require 'moment'
ramdaExtras = require 'ramda-extras'
utils = require './utils'
{isAction, isObject, isList, isListItem, isValue} = helpers = require './helpers'


{last, append, push, mapObjIndexed, insert, omit, assoc, assocPath, type, split, path} = R # auto_require:funp
{infoGroup, LocalStorage} = utils
{dropLast} = ramdaExtras

app = ->
	# ------------------------------------------------------------------------------------------------------
	# PROPERTIES
	# ------------------------------------------------------------------------------------------------------
	@rootComponent = null
	@data = {}
	@logs =
		data: []
		redoStack: []
	@config = {}
	@objects = {}
	@_lastDevData = null

	# ------------------------------------------------------------------------------------------------------
	# PUBLIC METHODS
	# ------------------------------------------------------------------------------------------------------
	@initialize = (config) ->
		{objects, cursors, apiUrl} = config
		if !(objects || cursors) || !apiUrl then throw new Error 'config not ok'
		@objects = objects
		@cursors = cursors
		@config = {apiUrl}

	##### TRANSACT
	@transact =
		set: (path, data, caller = null, shouldPostDevData = true) =>
			extraMsg = if caller then "(caller: #{caller})" else ''
			infoGroup "TRANSACT SET #{extraMsg} #{path}", data
			pathAr = if isa(Array, path) then path else split('.', path)
			lastKey = last pathAr
			if !isNaN(parseInt(lastKey))
				pathToArray = dropLast 1, pathAr
				existingArray = getPath pathToArray, @data
				index = parseInt lastKey
				isTheIndex = (_, i) -> i == index
				newArray = rejectIndexed isTheIndex, existingArray
				newArray = insert index, data, newArray
				newData = assocPath pathToArray, newArray, @data
				_transact @logs.data, newData, shouldPostDevData
			else
				newData = if path then assocPath pathAr, data, @data else data
				_transact @logs.data, newData, shouldPostDevData
		push: (path, data, caller = null, shouldPostDevData = true) =>
			if !path then throw new 'path sent to transact.push is nullish'
			extraMsg = if caller then "(caller: #{caller})" else ''
			infoGroup "TRANSACT PUSH #{extraMsg} #{path}", data
			pathAr = if isa(Array, path) then path else split('.', path)
			existingArray = getPath pathAr, @data
			newArray = append data, existingArray
			newData = assocPath pathAr, newArray, @data
			_transact @logs.data, newData, shouldPostDevData


	##### DATA
	@undo        = -> _transact @logs.redoStack, @logs.data.pop()
	@redo        = -> _transact @logs.data, @logs.redoStack.pop()
	@loadData    = -> _getSavedDataAsFunctions()
	@clearData   = -> _setSavedData {}
	@saveData    = (name) -> _addToSavedData name, @data
	@forceUpdate = -> @rootComponent.forceUpdate()
	@handleDevData = (data) ->
		if @_lastDevData == data then return else @_lastDevData = data
		if moment().isAfter moment(data.dontTransactBefore), 'second'
			@transact.set '', data, 'devData', false

	##### EXPOSURE
	@views = [] # todo: this needs improvements?
	@declare = {view: (component) => @views.push component}

	##### CURSORS
	@C = helpers.cursorFunctions


	# ------------------------------------------------------------------------------------------------------
	# PRIVATE METHODS
	# ------------------------------------------------------------------------------------------------------
	_transact = (logStack, data, shouldPostDevData = true) =>
		if !data then return 'nothing to transact'
		logStack.push @data
		@data = data
		_updateApp()
		if shouldPostDevData then	_postDevData()
		return undefined # prevent ajax object to polute the console

	_updateAppFn = => @rootComponent.setState @data
	_updateApp = lo.throttle _updateAppFn, 10
	_getSavedData = => LocalStorage.getObject "savedData" || {}
	_setSavedData = (data) => LocalStorage.setObject "savedData", data
	_addToSavedData = (name, data) => _setSavedData assoc(name, data, _getSavedData())
	_removeFromSavedData = (name) => _setSavedData omit([name], _getSavedData())
	_getSavedDataAsFunctions = =>
		dataToFunction = (data, key) =>
			fn = () => @transact.set '', data, 'loadData'
			fn.delete = () -> _removeFromSavedData key
			return fn
		return mapObjIndexed dataToFunction, _getSavedData()

	_postDevDataFn = =>
		devDataUrl = "//#{window.location.hostname}:#{parseInt(window.location.port)+9}/devData"
		$.ajax
			type: 'POST'
			url: devDataUrl
			contentType: 'application/json'
			data: JSON.stringify @data
			error: (xhr) -> console.log 'Failed posting data to devData'
	_postDevData = lo.debounce _postDevDataFn, 1000

	return this
module.exports = new app() #singleton
