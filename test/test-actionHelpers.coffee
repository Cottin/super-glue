assert = require('assert')
actionHelpers = require '../src/actionHelpers'
{add, bind, concat, flip, functions, identity, inc, path, reduce} = require 'ramda' #auto_require:ramda

eqF = flip assert.equal
deepEqF = flip assert.deepEqual

mockApp = {}
mockXhr = -> false
concatMany = (lists...) -> reduce concat, [], lists

mockedActionHelpers = actionHelpers(mockApp, mockXhr)
{actionGroup, action} = mockedActionHelpers

describe 'actionHelpers', ->
	# describe 'actionBuilder', ->
	# 	it 'should be able to add logging', ->
	# 		fakeLogger = (f) ->
	# 			logFn = (x) ->
	# 				console.log 'next action step:', f, 'arg:', x
	# 				return inc x
	# 			[f, logFn]
	# 		builder = mockedActionHelpers.actionBuilder fakeLogger
	# 		action = builder(identity, identity, identity)
	# 		eqF 4, action(1)

	describe 'buildActions', ->
		it 'should set path correctly', ->
			a = actionGroup 'a',
				a1: action inc, inc

			deepEqF ['a', 'a1'], a.a1._path

		it 'should bind path correctly', ->
			f1 = (x) -> concatMany x, [1], @_path
			f2 = (x) -> concatMany x, [2],  @_path
			a = actionGroup 'a',
				a1: action f1, f2

			deepEqF [0, 2, 'a', 'a1', 1, 'a', 'a1'], a.a1([0])

		it 'should be able to reference function in other functionGroups', ->
			f1 = (x) -> concatMany x, [1], @_path
			f2 = (x) -> concatMany x, [2],  @_path
			a = actionGroup 'a',
				a1: action f1, f2

			b = actionGroup 'b',
				b1: action a.a1, (x) -> concat([-1], x)

			deepEqF [-1, 0, 2, 'a', 'a1', 1, 'a', 'a1'], b.b1([0])


	# 	it 'should bind path correctly', ->
	# 		builder = mockedActionHelpers.actionBuilder false
	# 		o =
	# 			a:
	# 				a1: builder -> @_path
	# 			b:
	# 				b1: builder inc, inc, inc
	# 				b2: builder inc, inc, inc, inc

	# 		actions = mockedActionHelpers.buildActions o
	# 		deepEqF ['a', 'a1'], actions.a.a1()

	# describe 'actionComposeCall', ->
	# 	it 'should bind functions to {_path}', ->
	# 		ac = mockedActionHelpers.actionComposeCall
	# 		f1 = (x) -> concatMany x, [1], @_path
	# 		f2 = (x) -> concatMany x, [2],  @_path
	# 		o =
	# 			a:
	# 				a1: (x) -> ac @, f1, f2, x

	# 		actions = mockedActionHelpers.buildActions o
	# 		deepEqF [0, 2, 'a', 'a1', 1, 'a', 'a1'], actions.a.a1([0])

		# it 'should be able to reference a sibling function', ->
		# 	ac = mockedActionHelpers.actionComposeCall
		# 	f1 = (x) -> concatMany x, [1], @_path
		# 	f2 = (x) -> concatMany x, [2],  @_path
		# 	o =
		# 		a:
		# 			a1: (x) -> ac @, f1, f2, x
		# 		b:
		# 			b1: (x) ->
		# 				console.log 'a.a1', @a?.a1
		# 				ac @, @a.a1, concat([1], x)

		# 	actions = mockedActionHelpers.buildActions o
		# 	deepEqF [1, 0, 2, 'a', 'a1', 1, 'a', 'a1'], actions.b.b1([0])


