var Animation, Easing, LazyVar, Type, getArgProp, type;

Animation = require("Animated").Animation;

getArgProp = require("getArgProp");

LazyVar = require("LazyVar");

Easing = require("easing");

Type = require("Type");

type = Type("TimingAnimation");

type.inherits(Animation);

type.optionTypes = {
  endValue: Number,
  duration: Number,
  easing: Function,
  delay: Number
};

type.optionDefaults = {
  easing: Easing("linear"),
  delay: 0
};

type.defineFrozenValues({
  endValue: getArgProp("endValue"),
  duration: getArgProp("duration"),
  easing: getArgProp("easing"),
  delay: getArgProp("delay"),
  _velocity: function() {
    return LazyVar((function(_this) {
      return function() {
        return (_this.value - _this._lastValue) / (_this.time - _this._lastTime);
      };
    })(this));
  }
});

type.defineValues({
  progress: 0,
  time: null,
  value: null,
  _timer: null,
  _lastTime: null,
  _lastValue: null
});

type.exposeLazyGetters(["velocity"]);

type.defineMethods({
  computeValueAtProgress: function(progress) {
    return this.startValue + progress * (this.endValue - this.startValue);
  },
  computeProgressAtTime: function(time) {
    if (time <= 0) {
      return this.easing(0);
    }
    if (time >= this.duration) {
      return this.easing(1);
    }
    return this.easing(time / this.duration);
  },
  _start: function() {
    this._timer = null;
    if (this.duration === 0) {
      this._onUpdate(this.computeValueAtProgress(1));
      this.finish();
      return;
    }
    this.startTime = Date.now();
    return this._requestAnimationFrame();
  }
});

type.overrideMethods({
  __computeValue: function() {
    this._lastTime = this.time;
    this._lastValue = this.value;
    this._velocity.reset();
    this.time = Math.min(this.duration, Date.now() - this.startTime);
    this.progress = this.computeProgressAtTime(this.time);
    return this.value = this.computeValueAtProgress(this.progress);
  },
  __didStart: function() {
    if (this.delay <= 0) {
      return this._start();
    }
    return this._timer = Timer(this.delay, (function(_this) {
      return function() {
        return _this._start();
      };
    })(this));
  },
  __didUpdate: function(value) {
    if (this.time === this.duration) {
      return this.finish();
    }
  },
  __didEnd: function() {
    if (!this._timer) {
      return;
    }
    this._timer.prevent();
    return this._timer = null;
  },
  __captureFrame: function() {
    return {
      progress: this.progress,
      value: this.value,
      time: this.time
    };
  }
});

module.exports = type.build();

//# sourceMappingURL=../../map/src/TimingAnimation.map
