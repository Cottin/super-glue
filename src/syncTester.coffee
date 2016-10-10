test = ->
	actions.getUser('1234')
	deepEqF data.actions.getUser, {status: 'waiting'}
	deepEqF data.actions.getUser, {status: 'success'}


# - Which syntax is the nicest? ({expect: etc. tycker jag})
# - Implement toMatch, toBe, toEqual, etc. to simplicity of reading and writing
# - {actions} in this case is wrapped to actions.api.employee.get('1234')
#		returns -> actions.api.employee.get('1234')
# - Make sure you can cmd + shift + enter to eval/run the test immediatly.
#		Good since you can easy view data_live to see what state you're in



{actions, data, stepText, group} = app.stepTest

group 'Check employee',

	stepTest 'should handle simple case',
		{setup: normalSetup}
		{do: actions.api.employee.get('1234')}
		{expect: data.ui.serverSync.employee.get, toMatch: {state: "waiting"}}
		{expect: data.ui.serverSync.employee.get, toMatch: {state: "success"}}
		{expect: data.employee, toMatch: {persId: 22599}}

	stepTest 'should handle simple case',
		{do: actions.api.employee.get('1234')}
		{expect: data.ui.serverSync.employee.get, toMatch: {state: "waiting"}}
		{expect: data.ui.serverSync.employee.get, toMatch: {state: "success"}}
		{expect: data.employee, toMatch: {persId: 22599}}


describe 'Check employee', ->
	it 'should handle simple case', stepTest
		.do(actions.api.employee(1048).get())
		.expect(data.ui.serverSync.employee.get).to.equal({state: "waiting"})
		.expect(data.ui.serverSync.employee.get).to.match({state: "success"})
		.expect(data.employee).to.match({persId: 22599})

