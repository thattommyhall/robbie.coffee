fittest = (new Simulation).random_dna()

launch_worker = ->
  worker1 = new Worker("/javascripts/robbie/worker.js");
  worker1.postMessage("");
  worker1.onmessage = (message) ->
    if message.dna?
      fittest = message.dna
    else
      console.log(message.data)

for i in [0..1]
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
    console.log count
    if count == 200
      return
    setTimeout step,animation_rate
  step()


run_sim()

