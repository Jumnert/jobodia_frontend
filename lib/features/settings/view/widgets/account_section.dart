import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/features/profile/controller/profile_controller.dart';
import 'package:jobodia_frontend/features/settings/view/widgets/settings_helpers.dart';

class AccountSection extends StatelessWidget {
  const AccountSection({
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
    final profileCtrl = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : null;
    return Obx(() {
      final name = profileCtrl?.profile.name ?? 'User';
      final role = profileCtrl?.profile.role ?? '';
      final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
      return SettingsGroup(
        color: groupColor,
        borderColor: borderColor,
        children: [
          SettingsTile(
            icon: Icons.person_outline_rounded,
            title: name,
            subtitle: role,
            foregroundColor: foregroundColor,
            mutedColor: isDark
                ? const Color(0xFFA5ABB1)
                : const Color(0xFF84888D),
            showChevron: true,
            onTap: () => Get.toNamed(AppRoutes.profile),
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF00856F),
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
