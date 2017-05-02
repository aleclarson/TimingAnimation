
{Animation} = require "Animated"
{mutable} = require "Property"

Timer = require "timer"
Type = require "Type"

type = Type "TimingAnimation"

type.inherits Animation

type.defineArgs ->

  required:
    toValue: yes
    duration: yes

  types:
    toValue: Number
    duration: Number
    easing: Function
    delay: Number

type.defineFrozenValues (options) ->

  toValue: options.toValue

  duration: options.duration

  easing: options.easing

  delay: options.delay

type.defineValues

  _delayTimer: null

type.defineGetters

  value: -> @_valueAtProgress @progress

  elapsedTime: -> Date.now() - @startTime

  progress: ->
    progress = Math.min 1, @elapsedTime / @duration
    return @easing progress if @easing
    return progress

type.defineMethods

  _valueAtProgress: (progress) ->
    @fromValue + progress * (@toValue - @fromValue)

type.overrideMethods

  _startAnimation: (animated) ->

    unless @_useNativeDriver
      mutable.define this, "value", {value: @fromValue}
      mutable.define this, "progress", {value: 0}

    unless @delay
      return @__super arguments

    if @_delayTimer
      @_delayTimer = null
      return @__super arguments

    @_delayTimer = Timer @delay, =>
      @_startAnimation animated
    return

  __onAnimationStart: ->

    if @duration > 0
      return @__super arguments

    @_requestAnimationFrame =>
      @_animationFrame = null
      @_onUpdate @_valueAtProgress 1
      @stop yes
      return

  __computeValue: ->
    progress = Math.min 1, @elapsedTime / @duration
    progress = @easing progress if @easing
    @value = @_valueAtProgress progress
    @progress = progress
    return @value

  __onAnimationUpdate: (value) ->
    if @_time is @duration
      @stop yes
      return

  __onAnimationEnd: (finished) ->
    if @_delayTimer
      @_delayTimer.prevent()
      @_delayTimer = null
      return

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
