data =
	url:
		query:
			edit: null
			employee: null
	auth: null
	employees: []
	employeeToEdit: null

module.exports = data
# #:: action -> [str]
# actionPath = ({path, name}) -> flatten ['actions', path, name]
# actionStatePath = ({path, name}) -> flatten ['actions', path, name, 'state']
# actionState = (action) -> path app.data, actionStatePath(action)

# #:: action -> bool
# pending = compose pathEq(__, 'pending', app.data), actionStatePath
# failed = compose pathEq(__, 'error', app.data), actionStatePath
# succeeded = compose pathEq(__, 'success', app.data), actionStatePath

# #### "Singleton" endpoints - max one request can go through at a time, and they set their own state in the global data
# #:: str -> Thenable(any)
# get = (url) -> _xhr {method: 'get'}, 'get', url
# del = (url) -> _xhr {method: 'delete'}, 'del', url
# #:: [str, any] -> Thenable(any)
# post = ([url, data]) -> _xhr {method: 'post', data: JSON.stringify(data)}, 'post', url
# put = ([url, data]) -> _xhr {method: 'put', data: JSON.stringify(data)}, 'put', url


# #### "Normal" endpoints - just makes the request an does not set any state in the global data
# mget = mpost = mput = mdel = -> throw new Error 'not yet implemented'

# ######### ACTION
# action = (fs..., f) ->
# 	wrapper = (f, args...) ->
# 		composition = composeP2 fs..., f
# 		return composition args...
# 	return wrapKeepSignature f, wrapper
