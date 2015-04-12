$ = require 'jQuery'
R = require 'ramda'
ramdaExtras = require 'ramda-extras'
utils = require './utils'

{curry, isEmpty, last, append, push, apply, compose, reduce, map, mapObjIndexed, length, filter, find, contains, pluck, zipObj, createMapEntry, range, sort, eq, prop, get, func, bind, omit, pickBy, merge, assoc, type, path, propEq, functions} = R # auto_require:funp
{doit} = ramdaExtras
{LocalStorage, infoGroup} = utils


# ----------------------------------------------------------------------------------------------------------
# STATIC HELPERS
# ----------------------------------------------------------------------------------------------------------
isOfType = (typeString) -> (o) -> if !o then false else propEq '_type', typeString, o
isAction = isOfType 'action'
isObject = isOfType 'object'
isList = isOfType 'list'
isValue = isOfType 'value'
isListItem = isOfType 'listItem'

isActionOfType = (typeString) -> (o) -> R.and isAction(o), propEq('_actionType', typeString, o)
isGetAction = isActionOfType 'getAction'
isPostAction = isActionOfType 'postAction'
isPutAction = isActionOfType 'putAction'
isDeleteAction = isActionOfType 'deleteAction'

_ensureAction = (a) -> if !isAction(a) then throw new Error "#{a} is not an action" else a

# ----------------------------------------------------------------------------------------------------------
# CURSOR FUNCTIONS
# ----------------------------------------------------------------------------------------------------------
cursorFunctions =
	isEmpty: (c) ->
		v = c.value() 
		if v == null || v == undefined then true
		else if v == {} then true
		else if v == [] then true
		else false

	isWaiting: (a) -> cc eq('waiting'), prop('_path'), _ensureAction, a
	isSuccess: (a) -> cc eq('success'), prop('_path'), _ensureAction, a
	hasError: (a) -> cc eq('success'), prop('_path'), _ensureAction, a

