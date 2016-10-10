{__, all, append, assoc, both, concat, contains, curry, evolve, filter, flatten, forEach, has, head, intersection, invoker, isEmpty, isNil, join, keys, last, length, map, mapObjIndexed, merge, path, pluck, prop, propEq, reduce, sort, split, test, toPairs, without} = R = require 'ramda' #auto_require:ramda
{isa, cc, yfilter, yforEach, ymapObjIndexed} = require 'ramda-extras'
{hasRec, pathRec, pickRec} = sometools = require 'sometools'

_buildPath = (iniPath) -> (v, k) ->
	_path = append k, iniPath
	obj = mapObjIndexed _buildPath(_path), v
	return merge obj, {_path}

# TODO: comment this
buildPaths = (o, initialPath = []) ->
	return mapObjIndexed _buildPath(initialPath), o

# o, o -> a   # Extracts needed params from data and applies them to f
_runLifter = (data, {f, params}) ->
	paths = map split(/__/), params
	f.apply null, map(path(__, data), paths)

# o1 -> o2 -> s -> bool
# Returns true if s is reference-equal in o1 and o2 or if s is missing from both
_eqInBoth = (o1, o2) -> (key) ->
	# console.log 'eq in both', hasRec(key, o1), hasRec(key, o2), pathRec(key, o1) == pathRec(key, o2)
	if hasRec(key, o1)
		return hasRec(key, o2) && pathRec(key, o1) == pathRec(key, o2)
	else
		return !hasRec(key, o2)

# o1 -> o2 -> s -> bool
# Returns true if s is reference-equal in o1 and o2 or if s is missing from both
_eqInBothFlat = (o1, o2) -> (key) ->
	# console.log 'eq in both', key, has(key, o1), has(key, o2), prop(key, o1) == prop(key, o2)
	if has(key, o1)
		# console.log 'o1 == o2', o1, o2, key, prop(key, o1), prop(key, o2)
		return has(key, o2) && prop(key, o1) == prop(key, o2)
	else
		return !has(key, o2)

# Runs all functions in lifters and returns the resulting "lifted data". If lifter
# depends on data that did not change between data and lastData, the value from 
# lastData is used instead as an optimization.
# [{name, f, params}], o, o -> o
liftData = (lifters, data, lastData) ->
	newLiftedData = {}
	liftersRun = {}
	yforEach lifters, ({name, f, params}) ->
		mergedData = merge(data, newLiftedData)
		isEqual = (prop) -> [_eqInBoth(mergedData, lastData)(prop), prop]
		changed = cc map(last), filter(propEq('0', false)), map(isEqual), params
		if length(changed) > 0
			liftersRun[name] = {changed, old: pickRec(params, lastData), new: pickRec(params, mergedData)}
			newLiftedData[name] = _runLifter mergedData, {f, params}
		else
			newLiftedData[name] = lastData[name]
	return [newLiftedData, liftersRun]

runInvokers = (invokers, data, lastData, lastInvokersData) ->
	newLiftedData = {}
	invokersRun = {}
	yforEach invokers, ({name, f, params}) ->
		if all(_eqInBoth(data, lastData), params)
			newLiftedData[name] = lastInvokersData[name]
		else
			invokersRun[name] = {old: pickRec(params, lastData), new: pickRec(params, data)}
			newLiftedData[name] = _runLifter data, {f, params}
	return [newLiftedData, invokersRun]


