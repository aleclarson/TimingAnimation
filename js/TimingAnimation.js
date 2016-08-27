var Animation, Easing, LazyVar, Timer, Type, type;

Animation = require("Animated").Animation;

LazyVar = require("LazyVar");

Easing = require("easing");

Timer = require("timer");

Type = require("Type");

type = Type("TimingAnimation");

type.inherits(Animation);

type.defineOptions({
  endValue: Number.isRequired,
  duration: Number.isRequired,
  easing: Function.withDefault(Easing.get("linear")),
  delay: Number.withDefault(0)
});

type.defineFrozenValues(function(options) {
  return {
    endValue: options.endValue,
    duration: options.duration,
    easing: options.easing,
    delay: options.delay,
    _velocity: LazyVar((function(_this) {
      return function() {
        return (_this.value - _this._lastValue) / (_this.time - _this._lastTime);
      };
    })(this))
  };
});

type.defineValues({
  progress: 0,
  time: null,
  value: null,
  _lastTime: null,
  _lastValue: null,
  _delayTimer: null
});

type.defineGetters({
  velocity: function() {
    return this._velocity.get();
  }
});

type.defineMethods({
  _valueAtProgress: function(progress) {
    return this.startValue + progress * (this.endValue - this.startValue);
  },
  _progressAtTime: function(time) {
    if (time <= 0) {
      return this.easing(0);
    }
    if (time >= this.duration) {
      return this.easing(1);
    }
    return this.easing(time / this.duration);
  },
  _start: function(config) {
    this.time = this.startTime = Date.now();
    this.value = this.startValue = config.startValue;
    this._delayTimer = null;
    if (this.duration > 0) {
      this._requestAnimationFrame();
      return;
    }
    this._onUpdate(this._valueAtProgress(1));
    this.finish();
  }
});

type.overrideMethods({
  __computeValue: function() {
    this._lastTime = this.time;
    this._lastValue = this.value;
    this._velocity.reset();
    this.time = Math.min(this.duration, Date.now() - this.startTime);
    this.progress = this._progressAtTime(this.time);
    return this.value = this._valueAtProgress(this.progress);
  },
  __didStart: function(config) {
    if (this.delay > 0) {
      return this._delayTimer = Timer(this.delay, (function(_this) {
        return function() {
          return _this._start(config);
        };
      })(this));
    } else {
      return this._start(config);
    }
  },
  __didUpdate: function(value) {
    if (this.time === this.duration) {
      return this.finish();
    }
  },
  __didEnd: function() {
    if (!this._delayTimer) {
      return;
    }
    this._delayTimer.prevent();
    return this._delayTimer = null;
  },
  __captureFrame: function() {
    return {
      value: this.value,
      time: this.time,
      progress: this.progress
    };
  }
});

module.exports = type.build();

//# sourceMappingURL=map/TimingAnimation.map