# ----------------------------------------------------------------------------------------------------------
# APP-DEPENDENT HELPERS
# ----------------------------------------------------------------------------------------------------------
helpers = (app) ->
	# ----------------------------------------------------------------------------------------------------------
	# PRIVATE HELPERS
	# ----------------------------------------------------------------------------------------------------------
	_setState = curry (path, state) -> app.transact.set path, state, "callback for #{last(path)}"
	_setData = curry (path, data) -> app.transact.set path, data, "callback for #{last(path)}"
	_getData = (path) -> getPath path, app.data
	_setStateWaiting = (path) -> _setData path, {state: 'waiting', ts: new Date().valueOf()}
	_setStateSuccess = (path) -> _setData path, {state: 'success', ts: new Date().valueOf()}
	_setStateError = (path, xhr) -> _setData path, {state: 'error', ts: new Date().valueOf(), statusCode: xhr.status, statusText: xhr.statusText, data: xhr.responseJSON}

	_isAjaxPromise = (x) -> cc R.and(contains('success'), contains('error')), functions, x
	_ajax = (url) -> {url: app.config.apiUrl + url, xhrFields: {withCredentials: true}, contentType: 'application/json'}

	# ----------------------------------------------------------------------------------------------------------
	# XHR
	# ----------------------------------------------------------------------------------------------------------
	get = (url) -> $.ajax merge(_ajax(url), {type: 'get'})
	post = (url, data) -> $.ajax merge(_ajax(url), {type: 'post', data: JSON.stringify(data)})




	# ----------------------------------------------------------------------------------------------------------
	# ACTION DEFINITIONS
	# ----------------------------------------------------------------------------------------------------------
	_actionBuilder = (_actionType) -> (name, f) -> {_type:'action', _actionType, name, call:f}
	action = _actionBuilder 'action'
	ajaxAction = _actionBuilder 'ajaxAction'

	localAction = _actionBuilder('localAction')

	getAction = _actionBuilder('getAction')
	postAction = _actionBuilder('postAction')
	putAction = _actionBuilder('putAction')
	deleteAction = _actionBuilder('deleteAction')

	# ----------------------------------------------------------------------------------------------------------
	# OBJECT DEFINITIONS
	# ----------------------------------------------------------------------------------------------------------
	_actionsToObject = (as) ->
		aToObj = (a, b) -> assoc b.name, omit(['name'], b), a
		reduce aToObj, {}, as

	object = (_name, _validator, actionsAndSubObjects...) ->
		actionsObj = _actionsToObject filter(isAction, actionsAndSubObjects)
		return merge {_type:'object', _name, _validator}, actionsObj

	list = (_name, _validator, actionsAndListItems...) ->
		actionsObj = _actionsToObject filter(isAction, actionsAndListItems)
		_listItems = find isListItem, actionsAndListItems
		return merge {_type:'list', _name, _validator, _listItems}, actionsObj

	value = (_name, _validator, actions...) ->
		if any complement(isAction), actions
			throw new Error 'value can only have actions as children'
		actionsObj = _actionsToObject actions
		return merge {_type:'value', _name, _validator}, actionsObj

	listItem = (_validator, actions...) ->
		if any complement(isAction), actions
			throw new Error 'listItem can only have actions as children'
		actionsObj = _actionsToObject actions
		return merge {_type:'listItem', _validator}, actionsObj



	# ----------------------------------------------------------------------------------------------------------
	# SUB-CURSORS
	# ----------------------------------------------------------------------------------------------------------
	_commonListItemActions = (path) ->
		set: (value) ->
			console.log '----------------------'
			infoGroup "ACTION SET #{path} (caller #{@caller}):", value
			app.transact.set path, value
		value: -> getPath path, app.data

	_toListItemCursor = (listCursor) -> (index) ->
		path = cc append(index+''), append('value'), listCursor._path
		listItemsActions = pickBy isAction, listCursor._listItems
		return _mergeMany {_type:'listItem'}, _commonListItemActions(path), listItemsActions, {_path:path}

	_buildListItemSubCursors = (listCursor) -> () ->
		indexes = range 0, length(listCursor.value())
		return map _toListItemCursor(listCursor), indexes





	# ----------------------------------------------------------------------------------------------------------
	# BINDING OF ACTIONS
	# ----------------------------------------------------------------------------------------------------------
	_commonActions = (path) ->
		set: (value) ->
			console.log '----------------------'
			infoGroup "ACTION SET #{path} (caller #{@caller}):", value
			app.transact.set append('value', path), value
		clear: ->
			console.log '----------------------'
			infoGroup "ACTION CLEAR #{path} (caller #{@caller}):"
			app.transact.set append('value', path), null
		value: -> getPath append('value', path), app.data

	_commonListActions = (path) ->
		push: (value) -> app.transact.push append('value', path), value

	_omitAnnotations = omit ['_name', '_validator']
	_mergeMany = (original, objects...) -> reduce merge, original, objects

	_bindSimpleAction = (path, {_actionType, name, call}) ->
		actionPath = append(name, path)
		f = (params...) ->
			console.log '----------------------'
			infoGroup "ACTION #{actionPath} (caller #{@caller}):", params
			call.apply {path:actionPath}, params
		return f

	_isPathWaiting = (path) -> if !path || !_getData(path) then false else cc propEq('state', 'waiting'), _getData(path)

	_bindActionXhr = (actionPath, fn, success, error) ->
		# TODO: make sure none is called if it's already waiting
		f = (params...) ->
			console.log '----------------------'

			if _isPathWaiting actionPath
				infoGroup "ACTION #{actionPath}  __DO NOTHING__ (caller #{@caller}):", params
				return 'already waiting'

			infoGroup "ACTION #{actionPath} (caller #{@caller}):", params

			_setStateWaiting actionPath
			ajaxPromise = fn.apply {path:actionPath}, params
			if !_isAjaxPromise(ajaxPromise) then throw new Error "action #{actionPath} does not return an ajax promise" 
			ajaxPromise.success(success).error(error)
		# f.clear = -> app.transact.set actionPath, null, "action clear(#{actionPath}, invoked from #{@caller})"
		return f

	_bindAjaxAction = (path, actionName, {call}) ->
		actionPath = append actionName, path
		success = (data) -> doit _setStateSuccess(actionPath)
		error = (xhr) -> _setStateError actionPath, xhr 
		return _bindActionXhr actionPath, call, success, error

	_bindGetAction = (path, actionName, {call}) ->
		actionPath = append actionName, path
		success = (data) -> doit _setStateSuccess(actionPath), _setData(append('value', path), data)
		error = (xhr) -> _setStateError actionPath, xhr 
		return _bindActionXhr actionPath, call, success, error

	_bindPostAction = (path, actionName, {call}) ->
		actionPath = append actionName, path
		success = (data) -> doit _setStateSuccess(actionPath), _setData(append('value', path), data)
		error = (xhr) -> _setStateError actionPath, xhr 
		return _bindActionXhr actionPath, call, success, error

	_stateFnBuilder = (path) -> () -> _getData(path)

	_bindAction = (path) -> (a, actionName) ->
		if !a || a._type != 'action' then return a
		boundF = switch (a._actionType)
			when 'action' then _bindSimpleAction path, actionName, a
			when 'ajaxAction' then _bindAjaxAction path, actionName, a
			when 'getAction' then _bindGetAction path, actionName, a
			when 'postAction' then _bindPostAction path, actionName, a
			when 'localAction' then a.call.bind({path}) # todo
			else throw new Error 'action type not supported'
		actionPath = append actionName, path
		statePath = append 'state', actionPath
		boundF._type = a._type
		boundF._actionType = a._actionType
		return boundF

	_bindActions = (o, path) -> return mapObjIndexed _bindAction(path), o



	# ----------------------------------------------------------------------------------------------------------
	# CONVERTIONS FROM DEFINITION TO CURSOR
	# ----------------------------------------------------------------------------------------------------------
	_objectToCursor = (o, path = []) ->
		path = append(o._name, path)
		preparedObject = _bindActions o, path
		cursor = _mergeMany _omitAnnotations(preparedObject), _commonActions(path), {_path:path}
		[o._name, cursor]

	_listToCursor = (o, path = []) ->
		path = append(o._name, path)
		preparedObject = _bindActions o, path
		cursor = _mergeMany _omitAnnotations(preparedObject), _commonActions(path), _commonListActions(path), {_path:path}
		cursor = _mergeMany cursor, {listOfSubCursors: _buildListItemSubCursors(cursor)}
		[o._name, cursor]

	_valueToCursor = _objectToCursor

	_toCursor = (o) ->
		switch o._type
			when 'object' then _objectToCursor o
			when 'list' then _listToCursor o
			when 'value' then _valueToCursor o



	# ----------------------------------------------------------------------------------------------------------
	# EXPORTS
	# ----------------------------------------------------------------------------------------------------------
	buildObjectTree = (_, objects...) ->
		zipObj pluck('name', objects), pluck('value', objects)

	buildCursorTree = (_, definitions...) ->
		isNotRootLevel = cc complement, anyPass, [isObject, isList, isValue]
		if any isNotRootLevel, definitions
			throw new Error 'top level cursors needs to be one of [object, list, value]'
		createCursor = compose apply(createMapEntry), _toCursor
		createCursorAndMerge = (a, b) -> merge a, createCursor(b)
		reduce createCursorAndMerge, {}, definitions









	return {get, post, object, list, value, listItem, isAction, isList, isObject, isListItem, action, ajaxAction, localAction, getAction, postAction, putAction, deleteAction, buildObjectTree, buildCursorTree}


