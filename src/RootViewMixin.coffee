app = require './app'
moment = require 'moment'

RootViewMixin =
	componentWillMount: ->
		app.rootComponent = this

	componentWillUpdate: (nextProps, nextState) ->
		@timestampWillUpdate = moment().unix()

	componentDidUpdate: (prevProps, prevState) ->
		diff = moment().unix() - @timestampWillUpdate
		console.info "RENDER FINISHED in #{diff} millis"

module.exports = RootViewMixin
