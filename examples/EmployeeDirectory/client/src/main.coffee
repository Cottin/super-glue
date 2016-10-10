React = require 'react'
AppView = React.createFactory require('./views/AppView')
app = require './base/app'
data = require './base/data'

{forEach, keys} = R = require 'ramda'

install = (o, target) ->
	addKey = (k) -> target[k] = o[k]
	forEach addKey, keys o

originalIsNaN = window.isNaN
install {R}, window
install R, window
window.isNaN = originalIsNaN

ramdaExtras = require 'ramda-extras'
install {ramdaExtras}, window
install ramdaExtras, window

moment = require 'moment'
install {moment}, window

install {app}, window
install {app}, document
install {data}, window

React.render AppView(), document.getElementById('root')
