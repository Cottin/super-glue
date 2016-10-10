React = require 'react'
Radium = require 'radium'
{} = require 'ramda' #auto_require:ramda
{div, span, a, br, button} = React.DOM

app = require '../base/app'
{build, connect} = app.uiHelpers
{Employee} = require '../../../shared/models'
{Link} = require 'yun'
{shape, number, string, bool} = React.PropTypes

EmployeeReadView = React.createClass
	displayName: 'EmployeeReadView'

	propTypes:
		employee: shape
			id: number
			firstname: string
			lastname: string

	render: ->
		{employee} = @props
		div {},
			if ! employee
				div {}, 'No employee selected'
			else 
				div {},
					div {},
						span {}, 'id: '
						span {}, employee.id
					div {},
						span {}, 'name: '
						span {}, Employee.fullName(employee)

module.exports = EmployeeReadView
