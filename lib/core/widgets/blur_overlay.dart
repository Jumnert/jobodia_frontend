import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

class BlurOverlay extends StatelessWidget {
  const BlurOverlay({
    super.key,
    required this.child,
    this.sigmaX = 10.0,
    this.sigmaY = 10.0,
    this.colorOpacity = 0.1,
  });

  final Widget child;
  final double sigmaX;
  final double sigmaY;
  final double colorOpacity;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: Container(
          color: palette.scaffold.withValues(alpha: colorOpacity),
          child: child,
        ),
      ),
    );
  }
}
