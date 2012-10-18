// Generated by CoffeeScript 1.3.3
var now, voting;

now = function() {
  return (new Date).getTime();
};

voting = function(spec) {
  var alive, background, board, cell_size, cells, context, dead, deadColor, draw_line, fill_sq, i, line_colour, liveColor, lookup, majority, p, padding, power, start, state, t, tick;
  console.log(spec);
  board = document.getElementById('voteing');
  context = board.getContext('2d');
  line_colour = '#cdcdcd';
  background = '#fff';
  liveColor = '#666';
  deadColor = '#eee';
  context.fillStyle = background;
  context.fillRect(0, 0, board.width, board.height);
  padding = 0;
  console.log(cells);
  if ((spec != null ? spec.cells : void 0) != null) {
    cells = parseInt(spec.cells);
  } else {
    cells = 101;
  }
  cell_size = (board.width - 2 * padding) / cells;
  fill_sq = function(x, y) {
    var coords;
    coords = [x * cell_size + padding, y * cell_size + padding, cell_size, cell_size];
    context.strokeRect.apply(context, coords);
    return context.fillRect.apply(context, coords);
  };
  alive = function(x, y) {
    context.fillStyle = liveColor;
    context.strokeStyle = liveColor;
    return fill_sq(x, y);
  };
  dead = function(x, y) {
    context.fillStyle = deadColor;
    context.strokeStyle = deadColor;
    return fill_sq(x, y);
  };
  power = Math.floor(Math.random() * 10);
  p = 0.5;
  t = 0;
  state = (function() {
    var _i, _results;
    _results = [];
    for (i = _i = 0; 0 <= cells ? _i < cells : _i > cells; i = 0 <= cells ? ++_i : --_i) {
      if (Math.random() > p) {
        _results.push(1);
      } else {
        _results.push(0);
      }
    }
    return _results;
  })();
  draw_line = function(row, contents) {
    var pos, _i, _results;
    _results = [];
    for (pos = _i = 0; 0 <= cells ? _i < cells : _i > cells; pos = 0 <= cells ? ++_i : --_i) {
      if (contents[pos] === 0) {
        _results.push(dead(pos, row));
      } else {
        _results.push(alive(pos, row));
      }
    }
    return _results;
  };
  lookup = function(position) {
    if (position >= cells) {
      return lookup(position % cells);
    }
    if (position < 0) {
      return lookup(position + cells);
    }
    return state[position];
  };
  majority = function(a, b, c) {
    if (a + b + c >= 2) {
      return 1;
    } else {
      return 0;
    }
  };
  tick = function() {
    var end, new_state, pos;
    draw_line(t, state);
    new_state = (function() {
      var _i, _results;
      _results = [];
      for (pos = _i = 0; 0 <= cells ? _i < cells : _i > cells; pos = 0 <= cells ? ++_i : --_i) {
        if (state[pos] === 0) {
          _results.push(majority(lookup(pos), lookup(pos - 1), lookup(pos - 3)));
        } else {
          _results.push(majority(lookup(pos), lookup(pos + 1), lookup(pos + 3)));
        }
      }
      return _results;
    })();
    t++;
    state = new_state;
    if (t < cells) {
      return setTimeout(tick, 0);
    } else {
      end = now();
      return console.log("took " + (end - start));
    }
  };
  start = now();
  tick();
  return null;
};
