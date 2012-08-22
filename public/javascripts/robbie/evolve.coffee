fittest = (new Simulation).random_dna()

launch_worker = ->
  worker1 = new Worker("/javascripts/robbie/worker.js");
  worker1.postMessage("");
  worker1.onmessage = (message) ->
    if message.data?.dna?
      fittest = message.data.dna
    else
      console.log(message.data)

for i in [0]
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

setTimeout run_continually, 5000

