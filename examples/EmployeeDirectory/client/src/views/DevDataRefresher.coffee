React = require 'react/addons'
app = require '../base/app'
data_live = require '../dev/data_live'
# data_live = {}
{ span } = React.DOM

module.exports = React.createClass
	displayName: 'DevDataRefresher'

	# componentWillMount: ->
	# 	# console.log 'devref will mount'
	# 	@handleDevData(true)
	componentWillUpdate: (nextProps, nextState) ->
		# console.log 'devDataRefresher componentWillUpdate'
		@handleDevData()

	render: -> null

	handleDevData: (isInitial) ->
		data = data_live
		if @_lastDevData == data then return

		# console.log 'refresher', 'dontTransactBefore:', moment.unix(data.dontTransactBefore).format(), 'now', moment().format()
		# if isInitial
		# 	# console.log 'INITIAL SET FROM DEV DATA REFRESHER!!!'
		# 	app.set '', data

		# else if !data.dontTransactBefore || data.dontTransactBefore < moment().unix()
		# 	# console.log 'UPDATED FROM DEV DATA REFRESHER!!!'
		# 	app.set null, data
		if @_lastDevData && @_lastDevData.dontTransactBefore
			if @_lastDevData.dontTransactBefore == data.dontTransactBefore
				app.set null, data

		@_lastDevData = data


