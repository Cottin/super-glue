React = require 'react/addons'
app = require '../../base/app'
{SidewaysDataMixin} = siu = require 'siu'
{User} = models = require '../../../shared/models'
{ Navigation } = Router = require 'react-router'
RouteHandler = React.createFactory Router.RouteHandler
{ div } = elements = require '../components/elements'

module.exports = React.createClass
	displayName:	'AuthenticatedView'
	mixins: [SidewaysDataMixin, Navigation]
	statics:
		willTransitionTo: (transition) ->
			if !app.isAuthenticated()
				transition.redirect '/login', {}, 'nextPath': transition.path

	###### DEPENDENCIES
	objects:
		auth: app.objects.auth

	###### LIFE CYCLE
	componentDidMount: ->
		@objects.auth.self()

	componentWillUpdate: ->
		if !app.isAuthenticated() then @transitionTo '/login'

	render: ->
		div {},
			if ! @objects.auth.value()
				if Req.isWaiting @objects.auth.self
					div 'Getting user from server...'
				else
					div 'You were signed in but your user data is gone, will try to get data from server.'
			else
				div "Signed in as #{User.fullName @objects.auth}",
				RouteHandler {}
