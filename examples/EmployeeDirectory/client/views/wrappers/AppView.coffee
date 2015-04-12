React = require 'react/addons'
Router = require 'react-router'
app = require '../../base/app'
DevDataRefresherView = React.createFactory require('./DevDataRefresherView')
elements = require '../components/elements'
{RootViewMixin} = siu = require 'siu'

RouteHandler = React.createFactory Router.RouteHandler
{ div } = elements

module.exports = React.createClass
	displayName:  'AppView'

	mixins: [RootViewMixin]

	render: ->
		div {className: 'app-view'},
			DevDataRefresherView {}
			RouteHandler {}
