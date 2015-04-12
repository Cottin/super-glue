React = require 'react/addons'
{ div } = elements = require '../components/elements'

module.exports = React.createClass
	displayName:  'NotFoundView'

	render: ->
		div {className: 'app-view'},
			div 'Page not found'
