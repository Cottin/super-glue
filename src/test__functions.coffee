assert = require 'assert'
{without, any, eq, flip, functions, has, invoke, invoker, join, keys, length, merge, path, propEq, test} = require 'ramda' #auto_require:ramda
{isa, ypickBy} = require 'ramda-extras'
{liftData, wrapActions} = functions = require './functions'
{denorm} = require 'sometools'
util = require 'util'

eq = flip assert.equal
deepEq = flip assert.deepEqual

mockData =
	boats:
		1: {id: 1, name: 'Arcona', lys: 1.36}
		2: {id: 2, name: 'Laser', lys: 1.2}
		3: {id: 3, name: 'Vega', lys: 1.1}
	people:
		1: {id: 1, name: 'Victor', boats: [2]}
		2: {id: 2, name: 'Lathike', boats: [1, 3]}
	ui:
		a: 1

mockLifters = [
	{name: 'people_', params: ['boats', 'people'], f: (boats, people) -> denorm {boats}, people}
	{ name: 'laserOwners', params: ['people_'],
	f: (people_) -> ypickBy people_, (p) -> any propEq('name', 'Laser'), p.boats}
	{name: 'emptyLifter', params: ['people'], f: (people) -> null}
	{name: 'nested', params: ['ui__a'], f: (ui__a) -> ui__a}
]

