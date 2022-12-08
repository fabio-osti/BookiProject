import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CrossPlatformScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.mouse,
    PointerDeviceKind.touch
  };
}