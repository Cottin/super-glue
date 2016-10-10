LocalStorage =
	setObject: (k, v) -> localStorage?.setItem k, JSON.stringify(v)
	getObject: (k) ->
		value = localStorage?.getItem k
		value && JSON.parse value
	removeObject: (k) -> localStorage?.removeItem k
	clear: -> localStorage?.clear()

module.exports = {LocalStorage}
