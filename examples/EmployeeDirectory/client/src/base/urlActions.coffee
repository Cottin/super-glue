{compose, createMapEntry, dissoc, flatten, merge, remove, update, wrap} = require 'ramda' #auto_require:ramda
xhr = require '../helpers/xhr'
appBase = require('./appBase')
data = require './data'
yun = require 'yun'
{set, unset, setPath, setById, getPathById, fail, get, post, put, del, action, buildActions} = appBase.actionHelpers xhr

loginError = (o) ->
	console.log 'TODO: loginError'
	return o
logoutError = (o) ->
	console.log 'TODO: logoutError'
	return o

# loginSuccess = (data) ->
# 	document.cookie = "#{AUTH_KEY}=1"
# 	app.cursors.auth.set data
# 	# LocalStorage.setObject AUTH_KEY, data   # not in use yet
# 	app.forceUpdate()

# 	# LocalStorage.removeObject AUTH_KEY     # not in use yet
# 	# document.cookie = "#{AUTH_KEY}=; expires=Thu, 01 Jan 1970 00:00:00 UTC"
# 	# console.log 'about to clear auth'
# 	# app.cursors.auth.clear()
# 	# app.forceUpdate()

# error401 = loginError = logoutSuccess = logoutError = selfError = _removeAuth

LOG_ACTION_STEPS = true

# actions = (app) ->
	# {set, unset, fail, get, post, put, del, action, buildActions} = app.actionHelpers xhr
a = (fs...) -> flatten fs
# _post = post
# _get = get
# get = wrap get, (g, arg) ->
# 	fail(error401)(g(arg))





error401 = ->
	app.set 'auth', null

resetData = -> setPath('', data)

query = compose yun.utils.url.adjustUrl, createMapEntry('queryF')

actionDeclarations =
	employees:
		show: a query, merge, ({id}) -> {employee: id}
		startEdit: a query, merge, ({id}) -> {employee: id, edit: true}
		stopEdit: a query, dissoc, -> 'edit'

actions = buildActions actionDeclarations, LOG_ACTION_STEPS
module.exports = actions






	# employees:
	# 	getAll: a set, get, -> 'employee'
	# 	update: a setById, put, (employee) -> ["employee/#{id}", employee]
	# 	remove: a unsetById, del, (id) -> "employee/#{id}"

	# newEmployee:
	# 	create: a set, 'Employee.new()TODO'
	# 	save: a setTo({}), assocById('employee'), post, (employee) -> ['employee', employee]

	# auth: object null,
	# 	login: a loginSuccess, fail(loginError), post, (email, password) -> ['auth/login', {email, pass}]
	# 	logout: a logoutSuccess, fail(logoutError), get, -> 'auth/logout'
	# 	self: a selfSuccess, fail(selfError), get, -> 'self'
# setAuthCookie = unsetAuthCookie = a = set = get = setById = put = unsetById = del = setTo = assocById = post = -> null




	# fa = (o) ->
	# 	console.log 'fa', o
	# 	o

	# fb = (o) ->
	# 	console.log 'fb', o
	# 	o

	# fc = (o) ->
	# 	console.log 'fc', o
	# 	o
