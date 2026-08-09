import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/constants/app_spacing.dart';
import 'package:jobodia_frontend/core/widgets/blurred_header.dart';
import 'package:jobodia_frontend/features/applications/controller/applications_controller.dart';
import 'package:jobodia_frontend/features/applications/model/job_application.dart';
import 'package:jobodia_frontend/features/company/controller/company_controller.dart';
import 'package:jobodia_frontend/features/cv_builder/controller/cv_builder_controller.dart';
import 'package:jobodia_frontend/features/job_alerts/controller/job_alert_controller.dart';
import 'package:jobodia_frontend/features/saved_jobs/controller/saved_jobs_controller.dart';

/// A visual overview of the user's job-search activity.
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: BlurredHeader(
        child: FHeader.nested(
          title: const Text('Statistics'),
          prefixes: [FHeaderAction.back(onPress: () => Get.back<void>())],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Obx(() {
            final applications = Get.find<ApplicationsController>().applications
                .toList(growable: false);
            final saved = Get.find<SavedJobsController>().savedIds.length;
            final cvReady = Get.find<CvBuilderController>().isGenerated.value;
            final following = Get.find<CompanyController>().followingCount;
            final alerts = Get.isRegistered<JobAlertController>()
                ? Get.find<JobAlertController>().alerts
                      .where((alert) => alert.isActive)
                      .length
                : 0;

            return ListView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.sm,
                AppSpacing.xl,
                MediaQuery.paddingOf(context).bottom + AppSpacing.xxxl,
              ),
              children: [
                _ActivityPanel(applications: applications),
                const SizedBox(height: AppSpacing.xxl),
                const _SectionHeader(
                  title: 'At a glance',
                  subtitle: 'Your current job-search activity',
                ),
                const SizedBox(height: AppSpacing.md),
                _MetricsGrid(
                  saved: saved,
                  applied: applications.length,
                  following: following,
                  alerts: alerts,
                ),
                const SizedBox(height: AppSpacing.xxl),
                _SectionHeader(
                  title: 'Application pipeline',
                  subtitle: 'How your opportunities are progressing',
                  action: FButton(
                    variant: FButtonVariant.ghost,
                    onPress: () =>
                        Get.toNamed<void>(AppRoutes.applicationAnalytics),
                    child: const Text('Details'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _PipelinePanel(applications: applications),
                const SizedBox(height: AppSpacing.xxl),
                _CvReadinessTile(cvReady: cvReady),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _ActivityPanel extends StatelessWidget {
  const _ActivityPanel({required this.applications});

  final List<JobApplication> applications;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final palette = context.palette;
    final activity = _activityForLastSevenDays(applications);
    final total = activity.fold<int>(0, (sum, value) => sum + value);
    final maxValue = math.max(1, activity.fold<int>(0, math.max)).toDouble();
    final labels = _lastSevenDayLabels();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: palette.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.16 : 0.04),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly activity',
                      style: theme.typography.body.sm.copyWith(
                        color: palette.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$total',
                          style: theme.typography.display.xl2.copyWith(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w800,
                            height: 0.95,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text(
                            total == 1 ? 'application' : 'applications',
                            style: theme.typography.body.xs.copyWith(
                              color: palette.textTertiary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: theme.colors.primary.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FLucideIcons.calendarDays,
                      size: 14,
                      color: theme.colors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '7 days',
                      style: theme.typography.body.xs.copyWith(
                        color: theme.colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          SizedBox(
            height: 190,
            child: LineChart(
              _lineData(
                activity: activity,
                labels: labels,
                maxValue: maxValue,
                palette: palette,
                primary: theme.colors.primary,
                foreground: theme.colors.primaryForeground,
              ),
              duration: const Duration(milliseconds: 850),
              curve: Curves.easeOutCubic,
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _lineData({
    required List<int> activity,
    required List<String> labels,
    required double maxValue,
    required AppPalette palette,
    required Color primary,
    required Color foreground,
  }) {
    return LineChartData(
      minX: 0,
      maxX: 6,
      minY: 0,
      maxY: maxValue + math.max(1, maxValue * 0.28),
      clipData: const FlClipData.all(),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: math.max(1, maxValue / 3),
        getDrawingHorizontalLine: (_) => FlLine(
          color: palette.divider.withValues(alpha: 0.7),
          strokeWidth: 1,
          dashArray: [4, 5],
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              final index = value.round();
              if (index < 0 || index >= labels.length) {
                return const SizedBox.shrink();
              }
              final isToday = index == labels.length - 1;
              return SideTitleWidget(
                meta: meta,
                space: 9,
                child: Text(
                  labels[index],
                  style: TextStyle(
                    color: isToday ? palette.textPrimary : palette.textTertiary,
                    fontSize: 10,
                    fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBorderRadius: BorderRadius.circular(12),
          tooltipPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 7,
          ),
          fitInsideHorizontally: true,
          getTooltipColor: (_) => palette.textPrimary,
          getTooltipItems: (spots) => spots
              .map(
                (spot) => LineTooltipItem(
                  '${spot.y.round()} application${spot.y.round() == 1 ? '' : 's'}',
                  TextStyle(
                    color: palette.scaffold,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
              .toList(),
        ),
        getTouchedSpotIndicator: (barData, indexes) => indexes
            .map(
              (_) => TouchedSpotIndicatorData(
                FlLine(color: primary.withValues(alpha: 0.35), strokeWidth: 1),
                FlDotData(
                  show: true,
                  getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                    radius: 5,
                    color: primary,
                    strokeWidth: 3,
                    strokeColor: foreground,
                  ),
                ),
              ),
            )
            .toList(),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(
            activity.length,
            (index) => FlSpot(index.toDouble(), activity[index].toDouble()),
          ),
          isCurved: true,
          curveSmoothness: 0.34,
          preventCurveOverShooting: true,
          color: primary,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
              radius: spot.x == 6 ? 4 : 2.5,
              color: primary,
              strokeWidth: spot.x == 6 ? 3 : 2,
              strokeColor: palette.surface,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primary.withValues(alpha: 0.28),
                primary.withValues(alpha: 0.01),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.action,
  });

  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final palette = context.palette;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.typography.body.lg.copyWith(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.typography.body.xs.copyWith(
                  color: palette.textSecondary,
                ),
              ),
            ],
          ),
        ),
        ?action,
      ],
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({
    required this.saved,
    required this.applied,
    required this.following,
    required this.alerts,
  });

  final int saved;
  final int applied;
  final int following;
  final int alerts;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - AppSpacing.md) / 2;
        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _MetricButton(
              width: width,
              icon: FLucideIcons.bookmark,
              label: 'Saved jobs',
              value: saved,
              color: AppColors.chart2,
              onPress: () => Get.toNamed<void>(AppRoutes.savedJobs),
            ),
            _MetricButton(
              width: width,
              icon: FLucideIcons.send,
              label: 'Applications',
              value: applied,
              color: AppColors.brandPrimary,
              onPress: () => Get.toNamed<void>(AppRoutes.applications),
            ),
            _MetricButton(
              width: width,
              icon: FLucideIcons.building2,
              label: 'Following',
              value: following,
              color: AppColors.info,
              onPress: () {},
            ),
            _MetricButton(
              width: width,
              icon: FLucideIcons.bellRing,
              label: 'Active alerts',
              value: alerts,
              color: AppColors.warning,
              onPress: () => Get.toNamed<void>(AppRoutes.jobAlerts),
            ),
          ],
        );
      },
    );
  }
}

class _MetricButton extends StatelessWidget {
  const _MetricButton({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onPress,
  });

  final double width;
  final IconData icon;
  final String label;
  final int value;
  final Color color;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final palette = context.palette;
    return SizedBox(
      width: width,
      child: FButton.raw(
        variant: FButtonVariant.ghost,
        onPress: onPress,
        style: const FButtonStyleDelta.delta(
          contentStyle: FButtonContentStyleDelta.delta(
            constraints: BoxConstraints(minWidth: 0, minHeight: 0),
            padding: EdgeInsetsGeometryDelta.value(EdgeInsets.zero),
          ),
        ),
        child: Container(
          height: 116,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: palette.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 17),
                  ),
                  const Spacer(),
                  Icon(
                    FLucideIcons.arrowUpRight,
                    size: 16,
                    color: palette.iconMuted,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '$value',
                style: theme.typography.display.sm.copyWith(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.body.xs.copyWith(
                  color: palette.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PipelinePanel extends StatelessWidget {
  const _PipelinePanel({required this.applications});

  final List<JobApplication> applications;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final items = _pipelineItems(applications);
    final total = items.fold<int>(0, (sum, item) => sum + item.value);

    if (total == 0) {
      return FTileGroup(
        children: [
          FTile(
            prefix: const Icon(FLucideIcons.chartPie),
            title: const Text('No pipeline data yet'),
            subtitle: const Text(
              'Your progress will appear after you apply for a job.',
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: palette.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 340;
          final chart = _PipelineDonut(items: items, total: total);
          final legend = _PipelineLegend(items: items, total: total);
          return compact
              ? Column(
                  children: [
                    SizedBox(height: 190, child: chart),
                    const SizedBox(height: 18),
                    legend,
                  ],
                )
              : Row(
                  children: [
                    SizedBox(width: 176, height: 176, child: chart),
                    const SizedBox(width: 20),
                    Expanded(child: legend),
                  ],
                );
        },
      ),
    );
  }
}

class _PipelineDonut extends StatelessWidget {
  const _PipelineDonut({required this.items, required this.total});

  final List<_PipelineItem> items;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final palette = context.palette;
    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            startDegreeOffset: -90,
            sectionsSpace: 4,
            centerSpaceRadius: 53,
            borderData: FlBorderData(show: false),
            pieTouchData: PieTouchData(enabled: true),
            sections: [
              for (final item in items)
                if (item.value > 0)
                  PieChartSectionData(
                    value: item.value.toDouble(),
                    color: item.color,
                    radius: 22,
                    showTitle: false,
                    borderSide: BorderSide(color: palette.surface, width: 1.5),
                  ),
            ],
          ),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$total',
              style: theme.typography.display.sm.copyWith(
                color: palette.textPrimary,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'total',
              style: theme.typography.body.xs.copyWith(
                color: palette.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PipelineLegend extends StatelessWidget {
  const _PipelineLegend({required this.items, required this.total});

  final List<_PipelineItem> items;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final palette = context.palette;
    return Column(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: items[index].color,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  items[index].label,
                  style: theme.typography.body.xs.copyWith(
                    color: palette.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${items[index].value}',
                style: theme.typography.body.sm.copyWith(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 34,
                child: Text(
                  '${(items[index].value / total * 100).round()}%',
                  textAlign: TextAlign.right,
                  style: theme.typography.body.xs.copyWith(
                    color: palette.textTertiary,
                  ),
                ),
              ),
            ],
          ),
          if (index != items.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _CvReadinessTile extends StatelessWidget {
  const _CvReadinessTile({required this.cvReady});

  final bool cvReady;

  @override
  Widget build(BuildContext context) {
    return FTileGroup(
      label: const Text('Career readiness'),
      children: [
        FTile(
          prefix: Icon(
            cvReady ? FLucideIcons.circleCheckBig : FLucideIcons.fileText,
          ),
          title: Text(cvReady ? 'Your CV is ready' : 'Complete your CV'),
          subtitle: Text(
            cvReady
                ? 'Review or update your latest version.'
                : 'A polished CV helps you apply faster.',
          ),
          suffix: const Icon(FLucideIcons.chevronRight),
          onPress: () => Get.toNamed<void>(AppRoutes.cvBuilder),
        ),
      ],
    );
  }
}

class _PipelineItem {
  const _PipelineItem(this.label, this.value, this.color);

  final String label;
  final int value;
  final Color color;
}

List<_PipelineItem> _pipelineItems(List<JobApplication> applications) => [
  _PipelineItem(
    'Applied',
    _countStatus(applications, ApplicationStatus.applied),
    AppColors.info,
  ),
  _PipelineItem(
    'Screening',
    _countStatus(applications, ApplicationStatus.phoneScreen),
    AppColors.chart3,
  ),
  _PipelineItem(
    'Interview',
    _countStatus(applications, ApplicationStatus.interview),
    AppColors.warning,
  ),
  _PipelineItem(
    'Offer',
    _countStatus(applications, ApplicationStatus.offer),
    AppColors.success,
  ),
  _PipelineItem(
    'Rejected',
    _countStatus(applications, ApplicationStatus.rejected),
    AppColors.error,
  ),
];

int _countStatus(List<JobApplication> applications, ApplicationStatus status) =>
    applications
        .where((application) => application.statusEnum == status)
        .length;

List<int> _activityForLastSevenDays(List<JobApplication> applications) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return List.generate(7, (index) {
    final day = today.subtract(Duration(days: 6 - index));
    return applications.where((application) {
      final applied = application.appliedDate.toLocal();
      return applied.year == day.year &&
          applied.month == day.month &&
          applied.day == day.day;
    }).length;
  });
}

List<String> _lastSevenDayLabels() {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final today = DateTime.now();
  return List.generate(7, (index) {
    final day = today.subtract(Duration(days: 6 - index));
    return weekdays[day.weekday - 1];
  });
}
