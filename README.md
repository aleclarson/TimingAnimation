
# TimingAnimation 1.0.0 ![stable](https://img.shields.io/badge/stability-stable-4EBA0F.svg?style=flat)

An `Animation` subclass for `Easing`-based animations.

Uses [**aleclarson/Animated**](https://github.com/aleclarson/Animated) and [**aleclarson/easing**](https://github.com/aleclarson/easing).

*Made for React Native!*

```coffee
animation = TimingAnimation
  endValue: 0
  duration: 1000 # ms
  delay: 1000 # ms (optional)

animation.start
  startValue: 100
  onUpdate: (newValue) ->
  onEnd: (finished) ->
```

**TODO**: Write tests!?
