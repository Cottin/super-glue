
User =
	fullName: (x) -> "#{x?.firstname} #{x?.lastname}"

Employee =
	fullName: (x) -> "#{x?.firstname} #{x?.lastname} 2222"
	default: -> { id: 0, firstName: '', lastName: '', email: '' }

module.exports = {User, Employee}
