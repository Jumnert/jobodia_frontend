import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/features/settings/view/widgets/settings_helpers.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({
    super.key,
    required this.foregroundColor,
    required this.groupColor,
    required this.borderColor,
    required this.isDark,
  });

  final Color foregroundColor;
  final Color groupColor;
  final Color borderColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionTitle(
          'Legal',
          color: isDark ? const Color(0xFFB7BDC3) : const Color(0xFF6F7378),
        ),
        const SizedBox(height: 8),
        SettingsGroup(
          color: groupColor,
          borderColor: borderColor,
          children: [
            SettingsTile(
              icon: Icons.description_outlined,
              title: 'Data Privacy Terms',
              foregroundColor: foregroundColor,
              showChevron: true,
              onTap: () => Get.toNamed(AppRoutes.privacyPolicy),
            ),
            SettingsTile(
              icon: Icons.library_books_outlined,
              title: 'Terms and Conditions',
              foregroundColor: foregroundColor,
              showChevron: true,
              onTap: () => Get.toNamed(AppRoutes.aboutUs),
            ),
          ],
        ),
        const SizedBox(height: 26),
        SettingsGroup(
          color: groupColor,
          borderColor: borderColor,
          children: [
            SettingsTile(
              icon: Icons.info_outline_rounded,
              title: 'Version 1.0.0',
              foregroundColor: foregroundColor,
            ),
          ],
        ),
      ],
    );
  }
}
