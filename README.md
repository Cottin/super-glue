- CQRS: essentially means split reads and writes and is a good idea (Jessica Kerr - Keynote, ElixirConf 2015)
- Event sourcing: Elm, Redux (Jessica Kerr - Keynote, ElixirConf 2015)
- The problem I see with event sourcing: hard to draw since there are much more actions in a system than types of data
- 


The core of an super-glue application is made up of many small pure functions and a Parser. These functions can fall into one of 4 types:

# Lifters
Pure functions that take as input normalized data and/or other denormalized data and returns as output denormalized data.

# Queriers
Pure functions that take as input normalized data and/or denormalized data and returns a query as output. The query is passed to the Parser.queryParser together with the nested path of the querier. In your parser you can do whatever you want with the query and the path but the idea is that you would issue a query to your backend api to get some data, and when that data arrives you do an app.set for the path of the querier with that data.

# Actions
Pure functions that take any arbitrary input that you define and returns as output a query. That query is passed to the Parser.mutationParser function. You can choose what you want to do with the query in your parser function but the idea is that you can issue mutating requests to your backend api or mutate the normalized data or mutate the url or mutate anything else really. The major differance between actions and queriers is that queriers can only take as input normalized and denormalized data and are called automatically. Actions can define any input that you want and they are not called automatically, you need to call an action manually, e.g. when clicking a button.

# Invokers
Pure functions that take as input normalized data and/or denormalized data and returns as output a query. That query gets passed to the Parser.mutationParser. You can choose what to do with the query in your mutationParser but the idea is that you are given a chance to mutate stuff. For instance, if the user goes to the login page but already has an active session, an invoker can produce a url query that in turn mutates the url and sends the user to the main page instead. Invokers behaves like actions but you cannot manually trigger them, they can only be automatically triggered by changes in the normalized or denormalized data. In this aspect, invokers are closer to queriers but they get passed to the mutationParser instead of the queryParser.

# Parser
An object with two functions:

the first one called `queryParser = (query, path) -> ...` taking a query and a path as input.
The query is the result of a querier and the path is the nested path where that querier is defined. You are free to implement this function as you whish but typically you would want to issue a request to your backend api to get some data based on the query. When you get data back, you'd want to do an app.set on the given path with that data.

the second one called `mutationParser = (query) -> ...` taking a query as input.
The query is the result of either an action of an invoker. Again, you can do what you want with that query but typically you'd want to mutate some normalized data, the url or some kind of localStorage. You can also use this to call your backend api with a mutation request such as CREATE, PUT, DELETE if you have a REST-api.






# Anti-pattern: passing actions as props to grand-children.
# The beauty of actions: is that is very easy to follow. If you want to find usage of update
# you ctrl+shift+f for shift.update and see every component that uses it. Look at ScheduleDay.view.js
# which puts together an actions object and passes actions down far the hierarchy, you are completely gone.


# more like om/next relay
# Conclutions from fiddling with this:
# - You don't want an "object box" which supports any modification to the server.
#		It is good having to specify each action you can take (om/next does this too).

# - Declare what actions a component will use at top of component.
#		om/next does not do this but I think it's a misstake, dependencies gets clearer if you do.

# - A static query method with composability makes you not having to pass things down a long chain.
#		At the same time, for small applications this isn't a huge problem. The added complexity of this
#		querying ability is judged not to be worth it for smaller projects. E.g. normal propTypes-
#		definitions are not worth going away from.

# - The sync-state of data should probably be meta-data of the data itself as in EmployeeItemView
#		below. It should probably not be on actions (i.e. pending myAction). However having it on
#		the action is simpler and might support enough use cases for smaller applications.
#		Also, having the meta on the data itself gets tricky for a get request of a collection.

# - The sync-state of a get request for a list colides with the getAndMerge concept.
#		What if one of the items has been removed? If you want to find a solution to this you might
#		need to think a bit more.

# Overall conclusion: for the type of smaller apps I'm building, super-glue seems to be enough.
# Because of it's simplixity it might even be one of the best choices for me.
# Nolen tweeted that for bigger apps flux gets messy, but I'm not building these big apps so no
# need to complicate stuff :)

# data.coffee
employees: {}

# schema
Employee =
	id: int
	name: str
	age: int
	jobs: arr Company

Company =
	id: int
	name: str

# data_live.coffee
employees:
	1:
		id: 1
		name: 'Tao'
		age: 35
		childCount: 0
	2:
		id: 2
		name: 'Lathike'
		age: 34
		childCount: 1
	3:
		id: 3
		name: 'Victor'
		age: 28
		childCount: 0

