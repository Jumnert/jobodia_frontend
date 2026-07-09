import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/animated_scale_button.dart';
import 'package:jobodia_frontend/features/applications/controller/applications_controller.dart';
import 'package:jobodia_frontend/features/company/controller/company_controller.dart';
import 'package:jobodia_frontend/features/cv_builder/controller/cv_builder_controller.dart';
import 'package:jobodia_frontend/features/job_alerts/controller/job_alert_controller.dart';
import 'package:jobodia_frontend/features/saved_jobs/controller/saved_jobs_controller.dart';

/// A dedicated overview of the user's activity stats, moved off the profile
/// page. Each row links to the relevant feature.
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final topInset = MediaQuery.paddingOf(context).top;

    return AdaptiveScaffold(
      body: Container(
        color: palette.scaffold,
        child: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Obx(() {
                    final saved =
                        Get.find<SavedJobsController>().savedIds.length;
                    final applied =
                        Get.find<ApplicationsController>().applications.length;
                    final cvReady =
                        Get.find<CvBuilderController>().isGenerated.value;
                    final following =
                        Get.find<CompanyController>().followingCount;
                    final alerts = Get.isRegistered<JobAlertController>()
                        ? Get.find<JobAlertController>().alerts
                              .where((a) => a.isActive)
                              .length
                        : 0;

                    return ListView(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        topInset + 14 + 44 + 20,
                        20,
                        32,
                      ),
                      children: [
                        _StatRow(
                          icon: Icons.bookmark_rounded,
                          label: 'Saved jobs',
                          value: '$saved',
                          onTap: () => Get.toNamed<void>(AppRoutes.savedJobs),
                          palette: palette,
                        ),
                        _StatRow(
                          icon: Icons.send_rounded,
                          label: 'Applications',
                          value: '$applied',
                          onTap: () =>
                              Get.toNamed<void>(AppRoutes.applications),
                          palette: palette,
                        ),
                        _StatRow(
                          icon: Icons.description_rounded,
                          label: 'CV',
                          value: cvReady ? 'Ready' : 'Not yet',
                          onTap: () => Get.toNamed<void>(AppRoutes.cvBuilder),
                          palette: palette,
                        ),
                        _StatRow(
                          icon: Icons.apartment_rounded,
                          label: 'Following',
                          value: '$following',
                          onTap: () {},
                          palette: palette,
                        ),
                        _StatRow(
                          icon: Icons.notifications_active_rounded,
                          label: 'Job alerts',
                          value: '$alerts',
                          onTap: () => Get.toNamed<void>(AppRoutes.jobAlerts),
                          palette: palette,
                        ),
                        const SizedBox(height: 8),
                        _StatRow(
                          icon: Icons.analytics_rounded,
                          label: 'Application analytics',
                          value: '',
                          onTap: () =>
                              Get.toNamed<void>(AppRoutes.applicationAnalytics),
                          palette: palette,
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            // ── Floating glass toolbar ──
            Positioned(
              top: topInset + 14,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  AdaptiveButton.icon(
                    onPressed: () => Get.back<void>(),
                    icon: PlatformInfo.isIOS
                        ? Icons.arrow_back_ios_new_rounded
                        : Icons.arrow_back_rounded,
                    iconColor: palette.iconPrimary,
                    style: AdaptiveButtonStyle.glass,
                    minSize: const Size(44, 44),
                    useSmoothRectangleBorder: false,
                  ),
                  const Spacer(),
                  AdaptiveButton(
                    onPressed: () {},
                    label: 'Statistics',
                    textColor: palette.textPrimary,
                    style: AdaptiveButtonStyle.glass,
                    minSize: const Size(150, 44),
                    useSmoothRectangleBorder: false,
                  ),
                  const Spacer(),
                  const SizedBox(width: 44),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    required this.palette,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedScaleButton(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.border),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (value.isNotEmpty) ...[
                Text(
                  value,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Icon(Icons.chevron_right_rounded, color: palette.iconMuted),
            ],
          ),
        ),
      ),
    );
  }
}
