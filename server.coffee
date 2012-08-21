express = require 'express'
http = require 'http'
routes = require './routes'
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

random_strategy = ->
  strategy = ''
  for i in [0...242]
    strategy += _.random(['N','E','S','W','G','0','R'])
  strategy

max_fitness = (population) ->
  max = population[0]
  for strategy in population
    max = strategy if strategy.fitness > max.fitness
  max

population = for i in [0...200]
  dna = random_strategy()
  dna: dna
  fitness: (new Simulation(dna)).fitness()

io = require('socket.io').listen(server)
io.set("log level", 1)
io.sockets.on 'connection', (client) ->
  update_population()
  client.on 'result', (new_population) ->
    console.log "got result"
    population = new_population
    update_population()
    null

app.get '/robbie', (req,res) ->
  res.render 'robbie/index', {title: "Evolving Robbie"}

app.get '/robbie/hoipe', (req, res) ->
  res.render('robbie/hoipe', { title: "Here's one I prepared earlier" })

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

evolve = (population) ->
  new_population = []
  for i in [0...population.length/2]
    s1 = weighted_choice(population).dna
    s2 = weighted_choice(population).dna
    splitpoint = Math.floor(Math.random() * s1.length)
    dna1 = s1.slice(0,splitpoint) + s2.slice(splitpoint,s2.length)
    for i in [0...dna1.length]
      if Math.random() < 0.001
        dna1 = dna1.slice(0,i) + _.random(['N','E','S','W','G','0','R']) + dna1.slice(i+1,dna1.length)
    dna2 = s2.slice(0,splitpoint) + s1.slice(splitpoint,s1.length)
    for i in [0...dna2.length]
      if Math.random() < 0.001
        dna2 = dna2.slice(0,i) + _.random(['N','E','S','W','G','0','R']) + dna2.slice(i+1,dna2.length)
    new_population.push
      dna: dna1
      fitness: null
    new_population.push
      dna: dna2
      fitness: null
  console.log "Max fitness is #{max_fitness(population).fitness}"
  new_population

update_population = ->
  new_population = evolve(population)
  population = new_population
  io.sockets.emit 'population', population
  #console.log population

update_population()