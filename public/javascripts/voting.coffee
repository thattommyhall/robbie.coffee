

voting = ->
  board = document.getElementById('voteing')
  context = board.getContext('2d')
  line_colour = '#cdcdcd'
  background = '#fff'
  liveColor = '#666'
  deadColor = '#eee'
  context.fillStyle = background
  context.fillRect(0,0,board.width,board.height)
  padding = 0
  cells = 1001
  cell_size = (board.width - 2*padding) / cells

  fill_sq = (x,y) ->
    coords = [x * cell_size + padding, y * cell_size + padding, cell_size, cell_size]
    context.strokeStyle = line_colour
    context.strokeRect.apply context, coords
    context.fillRect.apply context, coords
  alive = (x,y) ->
    context.fillStyle = liveColor
    fill_sq(x,y)
  dead = (x,y) ->
    context.fillStyle = deadColor
    fill_sq(x,y)

  p = 0.5 + Math.random() / 10
  t = 0
  state = for i in [0...cells]
    if Math.random() > p
      1
    else
      0

  draw_line = (row, contents) ->
    for pos in [0...cells]
      if contents[pos] is 0 then dead(pos,row) else alive(pos,row)

  lookup = (position) ->
    if position >= cells
      return lookup(position % cells)
    if position < 0
      return lookup(position + cells)
    state[position]

  for i in [-3...cells+3]
    console.log "#{i} - #{lookup(i)}"

  majority = (a,b,c) ->
    if a+b+c >= 2 then 1 else 0

  tick = ->
    draw_line(t,state)
    new_state = for pos in [0...cells]
      if state[pos] is 0
        majority(lookup(pos),lookup(pos-1),lookup(pos-3))
      else
        majority(lookup(pos),lookup(pos+1),lookup(pos+3))
    t++
    state = new_state
    if t < cells
      setTimeout tick,0

  tick()
