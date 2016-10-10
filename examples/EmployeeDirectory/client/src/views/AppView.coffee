React = require 'react'
EventListener = require 'react/lib/EventListener'
app = require '../base/app'
{build} = app.uiHelpers
{equals, path} = require 'ramda' #auto_require:ramda
{h1, pre, div, textarea} = React.DOM
{LocalStorage} = require '../helpers/browser'
config = require '../../../config'


DevDataRefresher = React.createFactory require './DevDataRefresher'
EmployeeListView = require('./EmployeeListView').default
EmployeeDetailsView = require('./EmployeeDetailsView').default
LoginView = require('./LoginView').default
TopBarView = require('./TopBarView').default

getQueryString = ->
	result = {}
	queryString = location.search.slice(1)
	re = /([^&=]+)=([^&]*)/g
	m = undefined
	while m = re.exec(queryString)
		v = decodeURIComponent(m[2])

		value = switch
			when v == 'true' then true
			when v == 'false' then false
			else v

		result[decodeURIComponent(m[1])] = value
	result


AppView = React.createClass
	displayName: 'AppView'

	componentWillMount: ->
		console.log 'load 4'
		@setState {data: {url: {query: {}}}}

		app.renderHook = (data) =>
			@setState {data: data}
		app.setHook = (path, value, fullData) ->
			if path == '' || path == null
				url = {query: getQueryString()}
				app.set('url', url)
			else if equals path, ['auth']
				LocalStorage.setObject 'auth', value

			# if path == 'url'
			# {employee, edit} = fullData.url.query
			# if employee && edit
			# 	app.set 'employeeToEdit', 

		if (config.useDevData)
			data_live = require '../dev/data_live'
			# this makes things too complext. Skip? At least for now!
			# console.log 'Setting initial data from data_live.coffee'
			# if data_live && data_live.auth
			# 	app.actions.auth.mock data_live.auth
			app.set null, data_live
		else
			authFromLocalStorage = LocalStorage.getObject 'auth'
			if authFromLocalStorage
				app.set 'auth', authFromLocalStorage

				
		EventListener.listen window, 'popstate', ->
			url = {query: getQueryString()}
			app.set('url', url)
			return true




	render: ->
		{employees, auth, url: {query}} = @state.data
		div {},
			if config.useDevData
				DevDataRefresher()
			if !auth then build LoginView
			else
				div {},
					textarea {}
					build TopBarView
					h1 {}, '.' #Employee Directory 333333'
					if query.employee
						if employees
							@_renderEmployeeDetails employees[query.employee]
					else
						build EmployeeListView

	_renderEmployeeDetails: (employee) ->
		build EmployeeDetailsView, {employee}





module.exports = AppView
