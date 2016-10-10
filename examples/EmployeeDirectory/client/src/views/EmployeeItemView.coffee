React = require 'react'
Radium = require 'radium'
{merge} = require 'ramda' #auto_require:ramda
{div, a} = React.DOM
{shape, number, string, func} = React.PropTypes

app = require '../base/app'
{build, connect} = app.uiHelpers
{Employee} = require '../../../shared/models'
{Link} = require 'yun'

EmployeeItemView = React.createClass
	displayName: 'EmployeeItemView'

	propTypes:
		employee: shape
			id: number
			firstname: string
			lastname: string

	render: ->
		{employee, showEmployeeUrl} = @props
		div {},
			build Link, {queryF: merge(employee: employee.id)}, Employee.fullName(employee)

# EmployeeItemView.default = connect EmployeeItemView, 'EmployeeItemViewDefault', (data, actions) ->
# 	showEmployeeUrl: actions.employees.show

module.exports = EmployeeItemView
