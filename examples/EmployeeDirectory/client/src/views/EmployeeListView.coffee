React = require 'react'
Radium = require 'radium'
{map} = require 'ramda' #auto_require:ramda
{div, a} = React.DOM
{arrayOf, object, func} = React.PropTypes
app = require '../base/app'
{build, connect, isEmptyish, pending, failed, succeeded} = app.uiHelpers

EmployeeItemView = require './EmployeeItemView'

EmployeeListView = React.createClass
	displayName: 'EmployeeListView'

	propTypes:
		employees: arrayOf(object)
		getEmployees: func

	componentDidMount: ->
		@props.getEmployees()

	render: ->
		{employees, getEmployees} = @props
		div {},
			if pending getEmployees
				div {}, 'Loading employees...'
			else if failed getEmployees
				div {}, 'Failed in loading employees'
			else div {}, ' .'

			if isEmptyish employees
				div {}, 'No employees'
			else
				map @_renderEmployeeItem, employees

	_renderEmployeeItem: (employee) ->
		build EmployeeItemView, {employee, key:employee.id}

EmployeeListView.default = connect EmployeeListView, 'EmployeeListViewDefault', (data, actions) ->
	employees: data.employees
	getEmployees: actions.employees.get

module.exports = EmployeeListView
