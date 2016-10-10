{assocPath, compose, dropLast, fromPairs, into, join, keys, last, length, lift, map, merge, mergeAll, path, replace, set, take, type, update, values} = R = require 'ramda'  #auto_require:ramda
{cc, isa, getPath, dropLast} = require 'ramda-extras'
{ajax} = require 'jquery'
{refresh, saveData, saveDevData} = require './utils/devDataHelpers'
actionHelpers = require './actionHelpers'
uiHelpers = require './uiHelpers'
functions = require './functions'

# TODO: testa att göra om det här till en funktion.
class App
	# pass null as devData if you don't want to use it
	constructor: (initialData, actionsFn, TODO_shouldUseDevData) ->
		@data = null

		@undoStack = []
		@redoStack = []
		@setHistory = []

		@lastInvokersData = {}
		@lastQueriersData = {}

		# saving and loading of data using the dev-data server
		# @devDataApi = devDataApi
		# if @devData
		# 	@savedData = {refresh: refresh(@, @devData)}

		# hooks
		@renderHook = (data) ->
			# throw new Error 'you forgot to use app.renderHook'
		@setHook = (path, value) -> # do nothing by default since setHook is optional

		# set helpers
		@actionHelpers = actionHelpers @
		@uiHelpers = uiHelpers @

	initialize: ({DEV_MODE, devDataApi, initialData, lifters, invokers, queriers, actions, parser}) ->
		@DEV_MODE = DEV_MODE
		@devDataApi = devDataApi
		@data = initialData
		@dataPaths = functions.buildPaths initialData, ['data']

		if lifters
			@lifters = functions.prepareLifters initialData, lifters
			@liftedDataPaths = functions.buildPaths lifters, ['liftedData']

		if invokers
			@invokers = functions.prepareLifters merge(initialData, lifters), invokers, true

		if queriers
			@queriers = functions.prepareLifters merge(initialData, lifters), queriers

		if parser then @parser = parser

		runMutationParser = (query, path) => @parser.mutationParser query

		wrappedActions = functions.wrapActions @DEV_MODE, actions, runMutationParser
		@actions = wrappedActions
		@actionPaths = functions.buildPaths wrappedActions, ['actions']

		timerId = window.setInterval @render, 100
		window.onerror = ->
			window.setTimeout ->
				console.error 'Super-glue strict mode: stop rendering on thrown error'
				window.clearInterval timerId
			, 0



		# @setQueue = []
		# @isSyncing = false

		# startSync = =>
		# 	console.log 'start sync'
		# 	@isSyncing = true
		# 	stopSync = =>
		# 		console.log 'stop sync'
		# 		@isSyncing = false
		# 		if length @setQueue
		# 			{path, value, caller} = @setQueue.shift()
		# 			@set path, value, caller

		#		saveData(@)('live', true).then stopSync

		set = (path, value, caller = null) =>
			# if @isSyncing
			# 	@setQueue.push {path, value, caller: set.caller}
			# 	console.log 'syncing dev data, set-operation queued', path, value
			# 	return null #console.log 'syncing dev data, set-operation queued', path, value

			if isa(String, path) then path = path.split('.')
			currentValue = getPath (path || ''), @data
			isNoop = (currentValue == value)

			# logging
			extra = if isNoop then ' (NO-CHANGE)' else ''
			if R.is String, caller
				console.groupCollapsed "SET#{extra} #{join('.', path)} (#{caller})", value
				if path then console.log 'current value', getPath(path, @data)
				console.groupEnd()
			else
				# workaround for http://stackoverflow.com/q/33859262/416797
				console.groupCollapsed "SET#{extra} #{path}", value
				if path then console.log 'current value', getPath(path, @data)
				console.log 'caller', caller
				console.groupEnd()

			# we don't change if it's a noop since it's easy to get into
			# infinate render loops otherwise
			if isNoop then return value
			else if path == '' || path == null
				@data = value
			else
				@data = assocPath path, value, @data

			@setHistory.push join('.', (path || []))
			@setHook path, value, @data

			# if path != null then startSync()
			# saveData(@, @devData)('live', true)

			# @render(@data)
			return value

		@set = set




	# unset: (path) -> @set path, null

	# undo: ->
	# 	if !@undoStack.length then return 'nothing to undo'
	# 	@redoStack.push @data
	# 	@set '', @undoStack.pop()

	# redo: ->
	# 	if !@redoStack.length then return 'nothing to redo'
	# 	@undoStack.push @data
	# 	@set '', @redoStack.pop()

	renderOld: -> @renderHook(@data)


	render: =>
		# lastData = last @undoStack
		# this means that for now, invokers can only take normalized data as input
		# and there is no specific order of invocation
		# invocationQueue = ychain values(@invokers), ({f}) -> f lastData, @data

		# hur kommer det här att funka med state i komponenter
		if @lastRenderedData == @data then return
		render0 = performance.now()
		lastDataMerged = mergeAll [@lastRenderedData, @liftedData]

		console.info 'RENDER', @setHistory
		@setHistory = []

		lift0 = performance.now()
		[@liftedData, liftersRun] = functions.liftData @lifters, @data, lastDataMerged
		liftTime = performance.now() - lift0

		dataAndLiftedData = merge @data, @liftedData

		queriers0 = performance.now()
		[@queriersData, queriersRun] = functions.runInvokers @queriers, dataAndLiftedData, lastDataMerged, @lastQueriersData
		queriersTime = performance.now() - queriers0

		invokers0 = performance.now()
		[@invokersData, invokersRun] = functions.runInvokers @invokers, dataAndLiftedData, lastDataMerged, @lastInvokersData
		invokersTime = performance.now() - invokers0

		renderHook0 = performance.now()
		@renderHook mergeAll([@data, @liftedData])
		renderHookTime = performance.now() - renderHook0

		renderTime = performance.now() - render0
		console.groupCollapsed 'lifters:', keys(liftersRun)
		console.log liftersRun
		console.groupEnd()
		console.groupCollapsed 'queriers:', keys(queriersRun)
		console.log queriersRun
		console.groupEnd()
		console.groupCollapsed 'invokers:', keys(invokersRun)
		console.log invokersRun
		console.groupEnd()
		message = "total: #{parseFloat(renderTime).toFixed(2)}ms 
		lifters: #{parseFloat(liftTime).toFixed(2)}ms 
		queriers: #{parseFloat(queriersTime).toFixed(2)}ms 
		invokers: #{parseFloat(invokersTime).toFixed(2)}ms 
		renderHook: #{parseFloat(renderHookTime).toFixed(2)}ms"
		if renderTime > 16 then console.warn message
		else console.log message
		
		@lastRenderedData = @data

		functions.runQueries @parser.queryParser, @queriersData, @lastQueriersData
		@lastQueriersData = @queriersData

		functions.runQueries @parser.mutationParser, @invokersData, @lastInvokersData
		@lastInvokersData = @invokersData

		if @DEV_MODE && @devDataApi
			saveDevData @devDataApi, @data, 'data_live', true
			saveDevData @devDataApi, @liftedData, 'liftedData_live', true
			saveDevData @devDataApi, @queriersData, 'queriersData_live', true
			saveDevData @devDataApi, @invokersData, 'invokersData_live', true


