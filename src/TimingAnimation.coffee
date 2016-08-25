
{ Animation } = require "Animated"

LazyVar = require "LazyVar"
Easing = require "easing"
Type = require "Type"

type = Type "TimingAnimation"

type.inherits Animation

type.defineOptions
  endValue: Number.isRequired
  duration: Number.isRequired
  easing: Function.withDefault Easing.get "linear"
  delay: Number.withDefault 0

type.defineFrozenValues (options) ->

  endValue: options.endValue

  duration: options.duration

  easing: options.easing

  delay: options.delay

  _velocity: LazyVar => (@value - @_lastValue) / (@time - @_lastTime)

type.defineValues

  progress: 0

  time: null

  value: null

  _lastTime: null

  _lastValue: null

  _delayTimer: null

type.defineGetters

  velocity: -> @_velocity.get()

type.defineMethods

  computeValueAtProgress: (progress) ->
    @startValue + progress * (@endValue - @startValue)

  computeProgressAtTime: (time) ->
    return @easing 0 if time <= 0
    return @easing 1 if time >= @duration
    return @easing time / @duration

  _start: ->

    @_delayTimer = null
    if @duration is 0
      @_onUpdate @computeValueAtProgress 1
      @finish()
      return

    @time = @startTime = Date.now()
    @value = @startValue
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
    @_delayTimer = Timer @delay, => @_start()

  __didUpdate: (value) ->
    @finish() if @time is @duration

  __didEnd: ->
    return unless @_delayTimer
    @_delayTimer.prevent()
    @_delayTimer = null

  __captureFrame: ->
    { @value, @time, @progress }

module.exports = type.build()
