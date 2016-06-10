
{ AnimatedValue, Animation } = require "Animated"

getArgProp = require "getArgProp"
LazyVar = require "lazy-var"
Easing = require "easing"
Type = require "Type"

type = Type "TimingAnimation"

type.inherits Animation

type.optionTypes =
  endValue: Number
  duration: Number
  easing: Function
  delay: Number

type.optionDefaults =
  easing: Easing "linear"
  delay: 0

type.defineFrozenValues

  endValue: getArgProp "endValue"

  duration: getArgProp "duration"

  easing: getArgProp "easing"

  delay: getArgProp "delay"

  _velocity: -> LazyVar =>
    (@value - @_lastValue) / (@time - @_lastTime)

type.defineValues

  time: null

  value: null

  _timer: null

  _lastTime: null

  _lastValue: null

type.exposeLazyGetters [
  "velocity"
]

type.defineMethods

  computeValueAtProgress: (progress) ->
    @startValue + progress * (@endValue - @startValue)

  computeValueAtTime: (time) ->
    progress = @computeProgressAtTime time
    @computeValueAtProgress progress

  computeProgressAtTime: (time) ->
    return @easing 0 if time <= 0
    return @easing 1 if time >= @duration
    return @easing time / @duration

type.overrideMethods

  __computeValue: ->

    @_lastTime = @time
    @_lastValue = @value

    @time = Math.min @duration, Date.now() - @startTime
    @value = @computeValueAtTime @time

    @_velocity.reset()

    return @value

  __didComputeValue: (value) ->
    @finish() if @time is @duration

  __onStart: ->
    if @delay > 0
      @_timer = Timer @delay, => @__onStart()
    else
      @_timer = null
      if @duration is 0
        @_onUpdate @computeValueAtProgress 1
        @finish()
      else
        @startTime = Date.now()
        @_requestAnimationFrame()

  __onEnd: ->
    return unless @_timer
    @_timer.prevent()
    @_timer = null

module.exports = type.build()
