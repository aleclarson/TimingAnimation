
{ Animation } = require "Animated"

getArgProp = require "getArgProp"
LazyVar = require "LazyVar"
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

  progress: 0

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

  computeProgressAtTime: (time) ->
    return @easing 0 if time <= 0
    return @easing 1 if time >= @duration
    return @easing time / @duration

  _start: ->

    @_timer = null
    if @duration is 0
      @_onUpdate @computeValueAtProgress 1
      @finish()
      return

    @startTime = Date.now()
    @_requestAnimationFrame()

type.overrideMethods

  __computeValue: ->

    @_lastTime = @time
    @_lastValue = @value
    @_velocity.reset()

    @time = Math.min @duration, Date.now() - @startTime
    @progress = @computeProgressAtTime @time
    return @value = @computeValueAtProgress @progress

  __didStart: ->
    return @_start() if @delay <= 0
    @_timer = Timer @delay, => @_start()

  __didUpdate: (value) ->
    @finish() if @time is @duration

  __didEnd: ->
    return unless @_timer
    @_timer.prevent()
    @_timer = null

  __captureFrame: ->
    { @progress, @value, @time }

module.exports = type.build()
