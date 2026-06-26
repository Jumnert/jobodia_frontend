import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

class SalaryChartPainter extends CustomPainter {
  const SalaryChartPainter({
    required this.minSalary,
    required this.maxSalary,
    required this.medianSalary,
    required this.expectedSalary,
    required this.textColor,
    required this.mutedColor,
  });

  final double minSalary;
  final double maxSalary;
  final double medianSalary;
  final double expectedSalary;
  final Color textColor;
  final Color mutedColor;

  @override
  void paint(Canvas canvas, Size size) {
    final barHeight = 24.0;
    final topPadding = size.height / 2 - barHeight / 2;

    // Draw background track
    final bgPaint = Paint()
      ..color = mutedColor.withAlpha(50)
      ..style = PaintingStyle.fill;

    final bgRect = RRect.fromLTRBR(
      0,
      topPadding,
      size.width,
      topPadding + barHeight,
      const Radius.circular(12),
    );
    canvas.drawRRect(bgRect, bgPaint);

    // Calculate positions
    final range = maxSalary - minSalary;
    final medianNorm = (medianSalary - minSalary) / range;
    final expectedNorm = (expectedSalary - minSalary) / range;

    // Draw Median range (let's say 25th to 75th percentile approx)
    final p25 = minSalary + range * 0.25;
    final p75 = minSalary + range * 0.75;
    final p25Norm = (p25 - minSalary) / range;
    final p75Norm = (p75 - minSalary) / range;

    final rangePaint = Paint()
      ..color = AppColors.brandTeal.withAlpha(100)
      ..style = PaintingStyle.fill;
    final rangeRect = RRect.fromLTRBR(
      size.width * p25Norm,
      topPadding,
      size.width * p75Norm,
      topPadding + barHeight,
      const Radius.circular(12),
    );
    canvas.drawRRect(rangeRect, rangePaint);

    // Draw expected salary dot
    final expectedX = size.width * expectedNorm;
    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(expectedX, topPadding + barHeight / 2),
      10,
      dotPaint,
    );

    // Draw dot stroke
    final dotStroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(
      Offset(expectedX, topPadding + barHeight / 2),
      10,
      dotStroke,
    );

    // Draw Median Line
    final medianX = size.width * medianNorm;
    final medianLinePaint = Paint()
      ..color = AppColors.warning
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawLine(
      Offset(medianX, topPadding - 10),
      Offset(medianX, topPadding + barHeight + 10),
      medianLinePaint,
    );

    // Text labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Helper to draw text
    void drawText(
      String text,
      double x,
      double y,
      Color color, {
      bool isAbove = false,
    }) {
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      final dx = x - textPainter.width / 2;
      final dy = isAbove ? y - textPainter.height - 4 : y + 4;
      textPainter.paint(canvas, Offset(dx, dy));
    }

    drawText(
      '\$${(minSalary / 1000).toStringAsFixed(0)}k',
      10,
      topPadding + barHeight,
      mutedColor,
    );
    drawText(
      '\$${(maxSalary / 1000).toStringAsFixed(0)}k',
      size.width - 10,
      topPadding + barHeight,
      mutedColor,
    );
    drawText(
      'Expected',
      expectedX,
      topPadding + barHeight + 10,
      AppColors.primary,
    );
    drawText(
      'Median',
      medianX,
      topPadding - 14,
      AppColors.warning,
      isAbove: true,
    );
  }

  @override
  bool shouldRepaint(covariant SalaryChartPainter oldDelegate) {
    return oldDelegate.minSalary != minSalary ||
        oldDelegate.maxSalary != maxSalary ||
        oldDelegate.medianSalary != medianSalary ||
        oldDelegate.expectedSalary != expectedSalary;
  }
}
