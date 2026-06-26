// ignore_for_file: deprecated_member_use, avoid_print, curly_braces_in_flow_control_structures, unused_import, unnecessary_underscores, unused_field, unused_local_variable, use_build_context_synchronously, duplicate_ignore
// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/market_trends/controller/market_trends_controller.dart';
import 'dart:math' as math;

class MarketTrendsScreen extends StatelessWidget {
  const MarketTrendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final ctrl = Get.put(MarketTrendsController());

    return Scaffold(
      backgroundColor: palette.scaffold,
      appBar: AppBar(
        backgroundColor: palette.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            color: palette.iconPrimary,
            size: 30,
          ),
          onPressed: Get.back,
        ),
        title: Column(
          children: [
            Text(
              'Job Market Insights',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Updated weekly',
              style: TextStyle(color: palette.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
      body: Obx(() {
        final industries = ctrl.topIndustries();
        final skills = ctrl.topSkills();
        final fit = ctrl.userMarketFit();

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _MarketFitCard(fit: fit, palette: palette),
            const SizedBox(height: 32),
            Text(
              'Top Hiring Industries',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            ...industries.map(
              (ind) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DemandBarChart(
                  label: ind.name,
                  score: ind.demandScore,
                  palette: palette,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Skills in Demand',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: skills
                  .map(
                    (s) => _SkillBadge(
                      skill: s.name,
                      score: s.demandScore,
                      trend: s.trend,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 32),
            Text(
              'Salary Trends (Median)',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: CustomPaint(
                painter: _SalaryLineChartPainter(
                  lineColor: AppColors.brandTeal,
                  gridColor: palette.border,
                  textColor: palette.textTertiary,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        );
      }),
    );
  }
}

class _MarketFitCard extends StatelessWidget {
  const _MarketFitCard({required this.fit, required this.palette});
  final int fit;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    Color ringColor;
    if (fit >= 70) {
      ringColor = AppColors.success;
    } else if (fit >= 50)
      ringColor = AppColors.warning;
    else
      ringColor = AppColors.error;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [palette.surface, palette.surface.withAlpha(200)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CustomPaint(
              painter: _MarketFitRingPainter(
                percent: fit,
                color: ringColor,
                bgColor: palette.border,
              ),
              child: Center(
                child: Text(
                  '$fit%',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Market Fit',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your skills match $fit% of the top-demand roles this month.',
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketFitRingPainter extends CustomPainter {
  _MarketFitRingPainter({
    required this.percent,
    required this.color,
    required this.bgColor,
  });
  final int percent;
  final Color color;
  final Color bgColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2);

    final bgPaint = Paint()
      ..color = bgColor
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = color
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final sweepAngle = 2 * math.pi * (percent / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DemandBarChart extends StatelessWidget {
  const _DemandBarChart({
    required this.label,
    required this.score,
    required this.palette,
  });
  final String label;
  final int score;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: palette.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            Text(
              score.toString(),
              style: TextStyle(
                color: palette.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: palette.surfaceMuted,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: score / 100,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.brandTeal, Color(0xFF00C4B4)],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SkillBadge extends StatelessWidget {
  const _SkillBadge({
    required this.skill,
    required this.score,
    required this.trend,
  });
  final String skill;
  final int score;
  final String trend;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    if (score >= 80) {
      bg = AppColors.success.withAlpha(20);
      fg = AppColors.success;
    } else if (score >= 60) {
      bg = AppColors.warning.withAlpha(20);
      fg = AppColors.warning;
    } else {
      bg = const Color(0xFF9CA3AF).withAlpha(20);
      fg = const Color(0xFF9CA3AF);
    }

    IconData icon = Icons.trending_flat_rounded;
    if (trend == 'rising') icon = Icons.trending_up_rounded;
    if (trend == 'declining') icon = Icons.trending_down_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 6),
          Icon(icon, color: fg, size: 14),
        ],
      ),
    );
  }
}

class _SalaryLineChartPainter extends CustomPainter {
  _SalaryLineChartPainter({
    required this.lineColor,
    required this.gridColor,
    required this.textColor,
  });
  final Color lineColor;
  final Color gridColor;
  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Mock data points (Q1 to Q4)
    final data = [80.0, 85.0, 82.0, 95.0];
    final minData = 70.0;
    final maxData = 100.0;
    final labels = ['Q1', 'Q2', 'Q3', 'Q4'];

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw horizontal grid lines
    final int rows = 3;
    for (int i = 0; i <= rows; i++) {
      final y = size.height - (i * (size.height / rows));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final pointWidth = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * pointWidth;
      final normalizedY = (data[i] - minData) / (maxData - minData);
      final y = size.height - (normalizedY * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Draw dot
      canvas.drawCircle(Offset(x, y), 5, dotPaint);

      // Draw label (simplified using TextPainter)
      final textSpan = TextSpan(
        text: labels[i],
        style: TextStyle(color: textColor, fontSize: 11),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - (textPainter.width / 2), size.height + 8),
      );
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
