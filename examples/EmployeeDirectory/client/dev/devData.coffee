data = 
	auth:
		self: state: 'success'
		value:
			id: 1
			firstName: 'Anna'
			lastName: 'Svensson'
			email: 'anna@ab.se'
			password: '123'
	employees:
		getAll: state: 'success'
		value: [
			{
				id: 1
				firstName: 'Anna'
				lastName: 'Svensson'
				email: 'anna@ab.se'
				password: '123'
			}
			{
				id: 2
				firstName: 'Wai'
				lastName: 'Lu'
				email: 'wai@ab.se'
				password: '123'
			}
			{
				id: 3
				firstName: 'John'
				lastName: 'Doe'
				email: 'john@ab.se'
				password: '123'
			}
			{
				id: 4
				firstName: 'Raoul'
				lastName: 'Nzali'
				email: 'raoul@ab.se'
				password: '123'
			}
			{
				id: 5
				firstName: 'Lukasz'
				lastName: 'Ludkiewich'
				email: 'lukasz@ab.se'
				password: '123'
			}
			{
				id: 6
				firstName: 'Mélodie'
				lastName: 'Foret'
				email: 'melodie@ab.se'
				password: '123'
			}
			{
				id: 7
				firstName: 'Salvador'
				lastName: 'Alba'
				email: 'salvador@ab.se'
				password: '123'
			}
			{
				id: 8
				firstName: 'Miko'
				lastName: 'Hattori'
				email: 'miko@ab.se'
				password: '123'
			}
		]
	dontTransactBefore: 1427231683053

module.exports = data