express = require 'express'
http = require 'http'
routes = require './routes'
path = require 'path'
app = express()

server = http.createServer app


app.configure ->
  app.set('port', process.env.PORT || 3000)
  app.set('views', __dirname + '/views')
  app.set('view engine', 'jade')
  app.use(express.favicon())
  app.use(express.logger('dev'))
  app.use(express.bodyParser())
  app.use(express.methodOverride())
  app.use(app.router)
  app.use(express.static(path.join(__dirname, 'public')))

app.configure 'development', ->
  app.use express.errorHandler()

http.createServer(app).listen app.get('port'), ->
  console.log "Express server listening on port " + app.get('port')

app.get '/', routes.index




#io = require('socket.io').listen(server)
#io.on 'connection', (client) ->
#  client.emit 'news', hello: 'world'
#  client.on 'test',(data) ->
#    collection[data.k] = data.v

