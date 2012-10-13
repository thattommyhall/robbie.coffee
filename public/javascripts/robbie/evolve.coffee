fittest = (new Simulation).random_dna()

socket = io.connect('http://109.107.37.65')
#socket = io.connect('http://localhost:9292')

socket.on 'status', (new_status) ->
  #   connected: 30
  #   fittest: {dna: somelongishstring,  fitness: number}
  #   uptime: seconds_uptime

  refresh(new_status)

refresh = (status)->
  $('#connected').html(status.connected)
  $('#fittest-dna').html(status.fittest.dna)
  $('#uptime').html("#{(status.uptime/1000/60).toFixed(2)} Minutes")
  $('#fittest-fitness').html(status.fittest.fitness)

launch_worker = ->
  worker1 = new Worker("/javascripts/robbie/worker.js");
  worker1.postMessage("");
  worker1.onmessage = (message) ->
    if message.data?.dna?
      fittest = message.data.dna
    else
      console.log(message.data)

for i in [0..4]
  launch_worker()

run_sim = ->
  s = new Simulation(fittest)
  s.display_canvas('board')
  animation_rate = 100
  count = 0
  step = ->
    s.step()
    s.display_canvas('board')
    count++
    if count == 200
      return
    setTimeout step,animation_rate
  step()

run_continually = ->
  run_sim()
  setTimeout run_continually,0

$(document).ready run_continually
