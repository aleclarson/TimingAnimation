
{Animation} = require "Animated"

LazyVar = require "LazyVar"
Easing = require "easing"
Timer = require "timer"
Type = require "Type"

type = Type "TimingAnimation"

type.inherits Animation

type.defineArgs ->

  required: yes
  types:
    toValue: Number
    duration: Number
    easing: Function
    delay: Number

  defaults:
    easing: Easing.linear
    delay: 0

type.defineFrozenValues (options) ->

  toValue: options.toValue

  duration: options.duration

  easing: options.easing

  delay: options.delay

  _velocity: @_initVelocity() unless options.useNativeDriver

type.defineValues

  _time: null

  _value: null

  _progress: 0

  _lastTime: null

  _lastValue: null

  _delayTimer: null

type.defineGetters

  time: ->
    if @_useNativeDriver
    then @_computeTime()
    else @_time

  value: ->
    if @_useNativeDriver
    then @_valueAtProgress @easing @_computeTime() / @duration
    else @_value

  progress: ->
    if @_useNativeDriver
    then @easing @_computeTime() / @duration
    else @_progress

  velocity: ->
    if @_useNativeDriver
    then log.warn "Cannot access 'velocity' for native animations!"
    else @_velocity.get()

type.defineMethods

  _initVelocity: ->
    return LazyVar =>
      (@_value - @_lastValue) / (@_time - @_lastTime)

  _computeTime: ->
    Math.min @duration, Date.now() - @startTime

  _valueAtProgress: (progress) ->
    @fromValue + progress * (@toValue - @fromValue)

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
    @_time = @startTime
    @_value = @fromValue
    if @duration > 0
    then @__super arguments
    else @_requestAnimationFrame =>
      @_animationFrame = null
      @_onUpdate @_valueAtProgress 1
      @stop yes

  __computeValue: ->

    @_lastTime = @_time
    @_lastValue = @_value
    @_velocity.reset()

    @_time = @_computeTime()
    @_progress = @easing @_time / @duration
    return @_value = @_valueAtProgress @_progress

  __onAnimationUpdate: (value) ->
    if @_time is @duration
      @stop yes

  __onAnimationEnd: ->
    return unless @_delayTimer
    @_delayTimer.prevent()
    @_delayTimer = null

  __captureFrame: ->
    time: @_time
    value: @_value
    progress: @_progress

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
