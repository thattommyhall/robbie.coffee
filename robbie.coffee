_ = require('./tth_')

EMPTY = 0
CUP = 1
WALL = 2

class Simulation
  constructor: (@strategy) ->
    @board = @random_board()
    @score = 0
    @x = 1
    @y = 1

  reset: ->
    @board = @random_board()
    @score = 0
    @x = 1
    @y = 1

  random_board: -> for y in [0..11]
    for x in [0..11]
      if x is 0 or y is 0 or x is 11 or y is 11
        WALL
      else if Math.random() < 0.5 then CUP else EMPTY

  step: ->
    up = @board[@y-1][@x]
    down = @board[@y+1][@x]
    left = @board[@y][@x-1]
    right = @board[@y][@x+1]
    current = @board[@y][@x]
    strategy_index = @strategy_index(up,down,left,right,current)
    move = @strategy[strategy_index]
    @move(move)

  run: ->
    @reset()
    for i in [0...200]
      @step()
      # @display()
    @score

  move: (move) ->
    up = @board[@y-1][@x]
    down = @board[@y+1][@x]
    left = @board[@y][@x-1]
    right = @board[@y][@x+1]
    current = @board[@y][@x]
    switch move
      when 'N'
        if up is WALL
          @score -= 5
        else
          @y -= 1
      when 'E'
        if right is WALL
          @score -= 5
        else
          @x += 1
      when 'S'
        if down is WALL
          @score -= 5
        else @y += 1
      when 'W'
        if left is WALL
          @score -= 5
        else
          @x -= 1
      when '0'
        ''
      when 'G'
        if @board[@y][@x] is CUP
          @board[@y][@x] = EMPTY
          @score += 10
        else
          @score -= 1
      when 'R'
        @move(_.random(['N','E','S','W']))

  display: () ->
    console.log '***********************'
    console.log @score
    board = for x in [0..11]
      for y in [0..11]
        if x is @x and y is @y
          'R'
        else
          @board[y][x]
    for y in [0..11]
      console.log board[y].join()
    ''

  strategy_index: (up,down,left,right,current) ->
    up * Math.pow(3,4) + down * Math.pow(3,3) + left * Math.pow(3,2) + right * Math.pow(3,1) + current

  fitness: ->
    tot = 0
    i = 0
    while i < 100
      @reset()
      tot += @run()
      i++
    tot / 100

random_strategy = ->
  strategy = ''
  for i in [0...242]
    strategy += _.random(['N','E','S','W','G','0','R'])
  strategy

allways_random = ->
  strategy = ''
  for i in [0...242]
    strategy += 'R'
  console.log strategy
  strategy


max_fitness = (population) ->
  max = population[0]
  for strategy in population
    max = strategy if strategy.fitness > max.fitness
  max

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

run = ->
  population = for i in [0...200]
    dna = random_strategy()
    dna: dna
    fitness: (new Simulation(dna)).fitness()

  evolve = ->
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
        fitness: (new Simulation(dna1)).fitness()
      new_population.push
        dna: dna2
        fitness: (new Simulation(dna2)).fitness()
    population = new_population
    console.log max_fitness(population)

  for i in [0...20]
    console.log "Generation #{i}"
    evolve()
  0

run()

test = 'NG0EGRWGWWGNWWEWG0SGREGS00NSGWSSRWGWSWNWWSREESGESGEEEREGGEGNNGGEGEEG0NEGEGGEGW0EGNGSEGGWGSWGEWWWNGSRNENG0GSRNSWSS0SGSSW0WWRGNWEGNRGSSS0NGEEGRNGRWGSWGWRNW0RG00WGWNWGREGRWGEWGSEGGNN0SGESGWGERSG0ES0SGSWSSRSWS0RSG0SGER0SGRNGEEESRRGERESG0SNEEWSN0G'

# console.log (new Simulation test).run()

exports.Simulation = Simulation