React = require 'react'
{assoc, createMapEntry, merge, props, type} = require 'ramda' #auto_require:ramda
{h1, pre, div, input} = React.DOM

app = require '../base/app'
{build} = app.uiHelpers

# TODO: move to some kind of utils?
enhanceValueSynced = (valueSynced) ->
	if !valueSynced then return null
	[k, comp] = valueSynced
	setter = (e) -> comp.setState createMapEntry(k, e.target.value)
	{value: comp.state[k], onChange: setter}

enhanceElement = (element) -> (props, children) ->
	{valueSynced} = props
	enhancedProps = merge props, enhanceValueSynced(valueSynced)
	element enhancedProps, children

input = enhanceElement input


{func} = React.PropTypes

LoginView = React.createClass
	displayName: 'LoginView'

	propTypes:
		login: func

	getInitialState: ->
		email: 'anna@ab.se'
		password: '123'

	render: ->
		{login} = @props
		{email, password} = @state
		div {},
			div 'Login view'
			input {type:'text', placeholder:'username', valueSynced:['email', @]}
			input {type:'text', placeholder:'password', valueSynced:['password', @]}
			input {type:'button', defaultValue:'Login', onClick:->login({email, password})}
			# if pending login then	span 'Wait...'
			# else if failed login then span 'Error!'

LoginView.default = React.createClass
	displayName: 'LoginViewDefault'

	getDefaultProps: ->
		login: `function myFn(o) {
			app.actions.auth.login(assoc('_caller', myFn.caller, o));
		}`
		# login: `function myFn(o) {
		# 	console.log('o', o);
		# 	debugger
		# 	f = function(o) { return assoc('_caller', myFn.caller, o); };
		# 	cc(app.actions.auth.login, f, o); }`
		# login: (o) ->
		# 	debugger
		# 	

	render: -> build LoginView, @props


module.exports = LoginView
