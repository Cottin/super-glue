R = require 'ramda'

{compose, substringTo} = R # auto_require:funp

# ----------------------------------------------------------------------------------------------------------
# LOGGING
# ----------------------------------------------------------------------------------------------------------
_lastInfoGroup = 0
infoGroup = (msg, data) ->
	# now = new Date().getTime()
	# if _lastInfoGroup + 2000 < now
	# 	console.log '--------------------------'
	# _lastInfoGroup = now
	sub = compose(substringTo(50), JSON.stringify)
	console.groupCollapsed("#{msg} :: #{sub(data)}")
	console.info data
	console.groupEnd()

# ----------------------------------------------------------------------------------------------------------
# BROWSER
# ----------------------------------------------------------------------------------------------------------
LocalStorage =
	setObject: (k, v) -> localStorage?.setItem k, JSON.stringify(v)
	getObject: (k) ->
		value = localStorage?.getItem k
		value && JSON.parse value
	removeObject: (k) -> localStorage?.removeItem k
	clear: -> localStorage?.clear()

module.exports = {
	infoGroup,
	LocalStorage
}
