config = require '../../config'
{app} = siu = require 'siu' 

# add extentions
app.isAuthenticated = -> document?.cookie?.indexOf("#{config.authCookie}=1") > -1

module.exports = app
