{any, append, chain, composeP, curry, find, flatten, forEach, functions, head, join, map, mapObjIndexed, max, path, whereEq} = require 'ramda' #auto_require:ramda
{isa, composeP2, fail, getPath} = require 'ramda-extras'

actionHelpers = curry (app, xhr) ->

	# :: do changes to app data based on @_path
	set = (o) -> app.set head(@_path), o
	setPath = curry (path, o) -> app.set path, o
	setById = (o) -> app.set append(o.id, [head(@_path)]), o

	unset = -> app.unset head(@_path)
	getPathById = curry (path, id) -> cc find(whereEq({id})), getPath(path, app.data)

	# :: action -> [str]
	actionPath = ({_path}) -> flatten ['actions', _path]
	actionStatePath = ({_path}) -> flatten ['actions', _path, 'state']
	actionStatusPath = ({_path}) -> flatten ['actions', _path, 'status']

	# :: fs... -> [fs]
	# just some syntax helper when you declare actions
	action = (fs...) -> fs

	# :: fs... -> f
	# composes functions with composeP2
	# logger can be true/false or actual logging function you want to use
	actionBuilder = (logger) -> (fs...) ->
		if logger == true then funs = chain logAndIdentity, fs
		else if isa Function, logger then funs = chain logger, fs
		else funs = fs
		actionFunction = composeP2 funs...
		return actionFunction

	# :: f -> [f, f2]
	# good for debugging composition chains, e.g. use with chain logAndIdentity, ...
	logAndIdentity = (f) ->
		logFn = (x) ->
			console.log 'next action step:', f, 'arg:', x
			return x
		[f, logFn]

	# iterates a tree of functions and adds the full path as _path to each function
	_buildAction = (path, logger) -> (v, k) ->
		_path = append k, path
		if isa Array, v
			if logger == true then funs = chain logAndIdentity, v
			else if isa Function, logger then funs = chain logger, v
			else funs = v
			f = composeP2 funs...
			return _wrapAction f, _path
		else mapObjIndexed _buildAction(_path), v

	# _buildAction = (path) -> (v, k) ->
	# 	_path = append k, path
	# 	if isa Function, v
	# 		return _wrapAction v, _path
	# 	else mapObjIndexed _buildAction(_path), v

	_wrapAction = (action, _path) ->
		# .caller is not standard but works nicely in Chrome at least
		# https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function/caller
		bound = action.bind({_path})
		wrapper = (o) ->
			console.groupCollapsed "ACTION #{join('.', _path)}", o
			console.log wrapper.caller
			console.groupEnd()
			bound o
		wrapper._path = _path
		return wrapper

	actionComposeCall = (context, fs..., data) ->
		{_path} = context
		bindF = (f) -> f.bind({_path})
		boundFs = map bindF, fs
		return composeP2(boundFs...)(data)
		# fsCopy = []
		# console.log 'context.path', context._path
		# copyAndBind = (f) ->
		# 	fCopy = f
		# 	bound = fCopy.bind({_path})
		# 	console.log 'fCopy', fCopy
		# 	console.log 'res', fCopy()
		# 	fsCopy.push fCopy
		# 	return fsCopy
		# forEach copyAndBind, fs
		# console.log 'fsCopy', fsCopy
		# console.log 'fsCopy0', fsCopy[0]()

		# return composeP2(fsCopy...)(data)

	actionGroupBuilder = (logger) -> (path, actionObject) ->
		mapObjIndexed _buildAction([path], logger), actionObject

	# :: obj -> obj
	# builds a tree of action functions from your action declarations
	buildActions = (o) -> mapObjIndexed _buildAction([]), o
	# buildActions = (o, addLogging) -> mapObjIndexed _buildAction(addLogging, []), o

	#### "Singleton" endpoints - max one request can go through at a time, and
	#### "they set their own state in the global data
	# :: str -> Thenable(any)
	get = (url) ->
		_path = @_path
		app.set actionStatePath({_path}), 'pending'
		success = (data) ->
			app.set actionStatePath({_path}), 'success'
			return data
		error = (_, status) ->
			app.set actionStatePath({_path}), 'error'
			app.set actionStatusPath({_path}), status

		xhr {method: 'get', url, success, error}
	del = (url) -> xhr {method: 'delete'}, 'del', url
	# :: [str, any] -> Thenable(any)
	post = ([url, data]) -> xhr {method: 'post', data, url}
	put = ([url, data]) ->
		_path = @_path
		app.set actionStatePath({_path}), 'pending'
		success = (data) ->
			app.set actionStatePath({_path}), 'success'
			return data
		error = (_, status) ->
			app.set actionStatePath({_path}), 'error'
			app.set actionStatusPath({_path}), status
		return xhr {method: 'put', url, data, success, error}

	#### "Normal" endpoints - just makes the request an does not set any state in the global data
	mget = mpost = mput = mdel = -> throw new Error 'not yet implemented'

	fail = fail # export fail from ramda-extras so user don't need to depend on ramda-extras
	return {actionGroupBuilder, actionStatePath, get, del, post, put, action, actionBuilder, buildActions, set, unset, getPathById, setPath, setById, fail, actionComposeCall}


module.exports = actionHelpers

	# ######### ACTION
	# action = (fs..., f) ->
	# 	wrapper = (f, args...) ->
	# 		composition = composeP2 fs..., f
	# 		return composition args...
	# 	return wrapKeepSignature f, wrapper
