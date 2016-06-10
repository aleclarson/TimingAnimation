var AnimatedValue, Animation, Easing, LazyVar, Type, getArgProp, ref, type;

ref = require("Animated"), AnimatedValue = ref.AnimatedValue, Animation = ref.Animation;

getArgProp = require("getArgProp");

LazyVar = require("lazy-var");

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
  computeValueAtTime: function(time) {
    var progress;
    progress = this.computeProgressAtTime(time);
    return this.computeValueAtProgress(progress);
  },
  computeProgressAtTime: function(time) {
    if (time <= 0) {
      return this.easing(0);
    }
    if (time >= this.duration) {
      return this.easing(1);
    }
    return this.easing(time / this.duration);
  }
});

type.overrideMethods({
  __computeValue: function() {
    this._lastTime = this.time;
    this._lastValue = this.value;
    this.time = Math.min(this.duration, Date.now() - this.startTime);
    this.value = this.computeValueAtTime(this.time);
    this._velocity.reset();
    return this.value;
  },
  __didComputeValue: function(value) {
    if (this.time === this.duration) {
      return this.finish();
    }
  },
  __onStart: function() {
    if (this.delay > 0) {
      return this._timer = Timer(this.delay, (function(_this) {
        return function() {
          return _this.__onStart();
        };
      })(this));
    } else {
      this._timer = null;
      if (this.duration === 0) {
        this._onUpdate(this.computeValueAtProgress(1));
        return this.finish();
      } else {
        this.startTime = Date.now();
        return this._requestAnimationFrame();
      }
    }
  },
  __onEnd: function() {
    if (!this._timer) {
      return;
    }
    this._timer.prevent();
    return this._timer = null;
  }
});

module.exports = type.build();

//# sourceMappingURL=../../map/src/TimingAnimation.map
