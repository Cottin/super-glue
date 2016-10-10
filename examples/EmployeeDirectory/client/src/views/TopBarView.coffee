React = require 'react'
Radium = require 'radium'
{} = require 'ramda' #auto_require:ramda
{div, span, a, br} = React.DOM
{shape, number, string, func} = React.PropTypes
{pathOr, isa} = require 'ramda-extras'

{Employee} = require '../../../shared/models'
app = require '../base/app'
{build, connect} = app.uiHelpers

TopBarView = React.createClass
	displayName: 'TopBarView'

	propTypes:
		employee: shape
			id: number
			firstname: string
			lastname: string
		logout: func

	render: ->
		{employee} = @props
		div {},
			div {}, "Welcome, #{Employee.fullName employee}"
			a {href:'/', onClick:@logout}, 'Logout'

	logout: (e) ->
		e.preventDefault()
		@props.logout()


TopBarView.default = connect TopBarView, 'TopBarViewDefault', (data, actions) ->
	employee: data.auth
	logout: actions.auth.logout

module.exports = TopBarView





# TopBarView.default = React.createClass
# 	displayName: 'TopBarView'

# 	getDefaultProps: ->
# 		logout = -> app.actions.auth.logout({_caller:logout.caller})

# 		employee: app.dataPaths.auth
# 		logout: logout

# 	render: -> build TopBarView, @props
