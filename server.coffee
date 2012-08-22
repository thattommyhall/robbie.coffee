express = require 'express'
http = require 'http'
path = require 'path'
require './public/javascripts/tth_'
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
  console.log "Express serverlistening on port " + app.get('port')


max_fitness = (population) ->
  max = population[0]
  for strategy in population
    max = strategy if strategy.fitness > max.fitness
  max

population = for i in [0...200]
  dna = (new Simulation).random_dna()
  dna: dna
  fitness: (new Simulation(dna)).fitness()

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
io.sockets.on 'connection', (socket) ->
  console.log "#{socket.id} connected"
  client_count++
  socket.emit 'population', population
  socket.on 'result', (new_population) ->
    console.log "got result from #{socket.id}"
    result_count++
    console.log result_count
    if result_count > client_count
      population = for i in [0...200]
        weighted_choice(population)
      io.sockets.emit 'population', population
      result_count = 0
    update_population(new_population)
  socket.on 'disconnect', ->
    client_count--
    console.log "#{socket.id} left"


app.get '/', (req,res) ->
  res.render 'robbie/index', {title: "Evolving Robbie"}

app.get '/hoipe', (req, res) ->
  res.render('robbie/hoipe', { title: "Here's one I prepared earlier" })

update_population = (new_population) ->
  population = population.concat new_population
  console.log population.length
  max = max_fitness(population)
  console.log max
