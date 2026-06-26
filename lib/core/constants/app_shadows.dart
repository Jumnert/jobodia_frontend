import 'package:flutter/material.dart';

class AppShadows {
  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x0A000000), offset: Offset(0, 2), blurRadius: 4),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x0F000000), offset: Offset(0, 4), blurRadius: 8),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x14000000), offset: Offset(0, 8), blurRadius: 16),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 12), blurRadius: 24),
  ];
}
