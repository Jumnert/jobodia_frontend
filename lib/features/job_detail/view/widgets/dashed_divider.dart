import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

class DashedDivider extends StatelessWidget {
  const DashedDivider({
    super.key,
    this.color,
    this.height = 1,
    this.dashWidth = 3.0,
    this.gap = 3.0,
  });

  final Color? color;
  final double height;
  final double dashWidth;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _DashedDividerPainter(
          color: color ?? context.palette.divider,
          height: height,
          dashWidth: dashWidth,
          gap: gap,
        ),
      ),
    );
  }
}

class _DashedDividerPainter extends CustomPainter {
  const _DashedDividerPainter({
    required this.color,
    required this.height,
    required this.dashWidth,
    required this.gap,
  });

  final Color color;
  final double height;
  final double dashWidth;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = height;
    var startX = 0.0;
    final y = size.height / 2;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, y),
        Offset((startX + dashWidth).clamp(0, size.width), y),
        paint,
      );
      startX += dashWidth + gap;
    }
  }

  @override
  bool shouldRepaint(_DashedDividerPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.height != height ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.gap != gap;
  }
}
