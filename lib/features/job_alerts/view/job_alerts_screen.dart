import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/empty_state.dart';
import 'package:jobodia_frontend/features/job_alerts/controller/job_alert_controller.dart';
import 'package:jobodia_frontend/features/job_alerts/view/widgets/create_alert_sheet.dart';

class JobAlertsScreen extends StatelessWidget {
  const JobAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final ctrl = Get.find<JobAlertController>();

    return Scaffold(
      backgroundColor: palette.scaffold,
      appBar: AppBar(
        backgroundColor: palette.scaffold,
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
        title: Text(
          'Job Alerts',
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Obx(() {
        if (ctrl.alerts.isEmpty) {
          return EmptyState(
            icon: Icons.notifications_active_outlined,
            title: 'No job alerts yet',
            subtitle: 'Get notified when new jobs match your criteria',
            actionLabel: 'Create alert',
            onAction: () => _showCreateSheet(context),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ctrl.checkForNewMatches();
            await Future<void>.delayed(const Duration(milliseconds: 800));
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: ctrl.alerts.length + 1, // +1 for the top summary text
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your Alerts',
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _showCreateSheet(context),
                        icon: const Icon(
                          Icons.add_rounded,
                          size: 20,
                          color: AppColors.brandTeal,
                        ),
                        label: const Text(
                          'New Alert',
                          style: TextStyle(
                            color: AppColors.brandTeal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final alert = ctrl.alerts[index - 1];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: palette.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            alert.name,
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Switch.adaptive(
                          value: alert.isActive,
                          onChanged: (_) => ctrl.toggleAlert(alert.id),
                          activeTrackColor: AppColors.brandTeal,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final kw in alert.keywords)
                          _Chip(label: kw, icon: Icons.tag, palette: palette),
                        if (alert.location != null &&
                            alert.location!.isNotEmpty)
                          _Chip(
                            label: alert.location!,
                            icon: Icons.location_on,
                            palette: palette,
                          ),
                        if (alert.level != null && alert.level!.isNotEmpty)
                          _Chip(
                            label: alert.level!,
                            icon: Icons.work,
                            palette: palette,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            Get.dialog(
                              AlertDialog(
                                backgroundColor: palette.surface,
                                title: Text(
                                  'Delete alert?',
                                  style: TextStyle(color: palette.textPrimary),
                                ),
                                content: Text(
                                  'You will no longer receive notifications for this alert.',
                                  style: TextStyle(
                                    color: palette.textSecondary,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: Get.back,
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: palette.textSecondary,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      ctrl.deleteAlert(alert.id);
                                      Get.back();
                                    },
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(color: palette.error),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: palette.error,
                          ),
                          label: Text(
                            'Delete',
                            style: TextStyle(color: palette.error),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateAlertSheet(),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.icon, required this.palette});
  final String label;
  final IconData icon;
  final dynamic palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: palette.iconMuted),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
