# siu
A library for building small and simple javascript applications in react.js with a focus on keeping both complexity and lines of code to a minimum. The three main goal is declarative programming, minimizing glue-code and making your experience developing a front-end application super-duper fun.

# How does it work?
Siu brings you 5 concepts that greately simlifies the architecture of your front-end application.


# TODO
- dealing with nested objects
- byt namn till super-glue?
- link to hacker news where they dissucss om
- link to hacker news where they dissucss immutable-js and react
- link to my question on stackoverflow
- upgrade to react 0.13 and react-router 0.13


## 1. One value containing all app data
I got this concept from David Nolen's excellent library Om. (Links to other framework with similar approaches)

*Benefits:* 
	- Great dev-time interaction such as app.saveState('bug_in_edgecase'), app.loadStates().bug_in_edgecase(), app.loadStates().bug_that_customer_reported(), app.undo(), app.redo().
	- The simplicity of thinking of your app as a pure function taking the app-data as input and returning a ui as output.
	- The ability to interact with the current state of your running application in your favorite editor. Any changes made will trigger a transaction in your application running in your browser using react-hot-loader.
	- The simplicity of modelling your application data as normalized (link to prismatic blog post).

## 2. Single dispatcher
As popularized in the react community by Flux this concept brings some nice advantages.

*Benefits:* 
	- logging

## 3. Data and actions combined into an action router
This is somewhat a combination of stores in Flux which contains data and actions and cursors found in Om.

*Benefits:* 
	- simplicity and readability

## 4. AppViewMixin

*Benefits:* 
	- Sideways data loading in your react components. (link to sideways data loading on react github).

## 5. Ramda and immutability??


## Q & A

### How does siu compare to Flux?

### How does siu compare to Om?

### Is it fast? Does it scale?















---- deprecated stuff:


AppView
--------
React = require 'react/addons'
moment = require 'moment'
Router = require 'react-router'
app = require './app'
DevDataRefresherView = require './DevDataRefresherView'
elements = require './elements'

{ RouteHandler } = Router

{ div } = elements

module.exports = React.createClass
	displayName:  'AppView'

	componentWillMount: ->
		app.rootComponent = this

	componentWillUpdate: (nextProps, nextState) ->
		@timestampWillUpdate = moment().unix()

	componentDidUpdate: (prevProps, prevState) ->
		diff = moment().unix() - @timestampWillUpdate
		console.info "RENDER FINISHED in #{diff} millis"

	changeAppState: (data) ->
		app.transact.set '', data, 'devData', false

	render: ->
		div {className: 'app-view'},
			DevDataRefresherView {onDevDataChanged: @changeAppState}
			RouteHandler {}






DevDataRefresherView
--------------------
# This is a special view to enable interation with the global app state from the editor. When devData.coffee changes on
# disk it will be reloaded. This is the only component who should have a dependency on devData. This component is
# responsible for triggering an event to reload the entire app state.


React = require 'react/addons'
moment = require 'moment'
app = require './app'
elements = require './elements'

# TOGO!!! Gör detta med alias! http://webpack.github.io/docs/configuration.html#automatically-created-contexts-defaults-module-xxxcontextxxx
devData = require 'siu_devData'



{ span } = elements

module.exports = React.createClass

	displayName: 'DevDataRefresherView'

	PropTypes:
		onDevDataChanged: React.PropTypes.func

	lastDevData: null

	componentDidMount: ->

		dontTransactBefore = devData.dontTransactBefore
		@lastDevData = devData
		if moment().isAfter moment(dontTransactBefore), 'second'
			@devDataChanged devData

	componentWillUpdate: (nextProps, nextState) ->
		dontTransactBefore = devData.dontTransactBefore
		if @lastDevData == devData then return

		@lastDevData = devData
		if moment().isAfter moment(dontTransactBefore), 'second'
			@devDataChanged devData

	render: ->
		span {className: 'DevDataRefresherView'}

	devDataChanged: (data) ->
		@props.onDevDataChanged devData