describe 'functions', ->
	describe 'buildPaths', ->
		it 'should handle flat case', ->
			o = {a: {a1: 1}, b: {b1: {b11: 2, b12: 3}, b2: 4}, c: 5}
			res = functions.buildPaths o, ['>']
			deepEq ['>', 'a', 'a1'], res.a.a1._path
			deepEq ['>', 'b', 'b1', 'b11'], res.b.b1.b11._path
			deepEq ['>', 'b', 'b1', 'b12'], res.b.b1.b12._path

	describe 'liftData', ->
		it 'should handle simple case', ->
			[res, liftersRun] = functions.liftData mockLifters, mockData, {}
			eq 'Laser', res.people_[1].boats[0].name
			eq 'Vega', res.people_[2].boats[1].name

		it 'should handle complex case', ->
			[res, liftersRun] = functions.liftData mockLifters, mockData, {}
			eq 1, length(keys(res.laserOwners))
			eq 'Victor', res.laserOwners[1].name

		it 'should handle optimization in simple case', ->
			[res1, liftersRun] = functions.liftData mockLifters, mockData, {}
			[res2, liftersRun] = functions.liftData mockLifters, mockData, merge(mockData, res1)
			eq res1.people_, res2.people_

		it 'should handle optimization in complex case', ->
			[res1, liftersRun] = functions.liftData mockLifters, mockData, {}
			[res2, liftersRun] = functions.liftData mockLifters, mockData, merge(mockData, res1)
			eq res1.laserOwners, res2.laserOwners

		it 'should still return the key if lifter returns null', ->
			[res, liftersRun] = functions.liftData mockLifters, mockData, {}
			eq true, has('emptyLifter', res)

		it 'nested data', ->
			[res, _] = liftData mockLifters, mockData, {}
			eq 1, res.nested

	describe 'prepareLifters', ->
		data = {a: 1, b: 2, d: 'four', e: {e1: 1}}
		l1 = (a, b, c) -> a + b + c
		l2 = (l4, b) -> l4 + b
		l3 = (b, d) -> b + d
		l4 = (a, b) -> a + b
		l5 = (l5, a) -> l5 + a
		l6 = (l8, b) -> l8 + b
		l7 = (l6, l8, l9, a) -> 
		l8 = (l2, d) -> l2 + d
		l9 = (l3, l8) -> l3 + l8
		l10 = (a, l11) ->
		l11 = (l10, b) ->
		l12 = (a, l13) ->
		l13 = (l14, b, l15) ->
		l14 = (l15) ->
		l15 = (l12) ->
		l16 = (e__e1) ->
		l17 = (SELF) ->
		a = (b) ->

		it 'should throw error for data dep that dont exist', ->
			fn = -> functions.prepareLifters data, {l1}
			assert.throws fn, Error

		it 'should throw error for lifter dep that dont exist', ->
			fn = -> functions.prepareLifters data, {l2}
			assert.throws fn, Error

		it 'should throw error for data dep that is the lifter itself', ->
			fn = -> functions.prepareLifters data, {l5}
			assert.throws fn, Error

		it 'should throw error for data dep that is the lifter itself using SELF arg name', ->
			fn = -> functions.prepareLifters {SELF: 1}, {l17}
			assert.throws fn, Error

		it 'handle SELF', ->
			res = functions.prepareLifters {l17: 1}, {l17}, true
			console.log 'res', res

		it 'should order lifters without dependencies on other lifters first', ->
			res = functions.prepareLifters data, {l2, l3, l4}
			eq l3, res[0].f

		it 'should correctly order lifters with dependencies on other lifters', ->
			res = functions.prepareLifters data, {l2, l3, l4, l6, l7, l8, l9}
			eq l3, res[0].f
			eq l4, res[1].f
			eq l2, res[2].f
			eq l8, res[3].f
			eq l6, res[4].f
			eq l9, res[5].f
			eq l7, res[6].f

		it 'should throw error for simple cyclic dep', ->
			fn = -> functions.prepareLifters data, {l10, l11}
			assert.throws fn, Error

		it 'should throw error for complex cyclic dep', ->
			fn = -> functions.prepareLifters data, {l12, l13, l14, l15}
			assert.throws fn, Error

		it 'should handle nested paths', ->
			res = functions.prepareLifters data, {l16}
			eq l16, res[0].f

		# it 'should throw error if lifter shadows initial data', ->
		# 	fn = -> functions.prepareLifters data, {a}
		# 	assert.throws fn, Error
			

	describe 'wrapActions', ->
		mutators =
			a:
				a1: (x) -> x
				a2: (x) -> x * x
			b:
				b1: (x) -> x + 1

		it 'simple case', ->
			res = wrapActions false, mutators, (x, path) -> x + join('.', path)
			eq '4a.a2', res.a.a2(2)

	describe 'invokeActions', ->
		mockActions =
			a:
				a1: ({x}) -> x + 1
				a2: ({x}) -> x + 2
			b:
				b1: ({x}) -> x + 10

		mockInvokerResults =
			invoker1: {a_a2: {x: 1}}
			invoker2: undefined

		it 'should handle simple case', ->
			res = functions.invokeActions mockActions, mockInvokerResults, {}
			eq 3, res.invoker1

		it 'should not invoke NO_CHANGE', -> # todo: is this NO_CANGE REALLY NEEDED?
			res = functions.invokeActions mockActions, mockInvokerResults, {}
			eq 'NO_CHANGE', res.invoker2

		it 'should throw error if trying to invoke an action that don\'t exists', ->
			fn = -> functions.invokeActions {}, mockInvokerResults, {}
			assert.throws fn, Error

		it 'should return NO_CHANGE if there is no change in invoker result', ->
			res = functions.invokeActions mockActions, mockInvokerResults, mockInvokerResults
			eq 'NO_CHANGE', res.invoker1




# depr line ---
	# describe 'shouldUpdate', ->
	# 	a = {b: 1, c: 2}
	# 	it 'should handle simple false cases', ->
	# 		res = functions.shouldUpdate ['a'], {a, b:2}, {a}
	# 		eq false, res

	# 	it 'should handle simple true cases', ->
	# 		res = functions.shouldUpdate ['a'], {a, b:2}, {a: {b: 1, c: 2}}
	# 		eq true, res

	# describe 'lifter', ->
	# 	inv = functions.lifter 'test', (a, b, c) -> a + b + c
	# 	it 'should handle simple NO_CHANGE case', ->
	# 		res = inv.f {a: 1, b: 2, c: 3}, {a: 1, b: 2, c: 3}
	# 		eq 'test', inv.name
	# 		eq 'NO_CHANGE', res

	# 	it 'should handle simple case', ->
	# 		res = inv.f {a: 1, b: 1, c: 3}, {a: 1, b: 2, c: 3}
	# 		eq 6, res