companies:
	1: {id: 1, name: 'Quinyx', size: 90}
	2: {id: 2, name: 'Capgemini', size: 200000}
	3: {id: 3, name: 'Bonnier', size: 30000}
	4: {id: 4, name: 'Swarm Planet', size: 10}

# actions
employees =
	increaseChildren: a set, put, evolve({childCount: inc}), findById, (id) -> id

# EmployeeListView
query: () ->
	employees:
		subQuery: EmployeeItemView.query.employee

render: () ->
	{employees} = fromQuery this
	map buildFn(EmployeeItemView), employees

# EmployeeItemView
query: ->
	employee:
		fields: ['id', 'age', 'name']

actions:
	increaseChildren: 'employees.increaseChildren'

render: ->
	{employee} = fromQuery this
	div {},
		if updating employee then @renderOverlay() # overlay with spinner blocking edits
		div {}, employee.id
		div {}, employee.name
		div {}, employee.age
		button {onClick: -> @a.increaseChildren(employee.id)}, 'increase children'

# ParentEmployeeListView
query: () ->
	employees:
		subQuery: EmployeeItemView.query.employee
		where: {childCount: {gt: 0}}

render: () ->
	{employees} = fromQuery this
	map buildFn(EmployeeItemView), employees




read = (query) ->
	normalizedQuery = normalizeQuery query
	[localNormalizedData, syncs] = performReads normalizeQuery
	syncStatus = sync syncs
	return {data: denormalize(localNormalizedData, query), syncStatus}

performReads = (normalizedQuery) ->
	f = (v, k) -> reads[k](data, v)
	return mapObjIndex f, normalizedQuery

query1 =
	{employees: {name: 1, age: {gt: 30}, jobs: {name: 1, size: {gt: 1000}}}}
	...
	{employee: {_arity: 'many', name: 1, age: {gt: 30},
		join: {company: {_as: 'jobs', _arity: 'many', name: 1, size: {gt: 1000}}}}}

syncSpec = (history, query) ->
	f = (v, k) -> syncSpecs[k](history, v)
	return mapObjIndex f, query

syncSpecs =
	employee: (syncHistory, data, query) ->
		localData = popsiql.localQuery data, query
		shouldSync = needsSync syncHistory, query

	company: (syncHistory, data, query) ->



endpoints = (app, schema) ->

	Employee = QueryEndpoint 'employees',
		query: (query) ->
			employees: execApiQuery omit(['jobs'], query)
			jobs: if Company.canFullfill query then 
		canFullfill: (query) ->
			lastQuery = find propEq('query', query.toString()), app.queryHistory
			return lastQuery && lastQuery.ts > moment().valueOf() - 5 * 60 * 1000

Company = QueryEndpoint 'companies',
	query: (data, schema, query, onlyQuery) ->

	canFullfill: (data, schema, query, subquery) ->
		return if data.companies then true else false


Employee = QueryEndpoint 'employees', (data, schema, query) ->
	employeesQuery = flattenQuery query.employees
	employees = execLocalQuery data, schema, employeesQuery
	{join} = query || {}
	jobs = if join.jobs then companies data, join.jobs

	return mergeIntoResult query, {employees, jobs}

	refinedQuery = dissocPath ['join', 'jobs'], query
	sync = execApiQuery refinedQuery
	value = mergeQueryResults query, {employees, jobs}
	return {value, sync}

companies = 
	query: (data, schema, query, onlyQuery) ->
		localData = doQuery data, schema, query
		if localData then return {value: localData, sync: 'ok'}

		sync = api.get('/companies')
		return {value:localData, sync}

employee = (data, query) ->



# 1. nested query
# 2. flat query with subqueries
# 3. a combination




reads =













# Super-glue
All the gluecode you'll ever need.

# What?
A library that lets you write front-end appliactions in react in an interactive way with a minimal amount of gluecode.

# How?
 - All app data contained in one value
 - All data and actions defined in one place

# Why?
...

# TODO
- [ ] Clean-up
- [ ] Update examples, they are broken



# Thoughts

## Don't put everything in state with a mixin
In jungle you declare dependencies on the tree in a component. The mixin puts that data in the components state.
This makes it hard to do anything in response to data changes, which you would normally do in componentWillReceiveProps.
E.g.
componentWillReceiveProps: function(nextProps) {
  this.setState({
    likesIncreasing: nextProps.likeCount > this.props.likeCount
  });
}
It's probably better to do the connect approach where the wrapping component set the data as props on the wrapped component.



