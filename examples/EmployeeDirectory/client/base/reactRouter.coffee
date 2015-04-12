React = require 'react/addons'
Router = require 'react-router'

Route = React.createFactory Router.Route
DefaultRoute = React.createFactory Router.DefaultRoute
NotFoundRoute = React.createFactory Router.NotFoundRoute

AppView = require '../views/wrappers/AppView'
AuthenticatedView = require '../views/wrappers/AuthenticatedView'

NotFoundView = require '../views/pages/NotFoundView'
LoginView = require '../views/pages/LoginView'
EmployeeView = require '../views/pages/EmployeeView'

routes =
	[
		Route { path: '/', handler: AppView },
			Route { name: 'login', handler: LoginView, key: 'LoginView' }
			Route { path: '/', handler: AuthenticatedView },
				Route { name: 'employee', handler: EmployeeView }
			# 	Route
			# 		name: 'presence'
			# 		handler: PresenceListView
			# 		key: 'PresenceListView'
			NotFoundRoute
				handler: NotFoundView
				key: 'NotFoundView'
	]

window.routes = routes

module.exports =
	initialize: ->
		Router.run routes, Router.HistoryLocation, (Handler) ->
			React.render React.createElement(Handler), document.getElementById 'app-container'

