import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/applications/controller/applications_controller.dart';
import 'package:jobodia_frontend/features/applications/model/job_application.dart';

class ApplicationAnalyticsScreen extends StatelessWidget {
  const ApplicationAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final apps = Get.find<ApplicationsController>();

    return Scaffold(
      backgroundColor: palette.scaffold,
      appBar: AppBar(
        backgroundColor: palette.scaffold,
        elevation: 0,
        leading: IconButton(
          onPressed: Get.back,
          tooltip: 'Back',
          icon: Icon(
            Icons.chevron_left_rounded,
            size: 30,
            color: palette.textPrimary,
          ),
        ),
        title: Text(
          'Application Analytics',
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        final applications = apps.applications;
        final total = applications.length;

        if (total == 0) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 64,
                  color: palette.textTertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No applications yet',
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Apply to jobs to see your analytics',
                  style: TextStyle(color: palette.textTertiary, fontSize: 13),
                ),
              ],
            ),
          );
        }

        final activeCount = applications
            .where((a) => a.status != 'rejected')
            .length;
        final avgDays =
            applications
                .map((a) => DateTime.now().difference(a.appliedDate).inDays)
                .reduce((a, b) => a + b) /
            total;

        // Weekly grouping (last 4 weeks)
        final now = DateTime.now();
        final weeklyCounts = List.generate(4, (weekIndex) {
          final weekStart = now.subtract(Duration(days: (weekIndex + 1) * 7));
          final weekEnd = now.subtract(Duration(days: weekIndex * 7));
          return applications
              .where(
                (a) =>
                    a.appliedDate.isAfter(weekStart) &&
                    a.appliedDate.isBefore(weekEnd),
              )
              .length;
        }).reversed.toList();

        final maxWeekly = weeklyCounts.isEmpty
            ? 1
            : weeklyCounts.reduce((a, b) => a > b ? a : b).clamp(1, 999);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary cards row
              Row(
                children: [
                  _StatCard(
                    label: 'Total Applied',
                    value: '$total',
                    icon: Icons.send_rounded,
                    palette: palette,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    label: 'Active',
                    value: '$activeCount',
                    icon: Icons.trending_up_rounded,
                    palette: palette,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    label: 'Avg. Days',
                    value: '${avgDays.round()}',
                    icon: Icons.schedule_rounded,
                    palette: palette,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Weekly chart
              Text(
                'Applications by Week',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 160,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _BarChartPainter(
                    values: weeklyCounts,
                    maxValue: maxWeekly,
                    barColor: AppColors.primary,
                    bgColor: palette.surfaceMuted,
                    textColor: palette.textTertiary,
                    labels: ['4 wk ago', '3 wk ago', '2 wk ago', 'This week'],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Status breakdown
              Text(
                'Status Breakdown',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ..._buildStatusBreakdown(applications, palette),
            ],
          ),
        );
      }),
    );
  }

  List<Widget> _buildStatusBreakdown(
    List<JobApplication> applications,
    AppPalette palette,
  ) {
    const statuses = [
      'applied',
      'phone_screen',
      'interview',
      'offer',
      'rejected',
    ];
    const labels = {
      'applied': 'Applied',
      'phone_screen': 'Phone Screen',
      'interview': 'Interview',
      'offer': 'Offer',
      'rejected': 'Rejected',
    };
    final colors = {
      'applied': palette.info,
      'phone_screen': palette.warning,
      'interview': AppColors.accentPurple,
      'offer': palette.success,
      'rejected': palette.error,
    };

    return statuses.map((status) {
      final count = applications.where((a) => a.status == status).length;
      final fraction = applications.isEmpty ? 0.0 : count / applications.length;
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              child: Text(
                labels[status]!,
                style: TextStyle(
                  color: palette.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: fraction,
                  minHeight: 10,
                  backgroundColor: palette.surfaceMuted,
                  color: colors[status],
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 30,
              child: Text(
                '$count',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.palette,
  });

  final String label;
  final String value;
  final IconData icon;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: palette.textTertiary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({
    required this.values,
    required this.maxValue,
    required this.barColor,
    required this.bgColor,
    required this.textColor,
    required this.labels,
  });

  final List<int> values;
  final int maxValue;
  final Color barColor;
  final Color bgColor;
  final Color textColor;
  final List<String> labels;

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = (size.width / values.length) * 0.5;
    final spacing = size.width / values.length;

    for (var i = 0; i < values.length; i++) {
      final x = i * spacing + (spacing - barWidth) / 2;
      final barHeight = maxValue > 0
          ? (values[i] / maxValue) * (size.height - 30)
          : 0.0;
      final y = size.height - 30 - barHeight;

      // Background bar
      final bgRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 0, barWidth, size.height - 30),
        const Radius.circular(6),
      );
      canvas.drawRRect(bgRect, Paint()..color = bgColor);

      // Value bar
      if (barHeight > 0) {
        final barRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(6),
        );
        canvas.drawRRect(barRect, Paint()..color = barColor);
      }

      // Label
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: textColor,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + (barWidth - tp.width) / 2, size.height - 22));

      // Value on top
      if (values[i] > 0) {
        final vp = TextPainter(
          text: TextSpan(
            text: '${values[i]}',
            style: TextStyle(
              color: barColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        vp.paint(canvas, Offset(x + (barWidth - vp.width) / 2, y - 14));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) =>
      old.values != values ||
      old.maxValue != maxValue ||
      old.barColor != barColor;
}
