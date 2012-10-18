_ = require '../tth_' if module?.exports?

class Simulation
  EMPTY = 0
  CUP = 1
  WALL = 2

  constructor: (@strategy) ->
    @board = @random_board()
    @score = 0
    @x = _.random([1..10])
    @y = _.random([1..10])

  reset: ->
    @board = @random_board()
    @score = 0
    @x = _.random([1..10])
    @y = _.random([1..10])

  random_board: -> for y in [0..11]
    for x in [0..11]
      if x is 0 or y is 0 or x is 11 or y is 11
        WALL
      else if Math.random() < 0.1 then CUP else EMPTY

  step: ->
    up = @board[@y-1][@x]
    down = @board[@y+1][@x]
    left = @board[@y][@x-1]
    right = @board[@y][@x+1]
    current = @board[@y][@x]
    strategy_index = @strategy_index(up,down,left,right,current)
    move = @strategy[strategy_index]
    @move(move)


  run: (display_fn) ->
    @reset()
    for i in [0...200]
      @step()
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

  display_console: () ->
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
  random_dna: ->
    strategy = ''
    for i in [0...242]
      strategy += _.random(['N','E','S','W','G','0','R'])
    strategy

  display_canvas: (element_id) ->
    board = document.getElementById(element_id)
    context = board.getContext('2d')
    line_colour = '#cdcdcd'
    background = '#fff'
    fill_colour = '#666'
    context.fillStyle = background
    context.fillRect(0,0,board.width,board.height)
    cell_size = board.width / 12
    context.strokeStyle = line_colour
    context.fillStyle = fill_colour
    for x in [1..10]
      for y in [1..10]
        coords = [x * cell_size, y * cell_size, cell_size, cell_size]
        context.strokeRect.apply context, coords
        if @board[y][x] is CUP
          context.beginPath()
          context.arc(x * cell_size + cell_size / 2, y * cell_size + cell_size / 2, 5, 0, Math.PI*2, true);
          context.closePath()
          context.fill()
    context.beginPath()
    context.arc(@x * cell_size + cell_size / 2, @y * cell_size + cell_size / 2, 20, 0, Math.PI*2, true);
    context.closePath()
    context.fill()

    null

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

if module?.exports?
  module.exports['Simulation'] = Simulation
