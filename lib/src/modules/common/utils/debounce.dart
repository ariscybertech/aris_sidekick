import 'dart:async';

import 'package:flutter/foundation.dart';

class Debouncer {
  final Duration duration;
  VoidCallback action;
  Timer _timer;
  Debouncer(this.duration);

  // Can cancel programatically
  void cancel() {
    if (_timer != null) _timer.cancel();
  }

  void run(VoidCallback action) {
    if (_timer != null) _timer.cancel();
    _timer = Timer(duration, action);
  }
}

class Throttle {
  final int milliseconds;
  VoidCallback action;
  Timer _timer;
  Throttle({this.milliseconds});

  void run(VoidCallback action) {
    if (_timer != null && _timer.isActive) return;
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
