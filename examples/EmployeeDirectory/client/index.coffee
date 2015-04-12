R = require 'ramda'
objects = require './base/objects'
config = require '../config'
app = require './base/app'
React = require 'react/addons'
ramdaExtras = require 'ramda-extras'

{install} = ramdaExtras

install R, window
install {R}, window
install ramdaExtras, window
install {ramdaExtras}, window

install {app}, window
app.initialize
	objects: objects(app)
	apiUrl: config.apiUrl
	authCookie: config.authCookie

# shorthand for objects to use in console
install {oo: app.objects}, window 

# make sure to call app.initialize before requring router
ReactRouter = require './base/ReactRouter'
ReactRouter.initialize()
