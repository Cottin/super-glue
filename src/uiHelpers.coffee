React = require 'react'
{__, add, any, anyPass, complement, compose, composeP, equals, flatten, has, head, isEmpty, isNil, map, memoize, path, pickBy, prop, props, set, test} = R = require 'ramda' #auto_require:ramda
{ymapObjIndexed, isa, mergeMany, isEmptyObj, cc} = require 'ramda-extras'

uiHelpers = (app) ->
	# redeclarations from actionHelpers to avoid dependency here
	actionStatePath = ({_path}) -> flatten ['actions', _path, 'state']
	actionPath = ({_path}) -> flatten ['actions', _path]

	# :: action -> str
	actionState = (action) -> path actionStatePath(action), app.data

	# :: action -> bool
	# use these to check the state of an action
	pending = compose equals('pending'), actionState
	failed = compose equals('error'), actionState
	succeeded = compose equals('success'), actionState

	resetAction = (action) ->
		app.set actionPath(action), null

	# :: any -> bool
	# e.g. good to tell if you can render collections or not
	# isEmptyish = anyPass [isNil, isEmpty, isEmptyObj]

	# factorize = memoize (comp) -> React.createFactory comp

	# cache = {}
	# fac2 = (comp) ->
	# 	if cache[comp.displayName] then return cache[comp.displayName]
	# 	else
	# 		cache[comp.displayName] = React.createFactory comp
	# 		return cache[comp.displayName]

	# :: comp, obj, [comp] -> comp
	# takes care of the React.createFactory dance for you
	# (note: there will probably be something more done here in the future, like om-stuff)
	build = (comp, props, children...) ->
		# TODO: memoize so this doesn't add to rendering time
		# if ! comp.displayName || comp.displayName == ''
		# 	throw new Error 'build can only be used for components with displayName'

		# factorized = React.createFactory comp
		# factorized = fac2 comp
		# console.log 'factorized', factorized
		# factorized = factorize comp
		# console.log 'dipName', comp.constructor.displayName
		# console.log 'ui props', props
		# return factorized props, children
		return React.createElement comp, props, children...

	# :: comp, s, f -> comp
	# wraps a component and set its props from app.data and app.actions
	connect = (component, displayName, bindFn, actionBindFn) ->
		if R.is String, bindFn
			actionProps = if actionBindFn then actionBindFn app.actions else {}
			wrapperComponent = React.createClass
				displayName: displayName
				render: ->
					liftedDataProps = path ['liftedData', bindFn], app
					propsToUse = mergeMany actionProps, liftedDataProps, @props
					build component, propsToUse

			return wrapperComponent

		bindings = bindFn app.dataPaths, app.actions, app.liftedDataPaths
		ymapObjIndexed bindings, (v, k) ->
			if isNil v then throw new Error "connect #{displayName}
			has nil bindning for key #{k}"
		actionProps = pickBy isa(Function), bindings
		hasDataPath = compose equals('data'), head, prop('_path')
		hasLiftedDataPath = compose equals('liftedData'), head, prop('_path')

		isDataBinding = (x) -> has '_path', x
		manualBindings = pickBy complement(isDataBinding), bindings
		dataBindings = pickBy isDataBinding, bindings
		simpleDataBindings = cc map(prop('_path')), pickBy(hasDataPath), dataBindings
		liftedDataBindings = cc map(prop('_path')), pickBy(hasLiftedDataPath), dataBindings

		wrapperComponent = React.createClass
			displayName: displayName
			render: ->
				dataProps = map path(__, app), simpleDataBindings
				liftedDataProps = map path(__, app), liftedDataBindings
				propsToUse = mergeMany actionProps, dataProps,
					liftedDataProps, manualBindings, @props
				build component, propsToUse

		return wrapperComponent

	stateful = (statusPath, thenable, callbacks) -> () ->
		app.set statusPath, 'pending', 'statefulCall'
		test1 = thenable.apply null, arguments
		originalArgs = arguments
		{ok, fail} = callbacks || {}
		test1
			.then ->
				app.set statusPath, 'success', 'statefulCall'
				if ok then ok.apply {originalArgs: originalArgs[0]}, arguments
			.catch (err) ->
				app.set statusPath, 'error', 'statefulCall'
				if fail then fail.apply null, arguments

	return {pending, failed, succeeded, resetAction, actionState, build, connect, stateful}


module.exports = uiHelpers

	# ######### ACTION
	# action = (fs..., f) ->
	# 	wrapper = (f, args...) ->
	# 		composition = composeP2 fs..., f
	# 		return composition args...
	# 	return wrapKeepSignature f, wrapper
