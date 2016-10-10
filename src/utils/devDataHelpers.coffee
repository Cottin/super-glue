{all, curry, fromPairs, functions, keys, map, merge, test, type, values, where} = require 'ramda'  #auto_require:ramda
{cc} = require 'ramda-extras'
{ajax} = require 'jquery'

#:: s -> s
ensureDataPrefix = (s) -> if test(/^data_/, s) then s else 'data_' + s

#:: o, s -> [s, f]
nameToPair = curry (app, name) -> [name, -> loadData(app, name)]

#:: o, [s] -> {s: f}
toFunctionMap = (app, xs) -> cc fromPairs, map(nameToPair(app)), xs

# makes xhr to load a given data by name and sets the app's data to what's loaded
loadData = (app, name) ->
	ajax
		type: 'GET'
		url: "http://localhost:3001/dev/data/#{ensureDataPrefix(name)}"
		success: (data) => app.set '', data
		error: (xhr) -> console.log "Failed loading data with name:#{name}"

# Makes a xhr to get all saved data and creates a map where keys are names of saved data
# and values are functions without arguments that calls loadData.
# It also sets the savedData of app to this map of functions, merged with itself (refresh)
refresh = (app, apiUrl) -> ->
	ajax
		type: 'GET'
		url: apiUrl
		success: (data) => app.savedData = merge toFunctionMap(app, data), {refresh:refresh(app)}
		error: (xhr) -> console.log 'Failed loading data'

# makes an xhr to save the app's current data with a name
saveData = (app, apiUrl) -> (name, shouldOverwrite) ->
	# console.log 'saveData', name, JSON.stringify(app.data)
	ajax
		type: 'PUT'
		url: "#{apiUrl}#{ensureDataPrefix(name)}" + if shouldOverwrite then '?shouldOverwrite=true' else ''
		contentType: 'application/json'
		data: JSON.stringify app.data
		error: (xhr) ->
			console.log "Failed posting data to devData. Maybe its not started or
			maybe a file with that name already exists (use shouldOverwrite flag)"

# JSON.stringify 'swallows' undefined and we want to see that in dev data
_replacer = (k, v) -> if v == undefined then 'UNDEFINED' else v

saveDevData = (apiUrl, data, name, shouldOverwrite) ->
	ajax
		type: 'PUT'
		url: "#{apiUrl}#{name}" + if shouldOverwrite then '?shouldOverwrite=true' else ''
		contentType: 'application/json'
		data: JSON.stringify data, _replacer
		error: (xhr) ->
			console.log "Failed posting data to devData. Maybe its not started or
			maybe a file with that name already exists (use shouldOverwrite flag)"

module.exports = {refresh, saveData, saveDevData}
