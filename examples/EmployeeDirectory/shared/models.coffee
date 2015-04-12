R = require 'ramda'
ramdaExtras = require 'ramda-extras'


{compose, wrap, mapObj, propOr, defaultTo} = R # auto_require:funp
{isa} = ramdaExtras

User =
	fullName: (x) -> "#{x?.firstName} #{x?.lastName}"

Employee =
	fullName: (x) -> "#{x?.firstName} #{x?.lastName}"


_isCursor = compose isa(Function), propOr(false, 'value'), defaultTo({})
wrap = (f) -> (x) -> if _isCursor x then f x.value() else f x

User = mapObj wrap, User
Employee = mapObj wrap, Employee

module.exports = {User, Employee}
