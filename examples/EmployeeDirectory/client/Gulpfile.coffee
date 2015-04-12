gulp = require 'gulp'
gutil = require 'gulp-util'
nodemon = require 'gulp-nodemon'
path = require 'path'

express = require 'express'
webpack = require 'webpack'
portfinder = require 'portfinder'
bodyParser = require 'body-parser'
js2coffee = require 'js2coffee'
fs = require 'fs'
WebpackDevServer = require 'webpack-dev-server'
util = require 'util'
# server = require '../server/server'

servers = []


# ------------------------------------------------------------------------------------------------------
# TASKS
# ------------------------------------------------------------------------------------------------------
dev = ->
	portfinder.basePort = 8080 # for now, webpack-dev-server gives error if not using 8080, config thing?
	portfinder.getPort (err, port) ->
		servers.push webpackDevServer(port), devDataServer(port+9) #, nodeDevServer(port+8)  # +9 is hardcoded for now
		# servers.push nodemonDevServer(port+8)  # +9 is hardcoded for now
		# servers.push webpackDevServer(port)
		# servers.push webpackDevServer(port), nodeDevServer(port+8) 
		# servers.push nodeDevServer(3001)

gulp.task 'default', ['dev']
gulp.task 'dev', dev



# ------------------------------------------------------------------------------------------------------
# SERVERS
# ------------------------------------------------------------------------------------------------------
webpackDevServer = (port) ->
	RHLMatches = /View\.coffee$/
	compiler = webpack({
		entry:
			app: [
				"webpack-dev-server/client?http://localhost:#{port}"	,
				'webpack/hot/only-dev-server',
				'./index.coffee'
			]
		plugins: [
			new webpack.HotModuleReplacementPlugin(),
			new webpack.NoErrorsPlugin()
			# new webpack.DefinePlugin { DEV: true }
		]
		output:
			path: '/build',
			filename: 'bundle.js'
		resolve:
			# fallback: path.join(__dirname, "node_modules")
			extensions: ["", ".web.coffee", ".web.js", ".coffee", ".js"]
			alias:
				siu_devData: path.join(__dirname, './dev/devData')
				# siu: path.join(__dirname, './libs/siu/src/siu')
				# siu: path.join(__dirname, './siu2/siu')
		module:
			loaders: [
				{ test: /\.coffee$/, exclude: RHLMatches, loader: 'coffee-loader' },
				{ test: RHLMatches, loader: 'react-hot!coffee-loader' }
			]
		# devtool: 'eval'
		devtool: 'source-map'	# see if we can manage without this as well, will speed up the build a lot
		debug: true
	})

	new WebpackDevServer(compiler, {
			hot: true
			stats: {
				hash: false
				version: false
				assets: false
				cached: false
				colors: true
			}
			noInfo: true
			historyApiFallback: true
		}).listen port, 'localhost', (err) ->
		if err then throw new gutil.PluginError('webpack-dev-server', err)
		gutil.log '[webpack-dev-server]', "http://localhost:#{port}/webpack-dev-server/index.html"
		# callback(); # keep the server alive or continue?


devDataServer = (port) ->
	app = new express()

	app.all '*', (req, res, next) ->
		res.set 'Access-Control-Allow-Origin', req.headers.origin
		res.set 'Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, Content-Length, Accept, Origin'
		res.set 'Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE'
		res.set 'Access-Control-Allow-Credentials', 'true'
		res.set 'Access-Control-Max-Age', 5184000
		next()

	app.use bodyParser.json()

	app.post '/devData', (req, res) ->
		data = req.body
		sinceEpoch = (new Date()).getTime()
		data.dontTransactBefore = sinceEpoch + 5000

		console.log JSON.stringify(req.body)
		console.log JSON.stringify(req.body)
		console.log util.inspect(req.body, { showHidden: true, depth: null })
		json = JSON.stringify(req.body)
		json.replace /\\"/g, '￿'
		json = json.replace(/\"([^"]+)\":/g, '$1:').replace(/\uFFFF/g, '\"')

		# dataString = util.inspect(req.body, { showHidden: true, depth: null })
		# dataString = JSON.stringify(req.body)
		dataString = json
		dataStringJs = "var data = #{dataString};" 
		dataStringCoffee = js2coffee.build(dataStringJs, {indent: '\t'}).code
		dataStringCoffee += "\nmodule.exports = data"

		fs.writeFile __dirname + '/dev/devData.coffee', dataStringCoffee, (err) ->
			if err then console.log err
			else res.status(200).end()

	app.listen(port);
	console.log "devData listening on port #{port}"

	return app

# nodeDevServer = (port) ->

# 	console.log "about to start node on port #{port}"
# 	# server.start port

# 	nodeServer = server.listen port, ->
# 	  host = nodeServer.address().address
# 	  port = nodeServer.address().port
# 	  console.log 'Example app listening at http://%s:%s', host, port

# 	console.log "started node"

nodemonDevServer = (port) ->

	console.log "about to start nodemon on port #{port}"

	conf = {script: '../server/server.coffee'}
	nodemon(conf).on('change', -> console.log 'change')
    					.on('restart', -> console.log 'restarted!')

	# nodeServer = server.listen port, ->
	#   host = nodeServer.address().address
	#   port = nodeServer.address().port
	#   console.log 'Example app listening at http://%s:%s', host, port

	# console.log "started node"











# deprecation line --------
# # ------------------------------------------------------------------------------------------------------
# # UTILS
# # ------------------------------------------------------------------------------------------------------
# expandPath = (app, appPath) ->
# 	app.use(express.static(appPath))
# 	app.set('views', __dirname + '/' + appPath)
# 	app.engine('html', require('ejs').renderFile)
# 	app.get('*', (req, res, next) ->
# 		url = req.url
# 		isFile = url.substring(url.lastIndexOf('/') + 1).indexOf('.') > -1	# the last section after '/' contains a dot, assume it has a file ending

# 		if isFile
# 			next()
# 		else
# 			res.render('index.html')

# 	)




# DevServer = (port, appPath) ->
# 	devConfigParams = {}
# 	devConfigParams.entry = {
# 		app: [
# 			'webpack-dev-server/client?http://localhost:'+port,
# 			'webpack/hot/dev-server',
# 			'./index.coffee'
# 		]
# 	}

# 	devConfigParams.plugins = [
# 		new webpack.HotModuleReplacementPlugin(),
# 		new webpack.DefinePlugin({
# 			DEV: true
# 		})
# 	]

# 	devConfigParams.output = {
# 		path: 'build',
# 		filename: 'bundle.js'
# 	}

# 	devConfigParams.resolve = {
# 		extensions: ["", ".web.coffee", ".web.js", ".coffee", ".js"]
# 	}

# 	devConfigParams.module = {
# 		loaders: [
# 			{ test: /\.coffee$/, loader: "coffee" }
# 		]
# 	}

# 	devConfigParams.devtool = 'eval'
# 	# devConfigParams.devtool = "source-map"	# see if we can manage without this as well, will speed up the build a lot
# 	devConfigParams.debug = true

# 	# devConfig = webpackConfig(devConfigParams)
# 	devConfig = devConfigParams

# 	server = new WebpackDevServer(webpack(devConfig), {
# 		contentBase: 'devbuild'
# 		hot: true
# 		stats: {
# 			hash: false
# 			version: false
# 			assets: false
# 			cached: false
# 			colors: true
# 		}
# 	})

# 	# expandPath(server.app, appPath)

# 	server.listen(port, (err, result) ->
# 		if (err)
# 			console.log(err);

# 		console.log('Listening at port ' + port);
# 	)

# 	return server
