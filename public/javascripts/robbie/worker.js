// Generated by CoffeeScript 1.3.3
var evolve, max_fitness, population, socket, tick, weighted_choice;

importScripts('/socket.io/socket.io.js');

importScripts('/javascripts/underscore.js');

importScripts('/javascripts/tth_.js');

importScripts('/javascripts/robbie/simulation.js');

population = [];

weighted_choice = function(population) {
  var i, l, position, so_far, total;
  l = population.length;
  total = (l + 1) / 2 * l;
  position = Math.ceil(Math.random() * total);
  i = 0;
  so_far = l;
  while (so_far < position) {
    l = l - 1;
    so_far += l;
    i++;
  }
  return _.sortBy(population, function(strategy) {
    return strategy.fitness;
  })[population.length - 1 - i];
};

max_fitness = function(population) {
  var max, strategy, _i, _len;
  max = population[0];
  for (_i = 0, _len = population.length; _i < _len; _i++) {
    strategy = population[_i];
    if (strategy.fitness > max.fitness) {
      max = strategy;
    }
  }
  return max;
};

evolve = function(population) {
  var dna1, dna2, i, new_population, s1, s2, splitpoint, _i, _j, _k, _ref, _ref1;
  new_population = [];
  for (i = _i = 0; _i < 100; i = ++_i) {
    s1 = weighted_choice(population).dna;
    s2 = weighted_choice(population).dna;
    splitpoint = Math.floor(Math.random() * s1.length);
    dna1 = s1.slice(0, splitpoint) + s2.slice(splitpoint, s2.length);
    for (i = _j = 0, _ref = dna1.length; 0 <= _ref ? _j < _ref : _j > _ref; i = 0 <= _ref ? ++_j : --_j) {
      if (Math.random() < 0.001) {
        dna1 = dna1.slice(0, i) + _.random(['N', 'E', 'S', 'W', 'G', '0', 'R']) + dna1.slice(i + 1, dna1.length);
      }
    }
    dna2 = s2.slice(0, splitpoint) + s1.slice(splitpoint, s1.length);
    for (i = _k = 0, _ref1 = dna2.length; 0 <= _ref1 ? _k < _ref1 : _k > _ref1; i = 0 <= _ref1 ? ++_k : --_k) {
      if (Math.random() < 0.001) {
        dna2 = dna2.slice(0, i) + _.random(['N', 'E', 'S', 'W', 'G', '0', 'R']) + dna2.slice(i + 1, dna2.length);
      }
    }
    new_population.push({
      dna: dna1,
      fitness: new Simulation(dna1).fitness()
    });
    new_population.push({
      dna: dna2,
      fitness: new Simulation(dna2).fitness()
    });
  }
  return new_population;
};

socket = io.connect('http://109.107.37.65');

socket.on('population', function(new_population) {
  postMessage("Got new population from master");
  postMessage(max_fitness(population));
  return population = population.concat(new_population);
});

socket.on('connect_failed', function() {
  return postMessage('connect failed');
});

socket.on('error', function() {
  return postMessage('error');
});

tick = function() {
  var i, _i;
  for (i = _i = 0; _i < 10; i = ++_i) {
    if (population.length > 1) {
      population = evolve(population);
    }
  }
  socket.emit('result', population);
  return setTimeout(tick, 0);
};

tick();
