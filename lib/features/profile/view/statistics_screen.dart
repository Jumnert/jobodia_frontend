import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/constants/app_spacing.dart';
import 'package:jobodia_frontend/core/widgets/animated_scale_button.dart';
import 'package:jobodia_frontend/features/applications/controller/applications_controller.dart';
import 'package:jobodia_frontend/features/applications/model/job_application.dart';
import 'package:jobodia_frontend/features/company/controller/company_controller.dart';
import 'package:jobodia_frontend/features/cv_builder/controller/cv_builder_controller.dart';
import 'package:jobodia_frontend/features/job_alerts/controller/job_alert_controller.dart';
import 'package:jobodia_frontend/features/saved_jobs/controller/saved_jobs_controller.dart';

/// A focused overview of the user's job-search activity.
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      body: ColoredBox(
        color: palette.scaffold,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _PageHeader(palette: palette),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Obx(() {
                      final applicationsController =
                          Get.find<ApplicationsController>();
                      final applications = applicationsController.applications
                          .toList();
                      final saved =
                          Get.find<SavedJobsController>().savedIds.length;
                      final cvReady =
                          Get.find<CvBuilderController>().isGenerated.value;
                      final following =
                          Get.find<CompanyController>().followingCount;
                      final alerts = Get.isRegistered<JobAlertController>()
                          ? Get.find<JobAlertController>().alerts
                                .where((alert) => alert.isActive)
                                .length
                          : 0;

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          AppSpacing.sm,
                          AppSpacing.xl,
                          AppSpacing.xxxl,
                        ),
                        children: [
                          _OverviewCard(
                            applications: applications,
                            palette: palette,
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          _SectionHeading(
                            title: 'Your activity',
                            subtitle: 'A quick view of your job search',
                            palette: palette,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _MetricsGrid(
                            saved: saved,
                            applied: applications.length,
                            following: following,
                            alerts: alerts,
                            palette: palette,
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          _SectionHeading(
                            title: 'Application pipeline',
                            subtitle: 'Where your applications stand',
                            trailing: _TextAction(
                              label: 'View details',
                              onTap: () => Get.toNamed<void>(
                                AppRoutes.applicationAnalytics,
                              ),
                            ),
                            palette: palette,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _PipelineCard(
                            applications: applications,
                            palette: palette,
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          _CvCard(cvReady: cvReady, palette: palette),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.md,
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Get.back<void>(),
              icon: const Icon(FLucideIcons.arrowLeft),
              color: palette.iconPrimary,
              tooltip: 'Back',
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Statistics',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.applications, required this.palette});

  final List<JobApplication> applications;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    final activity = _activityForLastSevenDays(applications);
    final thisWeek = activity.fold<int>(0, (sum, count) => sum + count);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.16 : 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
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
                      'APPLICATIONS THIS WEEK',
                      style: TextStyle(
                        color: palette.textTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '$thisWeek',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 38,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.brandTeal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FLucideIcons.calendar,
                      color: AppColors.brandTeal,
                      size: 14,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Last 7 days',
                      style: TextStyle(
                        color: AppColors.brandTeal,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          SizedBox(
            height: 122,
            child: _ActivityChart(
              values: activity,
              labels: _lastSevenDayLabels(),
              palette: palette,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityChart extends StatelessWidget {
  const _ActivityChart({
    required this.values,
    required this.labels,
    required this.palette,
  });

  final List<int> values;
  final List<String> labels;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    final maxValue = math.max(1, values.fold<int>(0, math.max));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(values.length, (index) {
        final isToday = index == values.length - 1;
        final barHeight = 18 + (values[index] / maxValue * 68);

        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    width: 22,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: isToday
                          ? AppColors.brandTeal
                          : AppColors.brandTeal.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                labels[index],
                style: TextStyle(
                  color: isToday ? palette.textPrimary : palette.textTertiary,
                  fontSize: 11,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.subtitle,
    required this.palette,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final AppPalette palette;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.25,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: TextStyle(color: palette.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
        ?trailing,
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
    required this.palette,
  });

  final int saved;
  final int applied;
  final int following;
  final int alerts;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - AppSpacing.md) / 2;

        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _MetricCard(
              width: width,
              icon: FLucideIcons.bookmark,
              label: 'Saved jobs',
              value: '$saved',
              color: AppColors.accentPurple,
              onTap: () => Get.toNamed<void>(AppRoutes.savedJobs),
              palette: palette,
            ),
            _MetricCard(
              width: width,
              icon: FLucideIcons.arrowUpRight,
              label: 'Applications',
              value: '$applied',
              color: AppColors.brandTeal,
              onTap: () => Get.toNamed<void>(AppRoutes.applications),
              palette: palette,
            ),
            _MetricCard(
              width: width,
              icon: FLucideIcons.building2,
              label: 'Following',
              value: '$following',
              color: AppColors.info,
              onTap: () {},
              palette: palette,
            ),
            _MetricCard(
              width: width,
              icon: FLucideIcons.bell,
              label: 'Active alerts',
              value: '$alerts',
              color: AppColors.warning,
              onTap: () => Get.toNamed<void>(AppRoutes.jobAlerts),
              palette: palette,
            ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
    required this.palette,
  });

  final double width;
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: AnimatedScaleButton(
        onTap: onTap,
        child: Container(
          height: 122,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(20),
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
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const Spacer(),
                  Icon(
                    FLucideIcons.arrowUpRight,
                    color: palette.iconMuted,
                    size: 17,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 24,
                  height: 1,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.textSecondary,
                  fontSize: 12,
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

class _PipelineCard extends StatelessWidget {
  const _PipelineCard({required this.applications, required this.palette});

  final List<JobApplication> applications;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    final items = <_PipelineItem>[
      _PipelineItem(
        label: 'Applied',
        value: _countStatus(applications, ApplicationStatus.applied),
        color: AppColors.info,
      ),
      _PipelineItem(
        label: 'Screening',
        value: _countStatus(applications, ApplicationStatus.phoneScreen),
        color: AppColors.accentPurple,
      ),
      _PipelineItem(
        label: 'Interview',
        value: _countStatus(applications, ApplicationStatus.interview),
        color: AppColors.warning,
      ),
      _PipelineItem(
        label: 'Offer',
        value: _countStatus(applications, ApplicationStatus.offer),
        color: AppColors.success,
      ),
    ];
    final maxValue = math.max(
      1,
      items.fold<int>(0, (current, item) => math.max(current, item.value)),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
      ),
      child: applications.isEmpty
          ? _EmptyPipeline(palette: palette)
          : Column(
              children: [
                for (var index = 0; index < items.length; index++) ...[
                  _PipelineRow(
                    item: items[index],
                    maxValue: maxValue,
                    palette: palette,
                  ),
                  if (index != items.length - 1)
                    const SizedBox(height: AppSpacing.lg),
                ],
              ],
            ),
    );
  }
}

class _PipelineRow extends StatelessWidget {
  const _PipelineRow({
    required this.item,
    required this.maxValue,
    required this.palette,
  });

  final _PipelineItem item;
  final int maxValue;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    final progress = item.value / maxValue;

    return Row(
      children: [
        SizedBox(
          width: 76,
          child: Text(
            item.label,
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              color: item.color,
              backgroundColor: palette.surfaceMuted,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        SizedBox(
          width: 24,
          child: Text(
            '${item.value}',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyPipeline extends StatelessWidget {
  const _EmptyPipeline({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.brandTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              FLucideIcons.chartBar,
              color: AppColors.brandTeal,
              size: 21,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No pipeline data yet',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Your progress will appear after you apply.',
                  style: TextStyle(color: palette.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CvCard extends StatelessWidget {
  const _CvCard({required this.cvReady, required this.palette});

  final bool cvReady;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return AnimatedScaleButton(
      onTap: () => Get.toNamed<void>(AppRoutes.cvBuilder),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (cvReady ? AppColors.success : AppColors.brandTeal)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                cvReady ? FLucideIcons.circleCheckBig : FLucideIcons.fileText,
                color: cvReady ? AppColors.success : AppColors.brandTeal,
                size: 23,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cvReady ? 'Your CV is ready' : 'Complete your CV',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    cvReady
                        ? 'Review or update your latest version'
                        : 'A polished CV helps you apply faster',
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(FLucideIcons.chevronRight, color: palette.iconMuted),
          ],
        ),
      ),
    );
  }
}

class _TextAction extends StatelessWidget {
  const _TextAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.brandTeal,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _PipelineItem {
  const _PipelineItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;
}

int _countStatus(List<JobApplication> applications, ApplicationStatus status) =>
    applications
        .where((application) => application.statusEnum == status)
        .length;

List<int> _activityForLastSevenDays(List<JobApplication> applications) {
  final today = DateTime.now();
  final startToday = DateTime(today.year, today.month, today.day);

  return List.generate(7, (index) {
    final day = startToday.subtract(Duration(days: 6 - index));
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
