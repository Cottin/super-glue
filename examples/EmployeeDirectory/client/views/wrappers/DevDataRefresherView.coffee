React = require 'react/addons'
app = require '../../base/app'
devData = require '../../dev/devData'
{ span } = elements = require '../components/elements' 

module.exports = React.createClass
	displayName: 'DevDataRefresherView'

	componentDidMount: -> app.handleDevData devData
	componentWillUpdate: (nextProps, nextState) -> app.handleDevData devData

	render: ->
		span {className: 'DevDataRefresherView'}
