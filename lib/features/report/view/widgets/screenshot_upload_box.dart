import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

/// Static screenshot upload placeholder for the Report screen.
class ScreenshotUploadBox extends StatelessWidget {
  const ScreenshotUploadBox({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _DashedBorderPainter(),
      child: const SizedBox.square(
        dimension: 82,
        child: Icon(
          Icons.add_rounded,
          color: AppColors.textSecondary,
          size: 30,
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const dashLength = 5.0;
    const gapLength = 4.0;
    const radius = Radius.circular(12);
    final paint = Paint()
      ..color = AppColors.hint
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(Offset.zero & size, radius));

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashLength),
          paint,
        );
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) => false;
}
