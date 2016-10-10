lo = require 'lodash'

appBase = require './appBase'
data = require './data'
apiActions = require './apiActions'
urlActions = require './urlActions'
dataActions = require './dataActions'

actions = lo.merge apiActions, urlActions, dataActions

appBase.initialize(data, actions)

module.exports = appBase
