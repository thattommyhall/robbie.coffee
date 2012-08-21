_ = require './underscore' if global?

_.mixin
  random: (list) ->
    if _.isArray(list)
      return list[Math.floor(Math.random() * list.length)]
    if _.isObject(list)
      key = _.random(_.keys(list))
      return [key,list[key]]

if global?
  global['_'] = _

if window?
  window['_'] = _