# Converts map of lifter functions to list of objects with {name, f, params}.
# Returned list is sorted based on lifters dependencies on eachother.
# Error will be thrown for: deps on missing data or lifters and cyclic deps.
# o, o -> [{name, params, f}]
prepareLifters = (initialData, lifters, allowSelf = false) ->
	lifterKeys = keys lifters
	dataKeys = sometools.keysRec initialData
	allKeys = flatten [lifterKeys, dataKeys, 'SELF']

	# convert to object-list for easier handling
	toObject = ([name, f]) -> {name, f, params:sometools.getParamNames(f)}
	replaceSELF = (l) ->
		if ! contains 'SELF', l.params then l
		else
			console.log 'l.params', l.params
			# test1 = evolve {params: (p) -> append(l.name, without(['SELF'], p))}, l
			console.log 'cc:', cc(append('a'), without(['b']), ['b', 'c', 'd'])
			replaceF = (x) -> if x == 'SELF' then l.name else x
			test1 = evolve {params: (p) -> map(replaceF, p)}, l
			console.log 'test1', test1
			return test1
	lifterList = cc map(replaceSELF), map(toObject), toPairs, lifters
	console.log 'lifterList', lifterList

	# throw obvious dependency errors if they exists
	_throwIfDepMissing = ({params, name}) ->
		# if contains name, dataKeys
		# 	throw new Error "Lifter '#{name}' would shadow data with same name"

		yforEach params, (p) ->
			if ! contains(p, allKeys)
				throw new Error "Lifter, invoker or querier '#{name}' has a dependency '#{p}' that don't exist"

		if !allowSelf && contains name, params
			throw new Error "Lifter, invoker or querier '#{name}' has a dependency to itself"

			
	forEach _throwIfDepMissing, lifterList

	# basic = only deps on data,       complex = dep on other lifters
	basicLifters = yfilter lifterList, ({params}) -> all contains(__, dataKeys), params
	complexLifters = yfilter lifterList, ({params}) -> ! all contains(__, dataKeys), params

	# sorting of complex lifters based on their dependencies
	sorter = (acc, lifter) ->
		if all contains(__, acc.keys), lifter.params
			newAcc = evolve {list: append(lifter), keys: append(lifter.name)}, acc
			reduce sorter, {list: newAcc.list, keys: newAcc.keys, queue: []}, newAcc.queue
		else
			evolve {queue: append(lifter)}, acc
	accStart = {list: [], keys: concat(dataKeys, pluck('name', basicLifters)), queue: []}
	console.log 'complexLifters', complexLifters
	sortedOnDeps = reduce sorter, accStart, complexLifters

	console.log 'sortedOnDeps', sortedOnDeps
	if length sortedOnDeps.queue
		throw new Error "You have one or more cyclic dependencies.
		Therefor #{join(',', pluck('name', sortedOnDeps.queue))} could not be resolved."

	return concat basicLifters, sortedOnDeps.list

_wrapActions = curry (DEV_MODE, path, wrapper, v, k) ->
	newPath = append k, path
	if isa Function, v
		fn = (data) ->
			dataToLog = if R.is Function, data then '[function]' else data
			if console.groupCollapsed
				console.groupCollapsed 'ACTION', join('.', newPath), dataToLog
				if DEV_MODE then console.log 'caller:', fn.caller
				console.groupEnd()
			return wrapper(v(data), newPath)
		return fn

	return mapObjIndexed _wrapActions(DEV_MODE, newPath, wrapper), v

wrapActions = (DEV_MODE, actions, wrapper, path = []) ->
	return mapObjIndexed _wrapActions(DEV_MODE, path, wrapper), actions

# o, o -> o
# Invokes actions based on result-map from invokers.
invokeActions = (actions, invokerResults, lastInvokerResults) ->
	_bothEq = _eqInBoth(invokerResults, lastInvokerResults)
	invoke = (result, invoker) ->
		if _bothEq invoker then return 'NO_CHANGE'
		if isNil result then return undefined
		k = cc head, keys, result
		f = path split('_', k), actions
		if ! f then throw new Error "invoker #{invoker} tries to invoke action #{k} which does not exist"
		return f result[k]
	return mapObjIndexed invoke, invokerResults

runQueries = (parserFn, queries, lastQueries) ->
	_bothEqFlat = _eqInBothFlat(queries, lastQueries)
	runParser = (query, path) ->
		# console.log 'runParser PAHT', path, queries, queries[path], lastQueries[path]
		if _bothEqFlat path
			# console.log 'noChange'
			return 'NO_CHANGE'
		# if isNil query then return undefined
		res = parserFn query, cc(head, split('__'), path)
		return res

	return mapObjIndexed runParser, queries

module.exports = {liftData, runInvokers, buildPaths, prepareLifters,
wrapActions, invokeActions, runQueries}


# deprecation line ---
	# basic sort to put lifters without dep on other lifters on top
	# diff = (a, b) ->
	# 	a_ = isEmpty intersection(a.params, lifterKeys)
	# 	b_ = isEmpty intersection(b.params, lifterKeys)
	# 	if a_ && !b_ then -1
	# 	else if !a_ && b_ then 1
	# 	else 0
	# initiallySorted = sort diff, lifterList


# shouldUpdate = (params, lastData, data) ->
# 	for p in params then if lastData[p] != data[p] then return true
# 	return false

# lifter = (name, func) ->
# 	params = sometools.getParamNames func
# 	f = (lastData, data) ->
# 		if ! shouldUpdate params, lastData, data then 'NO_CHANGE'
# 		else func.apply null, map(prop(__, data), params)
# 	return {name, f}

# runInvoker = (invoker, actions, lastData, data) ->
# 	return assoc lifter.name, lifter.f(data), data
# 	return invoker

