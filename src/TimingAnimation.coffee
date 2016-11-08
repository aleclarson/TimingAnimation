
{Animation} = require "Animated"

LazyVar = require "LazyVar"
Easing = require "easing"
Timer = require "timer"
Type = require "Type"

type = Type "TimingAnimation"

type.inherits Animation

type.defineOptions
  toValue: Number.isRequired
  duration: Number.isRequired
  easing: Function.withDefault Easing.linear
  delay: Number.withDefault 0

type.defineFrozenValues (options) ->

  toValue: options.toValue

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
    @fromValue + progress * (@toValue - @fromValue)

  _progressAtTime: (time) ->
    return @easing 0 if time <= 0
    return @easing 1 if time >= @duration
    return @easing time / @duration

type.overrideMethods

  _startAnimation: (animated) ->
    if @delay is 0
      @__super arguments
    else if @_delayTimer
      @_delayTimer = null
      @__super arguments
    else
      @_delayTimer = Timer @delay, =>
        @_startAnimation animated

  __onAnimationStart: ->
    @time = @startTime
    @value = @fromValue
    if @duration > 0
    then @__super arguments
    else @_requestAnimationFrame =>
      @_animationFrame = null
      @_onUpdate @_valueAtProgress 1
      @finish()

  __computeValue: ->

    @_lastTime = @time
    @_lastValue = @value
    @_velocity.reset()

    @time = Math.min @duration, Date.now() - @startTime
    @progress = @_progressAtTime @time
    return @value = @_valueAtProgress @progress

  __onAnimationUpdate: (value) ->
    @finish() if @time is @duration

  __onAnimationEnd: ->
    return unless @_delayTimer
    @_delayTimer.prevent()
    @_delayTimer = null

  __captureFrame: ->
    { @value, @time, @progress }

  __getNativeConfig: ->
    frames = []
    frameDuration = 1000 / 60
    frameTime = 0
    while frameTime < @duration
      frames.push @easing frameTime / @duration
      frameTime += frameDuration
    if frameTime - @duration < 0.001
      frames.push @easing 1
    return {type: "frames", frames, @toValue}

module.exports = type.build()
