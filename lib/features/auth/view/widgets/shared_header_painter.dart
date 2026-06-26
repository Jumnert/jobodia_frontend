import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

/// Reusable gradient header background painter for auth screens.
///
/// Draws a dark gradient rectangle with a decorative translucent curved band,
/// used on the login, OTP verification, and reset-password screens.
class HeaderBackgroundPainter extends CustomPainter {
  const HeaderBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.headerStart, AppColors.headerEnd],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, background);

    final light = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    final band = Path()
      ..moveTo(-55, size.height * 1.1)
      ..quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.55,
        size.width * 0.72,
        -30,
      )
      ..lineTo(size.width * 0.88, -30)
      ..quadraticBezierTo(
        size.width * 0.58,
        size.height * 0.68,
        -5,
        size.height * 1.25,
      )
      ..close();
    canvas.drawPath(band, light);
  }

  @override
  bool shouldRepaint(HeaderBackgroundPainter oldDelegate) => false;
}
