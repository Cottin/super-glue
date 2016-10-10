React = require 'react'
Radium = require 'radium'
{dissoc, merge} = require 'ramda' #auto_require:ramda
{div, span, a, br, button} = React.DOM

app = require '../base/app'
{build, connect, pending, succeeded, resetAction} = app.uiHelpers
{Employee} = require '../../../shared/models'
{Link, utils} = require 'yun'
{navigate, adjustUrl} = utils.url
{shape, number, string, bool, func} = React.PropTypes
EmployeeReadView = require './EmployeeReadView'
EmployeeEditView = require './EmployeeEditView'

EmployeeDetailsView = React.createClass
	displayName: 'EmployeeDetailsView'

	propTypes:
		employee: shape
			id: number
			firstname: string
			lastname: string
		isEditing: bool
		updateEmployee: func

	componentWillMount: ->
		resetAction @props.updateEmployee

	render: ->
		{employee, isEditing, updateEmployee} = @props
		div {},
			if ! employee
				div {}, 'No employee selected'
			else if isEditing
				div {},
					build EmployeeEditView, {employee, onSave:@onSave, onCancel:@onCancel}
					if pending updateEmployee then div {}, 'Sparar...'
			else
				div {},
					build EmployeeReadView, {employee}
					build Link, {queryF: merge(edit:true)}, 'Edit'

			br()
			build Link, {url: '/'}, 'Back to list'

	onSave: (e) ->
		@props.updateEmployee(e).then ->
			navigate adjustUrl {queryF: dissoc('edit')}

	onCancel: ->
		navigate adjustUrl {queryF: dissoc('edit')}


EmployeeDetailsView.default = connect EmployeeDetailsView, 'EmployeeDetailsViewDefault', (data, actions) ->
	isEditing: data.url.query.edit
	updateEmployee: actions.employees.update

module.exports = EmployeeDetailsView
