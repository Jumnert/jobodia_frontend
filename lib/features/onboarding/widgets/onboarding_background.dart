import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

class OnboardingBackground extends StatelessWidget {
  const OnboardingBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: Color(0xFF070707))),
        Positioned.fill(child: CustomPaint(painter: _SmokyBackgroundPainter())),
        Positioned(
          top: size.height * 0.34,
          left: -size.width * 0.35,
          right: -size.width * 0.35,
          child: Container(
            height: size.height * 0.34,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentPurple.withValues(alpha: 0.13),
                  blurRadius: 95,
                  spreadRadius: 18,
                ),
              ],
            ),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _SmokyBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF040405),
          Color(0xFF101011),
          Color(0xFF171718),
          Color(0xFF060607),
        ],
        stops: [0, 0.42, 0.68, 1],
      ).createShader(bounds);
    canvas.drawRect(bounds, background);

    final smoke = Paint()
      ..color = Colors.white.withValues(alpha: 0.062)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    final upperBand = Path()
      ..moveTo(-size.width * 0.28, size.height * 0.42)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.2,
        size.width * 1.2,
        size.height * 0.03,
      )
      ..lineTo(size.width * 1.28, size.height * 0.2)
      ..quadraticBezierTo(
        size.width * 0.33,
        size.height * 0.44,
        -size.width * 0.18,
        size.height * 0.68,
      )
      ..close();
    canvas.drawPath(upperBand, smoke);

    final lowerBand = Path()
      ..moveTo(-size.width * 0.25, size.height * 1.04)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.8,
        size.width * 1.18,
        size.height * 0.73,
      )
      ..lineTo(size.width * 1.22, size.height)
      ..quadraticBezierTo(
        size.width * 0.42,
        size.height * 0.92,
        -size.width * 0.16,
        size.height * 1.18,
      )
      ..close();
    canvas.drawPath(lowerBand, smoke);

    final glow = Paint()
      ..color = AppColors.accentPurpleDark.withValues(alpha: 0.13)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 86);
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.43),
      size.width * 0.25,
      glow,
    );
  }

  @override
  bool shouldRepaint(_SmokyBackgroundPainter oldDelegate) => false;
}