helpers.isAction = isAction
helpers.isObject = isObject
helpers.isList = isList
helpers.isValue = isValue
helpers.isListItem = isListItem
helpers.cursorFunctions = cursorFunctions

module.exports = helpers


## -- depracation line 
	#
	# buildObjectTree null,
	# 	object 'a', null,
	# 		action 'a1', (a, b)			-> return @
	# 		action 'a2', (a)			-> return @
	# 		action 'a3', (a, b)			-> return a + b 
	# 	object 'b', null,
	# 		action 'b1', (a, b)			-> return @
	# 		action 'b2', (a)			-> return @

	# # ----------------------------------------------------------------------------------------------------------
	# # XHR
	# # ----------------------------------------------------------------------------------------------------------
	# get = (url, path) ->
	# 	setState = curry(_setStateFromXhrCallback) path
	# 	dataPath = cc append('value'), dropLast(1), path
	# 	setData = curry(_setDataFromXhrCallback) dataPath
	# 	setState {state: 'waiting'}
	# 	$.ajax
	# 		type: 'get'
	# 		url: app.config.apiUrl + url
	# 		xhrFields: {withCredentials: true}
	# 		success: (data) -> doit setState({state: 'success'}), setData(data)
	# 		error: (xhr) -> setState {state: 'error', statusCode: xhr.status, statusText: xhr.statusText, data: xhr.responseJSON}
	# post = (url, path, data) ->
	# 	setState = curry(_setStateFromXhrCallback) path
	# 	dataPath = cc append('value'), dropLast(1), path
	# 	setData = curry(_setDataFromXhrCallback) dataPath
	# 	setState {state: 'waiting'}
	# 	$.ajax
	# 		type: 'post'
	# 		contentType: 'application/json'
	# 		data: JSON.stringify data
	# 		url: app.config.apiUrl + url
	# 		xhrFields: {withCredentials: true}
	# 		success: (data) -> doit setState({state: 'success'}), setData(data)
	# 		error: (xhr) -> setState {state: 'error', statusCode: xhr.status, statusText: xhr.statusText, data: xhr.responseJSON}









	# # ----------------------------------------------------------------------------------------------------------
	# # OBJECT
	# # ----------------------------------------------------------------------------------------------------------

	# # :: str, str, arrOf(action) -> obj
	# # Declare an object with optional actions. If passed a typeChecker, it will be called when the set object
	# # is called (todo).
	# object = (objectName, type, actions...) ->
	# 	bindAction = (a) ->
	# 		switch (a.type)
	# 			when 'action' then _bindAction objectName, a
	# 			when 'ajaxAction' then _bindAjaxAction objectName, a
	# 			when 'getAction' then _bindGetAction objectName, a
	# 			else throw new Error 'action type not supported'

	# 	boundActions = map bindAction, actions
	# 	actionNames = pluck 'actionName', actions
	# 	o = zipObj actionNames, boundActions

	# 	objectPath = [objectName, 'value']
	# 	o.value = -> path objectPath, app.data
	# 	o.set = (x) -> app.transact.set objectPath, x, "todo: write what view called this"
	# 	o.clear = -> app.transact.set objectPath, null, "todo: write what view called this"
	# 	o.state = -> cc call, prop('state'), last, sort(_sortByTs), boundActions
	# 	return {name:objectName, value:o}


	# # ----------------------------------------------------------------------------------------------------------
	# # VANILLA
	# # ----------------------------------------------------------------------------------------------------------
	# # :: str, func -> obj
	# # Declare an action. fn will be called with this.path = [the nested path].
	# ajaxAction = _actionBuilder 'ajaxAction'
	# action = _actionBuilder 'action'

	# _bindAjaxAction = (objectName, {actionName, fn, type}) ->
	# 	actionPath = [objectName, actionName]
	# 	success = (data) -> doit _setStateSuccess(actionPath)
	# 	error = (xhr) -> _setStateError actionPath, xhr 
	# 	return _bindActionXhr actionPath, fn, success, error

	# _bindAction = (objectName, {actionName, fn, type}) ->
	# 	actionPath = [objectName, actionName]
	# 	return fn.bind {path:actionPath}


	# # ----------------------------------------------------------------------------------------------------------
	# # REST
	# # ----------------------------------------------------------------------------------------------------------
	# # :: str, func -> obj
	# # Like action but sets the value of the object to what's returned from the ajaxPromise
	# getAction = _actionBuilder('getAction')
	# postAction = _actionBuilder('postAction')
	# putAction = _actionBuilder('putAction')
	# deleteAction = _actionBuilder('deleteAction')

	# _bindGetAction = (objectName, {actionName, fn, type}) ->
	# 	actionPath = [objectName, actionName]
	# 	success = (data) -> doit _setStateSuccess(actionPath), _setData([objectName, 'value'])
	# 	error = (xhr) -> _setStateError actionPath, xhr 
	# 	return _bindActionXhr actionPath, fn, success, error

	# _bindPostAction = (objectName, {actionName, fn, type}) ->
	# 	actionPath = [objectName, actionName]
	# 	success = (data) -> doit _setStateSuccess(actionPath), _setData([objectName, 'value'])
	# 	error = (xhr) -> _setStateError actionPath, xhr 
	# 	return _bindActionXhr actionPath, fn, success, error
