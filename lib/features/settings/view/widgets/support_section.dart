import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/features/settings/view/widgets/settings_helpers.dart';

class SupportSection extends StatelessWidget {
  const SupportSection({
    super.key,
    required this.foregroundColor,
    required this.groupColor,
    required this.borderColor,
    required this.isDark,
    required this.onFeedbackTap,
    required this.onClearCacheTap,
    required this.onFaqTap,
  });

  final Color foregroundColor;
  final Color groupColor;
  final Color borderColor;
  final bool isDark;
  final VoidCallback onFeedbackTap;
  final VoidCallback onClearCacheTap;
  final VoidCallback onFaqTap;

  @override
  Widget build(BuildContext context) {
    final mutedColor = isDark
        ? const Color(0xFFA5ABB1)
        : const Color(0xFF84888D);
    return Column(
      children: [
        SettingsGroup(
          color: groupColor,
          borderColor: borderColor,
          children: [
            SettingsTile(
              icon: Icons.notifications_active_outlined,
              title: 'Job Alerts',
              foregroundColor: foregroundColor,
              showChevron: true,
              onTap: () => Get.toNamed<void>(AppRoutes.jobAlerts),
            ),
            SettingsTile(
              icon: Icons.thumb_up_alt_outlined,
              title: 'Leave feedback',
              subtitle: 'Help us improve the app experience.',
              foregroundColor: foregroundColor,
              mutedColor: mutedColor,
              onTap: onFeedbackTap,
            ),
            SettingsTile(
              icon: Icons.public_rounded,
              title: 'Clear cache',
              foregroundColor: foregroundColor,
              onTap: onClearCacheTap,
            ),
            SettingsTile(
              icon: Icons.help_outline_rounded,
              title: 'FAQ',
              foregroundColor: foregroundColor,
              showChevron: true,
              onTap: onFaqTap,
            ),
            SettingsTile(
              icon: Icons.star_border_rounded,
              title: 'Pricing Plan',
              foregroundColor: foregroundColor,
              showChevron: true,
              onTap: () => Get.toNamed<void>(AppRoutes.pricing),
            ),
          ],
        ),
      ],
    );
  }
}
