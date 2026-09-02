import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_spacing.dart';

/// Applies the app's standard content gutter together with device-safe insets.
///
/// Use this at page and section boundaries instead of combining [SafeArea],
/// [MediaQuery.paddingOf], and hand-written edge padding in each screen.
class SafeContentPadding extends StatelessWidget {
  const SafeContentPadding({
    required this.child,
    this.safeTop = true,
    this.safeBottom = true,
    this.safeLeft = true,
    this.safeRight = true,
    this.maintainBottomViewPadding = false,
    super.key,
  });

  final Widget child;
  final bool safeTop;
  final bool safeBottom;
  final bool safeLeft;
  final bool safeRight;
  final bool maintainBottomViewPadding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: safeTop,
      bottom: safeBottom,
      left: safeLeft,
      right: safeRight,
      maintainBottomViewPadding: maintainBottomViewPadding,
      minimum: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      child: child,
    );
  }
}
