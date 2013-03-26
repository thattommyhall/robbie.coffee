express = require 'express'
http = require 'http'
path = require 'path'
_ = require './public/javascripts/tth_'
Simulation = require('./public/javascripts/robbie/simulation.js').Simulation

app = express()

app.configure ->
  app.set('port', process.env.PORT || 9292)
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

server = http.createServer(app).listen app.get('port'), ->
  console.log "Express server listening on port " + app.get('port')

max_fitness = (population) ->
  max = population[0]
  for strategy in population
    max = strategy if strategy.fitness > max.fitness
  max

population = []

now = ->
  (new Date).getTime()

start = now()
thirty_mins = 30*60*1000

weighted_choice = (population) ->
  l = population.length
  total = (l + 1)/2 * l
  position = (Math.ceil(Math.random() * total))
  i = 0
  so_far = l
  while so_far < position
    l = l - 1
    so_far += l
    i++
  _.sortBy(population,(strategy) -> strategy.fitness)[population.length-1-i]

client_count = 0
result_count = 0
io = require('socket.io').listen(server)
io.set("log level", 1)
io.enable('browser client minification')
io.enable('browser client etag')
io.enable('browser client gzip')
io.set('log level', 1)
io.set 'transports',
[
#    'websocket'
   'flashsocket'
  , 'htmlfile'
  , 'xhr-polling'
  , 'jsonp-polling'
]

run_id = now()

io.sockets.on 'connection', (socket) ->
  console.log "#{socket.id} connected"
  client_count++
  socket.emit 'population',
    population: population
    run_id: run_id
    
  socket.emit 'status', status()
  # socket.emit 'reset'
  socket.on 'result', (new_population) ->
    #console.log "got result from #{socket.id}"
    pop = new_population['population']
    id = new_population['run_id']
    unless id is run_id
      console.log "incorrect ID"
      return
    result_count++
    
    #console.log result_count
    if result_count > client_count
      population = for i in [0...200]
        weighted_choice(population)
      run_id = now()
      io.sockets.emit 'population',
        run_id: run_id
        population: population
      io.sockets.emit 'status', status()
      result_count = 0
    update_population(pop)
  socket.on 'disconnect', ->
    client_count--
    console.log "#{socket.id} left"

update_population = (new_population) ->
  population = population.concat new_population
  max = max_fitness(population)
  reset() if now()-start > thirty_mins
  
reset = ->
  console.log "resetting"
  population = for i in [0...200]
    dna = (new Simulation).random_dna()
    dna: dna
    fitness: (new Simulation(dna)).fitness()
  start = now()
  io.sockets.emit 'reset'

status = ->
  connected: client_count
  fittest: max_fitness(population)
  uptime: now() - start

log_status = ->
  console.log status()

setInterval log_status, 5000

send_status = ->
  io.sockets.emit 'status', status()

setInterval send_status, 2000

app.get '/', (req,res) ->
  res.redirect '/robbie/evolve'

app.get '/robbie/evolve', (req,res) ->
  res.render 'robbie/evolve', title: "Evolving Robbie"

app.get '/robbie/display', (req, res) ->
  res.render 'robbie/display', title: "Here's one I prepared earlier"

app.get '/ca/evolve', (req, res) ->
  res.render 'ca/evolve', title: "EVOLVING..."

app.get '/ca/display', (req,res) ->
  res.render 'ca/display',
    title: "Majority Voting"
    spec:
      cells: req.query.cells
      dna: req.query.dna

reset()
