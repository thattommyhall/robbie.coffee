// Generated by CoffeeScript 1.3.3
var _;

if (typeof global !== "undefined" && global !== null) {
  _ = require('./underscore');
}

_.mixin({
  random: function(list) {
    var key;
    if (_.isArray(list)) {
      return list[Math.floor(Math.random() * list.length)];
    }
    if (_.isObject(list)) {
      key = _.random(_.keys(list));
      return [key, list[key]];
    }
  }
});

if (typeof global !== "undefined" && global !== null) {
  global['_'] = _;
}

if (typeof window !== "undefined" && window !== null) {
  window['_'] = _;
}