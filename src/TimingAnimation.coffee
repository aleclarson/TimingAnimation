
{Animation} = require "Animated"

LazyVar = require "LazyVar"
Easing = require "easing"
Timer = require "timer"
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

  _valueAtProgress: (progress) ->
    @startValue + progress * (@endValue - @startValue)

  _progressAtTime: (time) ->
    return @easing 0 if time <= 0
    return @easing 1 if time >= @duration
    return @easing time / @duration

  _start: (config) ->
    @time = @startTime = Date.now()
    @value = @startValue = config.startValue

    @_delayTimer = null

    if @duration > 0
      @_requestAnimationFrame()
      return

    @_onUpdate @_valueAtProgress 1
    @finish()
    return


type.overrideMethods

  __computeValue: ->

    @_lastTime = @time
    @_lastValue = @value
    @_velocity.reset()

    @time = Math.min @duration, Date.now() - @startTime
    @progress = @_progressAtTime @time
    return @value = @_valueAtProgress @progress

  __didStart: (config) ->
    if @delay > 0
      @_delayTimer = Timer @delay, => @_start config
    else @_start config

  __didUpdate: (value) ->
    @finish() if @time is @duration

  __didEnd: ->
    return unless @_delayTimer
    @_delayTimer.prevent()
    @_delayTimer = null

  __captureFrame: ->
    { @value, @time, @progress }

module.exports = type.build()
