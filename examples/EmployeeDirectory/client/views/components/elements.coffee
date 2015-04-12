# originally stolen from https://github.com/kalasjocke/react-coffee-elements
React = require 'react'
R = require 'ramda'


{apply, props, has, keys, merge} = R #auto_require:funp

build = (tag) ->
	(options...) ->
		if options[0]['_isReactElement'] or options[0].constructor isnt Object
			options.unshift {}


		# shortcut using stateCursors for
		# { value:@state.myState1, onChange:(e)->@setState {myState1: e.target.value} }
		props = options[0]
		if has 'valueSynced', props
			stateCursor = props.valueSynced
			setter = (e) -> stateCursor.set e.target.value
			options[0] = merge props, {value: stateCursor.value(), onChange: setter}

		React.DOM[tag].apply this, options

module.exports = (->
	object = {}
	for element in Object.keys(React.DOM)
		object[element] = build element
	object
)()