module.exports = App



	# # prio 2
	# subscribe = (path, callback) -> null
	# unsubscribe = (path, callback) -> null

# ----- deprecation line
				# i = parseInt last(path)
				# if isNaN i
				# 	@data = assocPath path, value, @data
				# else
				# 	# TODO: skip this part? or break out into utility?
				# 	ar = getPath dropLast(1, path), @data
				# 	if !isa(Array, ar) then throw new Error join('.', path) + ' is not an array'
				# 	newAr = update i, value, ar
				# 	@data = assocPath dropLast(1, path), newAr, @data

	# loadSavedData: ->
	# 	loadData = (name) =>
	# 		name = replace /^data_/, '', name
	# 		ajax
	# 			type: 'GET'
	# 			url: "http://localhost:3001/dev/data/#{name}"
	# 			success: (data) => @data = data
	# 			error: (xhr) -> console.log 'Failed loading data'

	# 	nameToPair = (name) -> [name, -> loadData(name)]
	# 	toFunctionMap = (xs) -> compose(fromPairs, map(nameToPair)) xs
	# 	ajax
	# 		type: 'GET'
	# 		url: "http://localhost:3001/dev/data"
	# 		success: (data) => @_loadedData = toFunctionMap data
	# 		error: (xhr) -> console.log 'Failed loading data'

	# 	if @_loadedData
	# 		console.log 'returning the saved data from last time you called loadSavedData:'
	# 		@_loadedData
	# 	else 'there is no data loaded yet, try calling loadSavedData again'
