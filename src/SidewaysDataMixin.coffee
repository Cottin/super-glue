app = require './app'
helpers = require './helpers'
R = require 'ramda'

{apply, evolve, reduce, mapObjIndexed, prop, values, merge, assoc} = R #auto_require:funp

##### HELPERS
# not needed for current implementation
# toObjectCursor = (_, k) -> prop k, app.objects
# buildObjectCursors = (c) -> mapObjIndexed toObjectCursor, c.objects

buildStateCursors = (c) ->
	setFn = (k) -> (v) -> c.setState assoc(k, v, c.state)
	applyFn = (k) -> (f) -> c.setState evolve(assoc(k, f, {}), c.state)
	valueFn = (k) -> () -> c.state[k]
	toStateCursor = (v, k) -> {set: setFn(k), apply: applyFn(k), value: valueFn(k)}
	return mapObjIndexed toStateCursor, c.state


SidewaysDataMixin =
	componentWillMount: (newProps) ->
		@o = @objects
		@stateCursors = buildStateCursors this

		@c = reduce merge, {}, [@cursors.objects, @cursors.lists, @cursors.values, @cursors.actions]

		# utils
		@syncState = (k) -> (e) => @setState assoc(k, e.target.value, {})
		app.declare.view this

module.exports = SidewaysDataMixin
