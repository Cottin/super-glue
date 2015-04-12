React = require 'react/addons'
{Navigation, State} = Router = require('react-router')
{Req, SidewaysDataMixin} = siu = require 'siu'
app = require '../../base/app'
{div, input, textarea, span} = elements = require '../components/elements'

module.exports = React.createClass
	displayName:  'LoginView'
	mixins: [SidewaysDataMixin, Navigation, State]
	statics:
		willTransitionTo: (transition) ->
			if app.isAuthenticated() then transition.redirect '/'

	###### DEPENDENCIES
	objects:
		auth: app.objects.auth

	###### LIFE CYCLE
	getInitialState: -> {email:'', password:''}
	componentWillUpdate: -> if app.isAuthenticated() then @redirect()

	###### HANDLERS
	redirect: -> @transitionTo @getQuery().nextPath || '/'
	onSubmit: -> @objects.auth.login(@state.email, @state.password)


	render: ->
		div {},
			div 'Login view'
			# textarea {value:JSON.stringify(@state), cols: 80, rows: 5}
			input {type:'text', placeholder:'username', valueSynced:@stateCursors.email}
			input {type:'text', placeholder:'password', valueSynced:@stateCursors.password}
			input {type:'button', defaultValue:'Login', onClick:@onSubmit}
			if Req.isWaiting @objects.auth.login
				span 'Wait...'
			else if Req.hasError @objects.auth.login
				span 'Error!'


