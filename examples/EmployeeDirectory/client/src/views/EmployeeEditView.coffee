React = require 'react'
Radium = require 'radium'
{chain, dissoc} = require 'ramda' #auto_require:ramda
{div, span, a, br, button, input} = React.DOM

app = require '../base/app'
{build, connect} = app.uiHelpers
{Employee} = require '../../../shared/models'
{Link, utils} = require 'yun'
{shape, number, string, bool, func} = React.PropTypes

EmployeeEditView = React.createClass
	displayName: 'EmployeeEditView'

	propTypes:
		employee: shape
			id: number
			firstname: string
			lastname: string
		onSave: func
		onCancel: func

	getInitialState: ->
		employee: @props.employee

	render: ->
		{employee} = @state
		div {},
			if ! employee
				div {}, 'No employee selected'
			else 
				div {},
					div {},
						span {}, 'id: '
						span {}, employee.id
					div {},
						span {}, 'firstname: '
						input {value: employee.firstname, onChange:@onChangeFirstname}
					div {},
						span {}, 'lastname: '
						input {value: employee.lastname, onChange:@onChangeLastname}
					a {onClick:@onCancel}, 'Cancel'
					a {onClick:@onSave}, 'Save'

	onChangeFirstname: (e) -> utils.react.mergeState @, {employee: {firstname: e.target.value}}
	onChangeLastname: (e) -> utils.react.mergeState @, {employee: {lastname: e.target.value}}
	onCancel: -> @props.onCancel?()
	onSave: -> @props.onSave @state.employee

# EmployeeEditView.default = connect EmployeeEditView, 'EmployeeEditViewDefault', (data, actions) ->
# 	onSave: chain actions.employees.update, -> navigate adjustUrl {queryF: dissoc('edit')}
# 	onCancel: navigate adjustUrl {queryF: dissoc('edit')}

module.exports = EmployeeEditView
