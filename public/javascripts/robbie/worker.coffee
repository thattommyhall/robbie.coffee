importScripts('/socket.io/socket.io.js')
importScripts('/javascripts/underscore.js')
importScripts('/javascripts/tth_.js')
importScripts('/javascripts/robbie/simulation.js')

# socket = io.connect('http://109.107.37.65')
socket = io.connect('http://localhost:9292')

population = []

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

max_fitness = (population) ->
  max = population[0]
  for strategy in population
    max = strategy if strategy.fitness > max.fitness
  max

evolve = (population) ->
  new_population = []
  for i in [0...100]
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
      fitness: (new Simulation(dna1).fitness())
    new_population.push
      dna: dna2
      fitness: (new Simulation(dna2).fitness())
  new_population

socket.on 'population', (new_population) ->
  postMessage "Got new population from master"
  postMessage max_fitness(population)
  population = population.concat new_population

reset = ->
  population = for i in [0...200]
    dna = (new Simulation).random_dna()
    dna: dna
    fitness: (new Simulation(dna)).fitness()

# socket.on 'reset', ->
#   reset()

# socket.on 'connect_failed', ->
#   postMessage('connect failed')
#   reset()

socket.on 'error', ->
  postMessage('error in the socket')

tick = ->
  for i in [0...10]
    population = evolve(population) if population.length > 1
  socket.emit 'result', population
  setTimeout tick,0

tick()