import 'package:flutter/material.dart';

/// Wraps a child widget so that tapping anywhere outside a text field
/// dismisses the keyboard.
class DismissKeyboardWrapper extends StatelessWidget {
  const DismissKeyboardWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}
