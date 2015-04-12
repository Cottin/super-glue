{utils} = siu = require 'siu'
{LocalStorage} = utils
config = require '../../config'

# ----------------------------------------------------------------------------------------------------------
# AUTH - cookies from server might/should be httpOnly, we need one more that can be read from js to keep track
# ----------------------------------------------------------------------------------------------------------
appHelpers = (app) ->
	AUTH_KEY = config.authCookie
	loginSuccess = (data) ->

		document.cookie = "#{AUTH_KEY}=1"
		LocalStorage.setObject AUTH_KEY, data
		app.forceUpdate()

	_removeAuth = ->
		LocalStorage.removeObject AUTH_KEY
		document.cookie = "#{AUTH_KEY}=; expires=Thu, 01 Jan 1970 00:00:00 UTC"
		console.log 'about to clear auth'
		app.objects.auth.clear()
		app.forceUpdate()

	loginError = logoutSuccess = logoutError = selfError = _removeAuth

	return {loginSuccess, loginError, logoutSuccess, logoutError, selfError}

module.exports = appHelpers
