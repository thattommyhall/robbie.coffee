importScripts('/socket.io/socket.io.js')
importScripts('/javascripts/underscore.js')
importScripts('/javascripts/tth_.js')
importScripts('/javascripts/robbie/simulation.js')

@onmessage = (event) ->
  socket = io.connect('http://localhost:9292')

  socket.on 'population', (population) ->
    postMessage "recieved"
    new_population = for strategy in population
      dna: strategy.dna
      fitness: (new Simulation(strategy.dna).fitness())
    socket.emit 'result', new_population

  socket.on 'connect_failed', ->
    postMessage('connect failed')

  socket.on 'error', ->
    postMessage('error')

