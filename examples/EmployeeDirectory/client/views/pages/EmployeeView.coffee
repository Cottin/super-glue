React = require 'react/addons'
{map, length} = require 'ramda' #auto_require:funp
{ div } = elements = require '../components/elements'
{ SidewaysDataMixin, Req } = siu = require 'siu'
{Employee} = models = require '../../../shared/models'
app = require '../../base/app'

employeeListItem = (e) -> div {key: e.id}, Employee.fullName(e)
waitingView = div 'Loading employees...'
errorView = div 'Error while loading employees!'
notLoadedView	= div 'Employees not yet loaded.'
zeroView = div 'No employees found on server'

module.exports = React.createClass
	displayName:  'EmployeeView'

	mixins: [SidewaysDataMixin]

	objects:
		employees: app.objects.employees

	componentDidMount: ->
		if @objects.employees.value() == undefined
			@objects.employees.getAll()

	render: ->
		isWaiting = Req.isWaiting @objects.employees.getAll
		hasError = Req.hasError @objects.employees.getAll
		isNotLoaded = @objects.employees.value() == undefined
		zeroEmployees = length(@objects.employees.value()) == 0
		manyEmployees = length(@objects.employees.value()) > 0
		div {},
			if isWaiting then waitingView
			else if hasError then errorView
			else if isNotLoaded then notLoadedView
			else if zeroEmployees then zeroView
			else if manyEmployees
				map employeeListItem, @objects.employees.value()

