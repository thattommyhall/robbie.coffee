// Generated by CoffeeScript 1.3.3
var Simulation;

Simulation = (function() {
  var CUP, EMPTY, WALL;

  EMPTY = 0;

  CUP = 1;

  WALL = 2;

  function Simulation(strategy) {
    this.strategy = strategy;
    this.board = this.random_board();
    this.score = 0;
    this.x = 1;
    this.y = 1;
  }

  Simulation.prototype.reset = function() {
    this.board = this.random_board();
    this.score = 0;
    this.x = 1;
    return this.y = 1;
  };

  Simulation.prototype.random_board = function() {
    var x, y, _i, _results;
    _results = [];
    for (y = _i = 0; _i <= 11; y = ++_i) {
      _results.push((function() {
        var _j, _results1;
        _results1 = [];
        for (x = _j = 0; _j <= 11; x = ++_j) {
          if (x === 0 || y === 0 || x === 11 || y === 11) {
            _results1.push(WALL);
          } else if (Math.random() < 0.5) {
            _results1.push(CUP);
          } else {
            _results1.push(EMPTY);
          }
        }
        return _results1;
      })());
    }
    return _results;
  };

  Simulation.prototype.step = function() {
    var current, down, left, move, right, strategy_index, up;
    up = this.board[this.y - 1][this.x];
    down = this.board[this.y + 1][this.x];
    left = this.board[this.y][this.x - 1];
    right = this.board[this.y][this.x + 1];
    current = this.board[this.y][this.x];
    strategy_index = this.strategy_index(up, down, left, right, current);
    move = this.strategy[strategy_index];
    return this.move(move);
  };

  Simulation.prototype.run = function(display_fn) {
    var i, _i;
    this.reset();
    for (i = _i = 0; _i < 200; i = ++_i) {
      this.step();
    }
    return this.score;
  };

  Simulation.prototype.move = function(move) {
    var current, down, left, right, up;
    up = this.board[this.y - 1][this.x];
    down = this.board[this.y + 1][this.x];
    left = this.board[this.y][this.x - 1];
    right = this.board[this.y][this.x + 1];
    current = this.board[this.y][this.x];
    switch (move) {
      case 'N':
        if (up === WALL) {
          return this.score -= 5;
        } else {
          return this.y -= 1;
        }
        break;
      case 'E':
        if (right === WALL) {
          return this.score -= 5;
        } else {
          return this.x += 1;
        }
        break;
      case 'S':
        if (down === WALL) {
          return this.score -= 5;
        } else {
          return this.y += 1;
        }
        break;
      case 'W':
        if (left === WALL) {
          return this.score -= 5;
        } else {
          return this.x -= 1;
        }
        break;
      case '0':
        return '';
      case 'G':
        if (this.board[this.y][this.x] === CUP) {
          this.board[this.y][this.x] = EMPTY;
          return this.score += 10;
        } else {
          return this.score -= 1;
        }
        break;
      case 'R':
        return this.move(_.random(['N', 'E', 'S', 'W']));
    }
  };

  Simulation.prototype.display_console = function() {
    var board, x, y, _i;
    console.log('***********************');
    console.log(this.score);
    board = (function() {
      var _i, _results;
      _results = [];
      for (x = _i = 0; _i <= 11; x = ++_i) {
        _results.push((function() {
          var _j, _results1;
          _results1 = [];
          for (y = _j = 0; _j <= 11; y = ++_j) {
            if (x === this.x && y === this.y) {
              _results1.push('R');
            } else {
              _results1.push(this.board[y][x]);
            }
          }
          return _results1;
        }).call(this));
      }
      return _results;
    }).call(this);
    for (y = _i = 0; _i <= 11; y = ++_i) {
      console.log(board[y].join());
    }
    return '';
  };

  Simulation.prototype.random_dna = function() {
    var i, strategy, _i;
    strategy = '';
    for (i = _i = 0; _i < 242; i = ++_i) {
      strategy += _.random(['N', 'E', 'S', 'W', 'G', '0', 'R']);
    }
    return strategy;
  };

  Simulation.prototype.display_canvas = function(element_id) {
    var background, board, cell_size, context, coords, fill_colour, line_colour, x, y, _i, _j;
    board = document.getElementById(element_id);
    context = board.getContext('2d');
    line_colour = '#cdcdcd';
    background = '#fff';
    fill_colour = '#666';
    context.fillStyle = background;
    context.fillRect(0, 0, board.width, board.height);
    cell_size = board.width / 12;
    context.strokeStyle = line_colour;
    context.fillStyle = fill_colour;
    for (x = _i = 1; _i <= 10; x = ++_i) {
      for (y = _j = 1; _j <= 10; y = ++_j) {
        coords = [x * cell_size, y * cell_size, cell_size, cell_size];
        context.strokeRect.apply(context, coords);
        if (this.board[y][x] === CUP) {
          context.beginPath();
          context.arc(x * cell_size + cell_size / 2, y * cell_size + cell_size / 2, 5, 0, Math.PI * 2, true);
          context.closePath();
          context.fill();
        }
      }
    }
    context.beginPath();
    context.arc(this.x * cell_size + cell_size / 2, this.y * cell_size + cell_size / 2, 20, 0, Math.PI * 2, true);
    context.closePath();
    context.fill();
    return null;
  };

  Simulation.prototype.strategy_index = function(up, down, left, right, current) {
    return up * Math.pow(3, 4) + down * Math.pow(3, 3) + left * Math.pow(3, 2) + right * Math.pow(3, 1) + current;
  };

  Simulation.prototype.fitness = function() {
    var i, tot;
    tot = 0;
    i = 0;
    while (i < 100) {
      this.reset();
      tot += this.run();
      i++;
    }
    return tot / 100;
  };

  return Simulation;

})();

if ((typeof module !== "undefined" && module !== null ? module.exports : void 0) != null) {
  module.exports['Simulation'] = Simulation;
}
