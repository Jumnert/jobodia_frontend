import 'package:flutter/material.dart';

class AppAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;
  static const Curve easeOutCubic = Curves.easeOutCubic;
}
