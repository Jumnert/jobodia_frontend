import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/features/settings/controller/theme_controller.dart';
import 'package:jobodia_frontend/features/settings/view/widgets/settings_helpers.dart';

class AppearanceSection extends StatelessWidget {
  const AppearanceSection({
    super.key,
    required this.foregroundColor,
    required this.groupColor,
    required this.borderColor,
    required this.biometricEnabled,
    required this.passcodeEnabled,
    required this.onBiometricChanged,
    required this.onPasscodeChanged,
    required this.onPinTap,
  });

  final Color foregroundColor;
  final Color groupColor;
  final Color borderColor;
  final bool biometricEnabled;
  final bool passcodeEnabled;
  final ValueChanged<bool> onBiometricChanged;
  final ValueChanged<bool> onPasscodeChanged;
  final VoidCallback onPinTap;

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return Column(
      children: [
        SectionTitle('General', color: _sectionColor(context)),
        const SizedBox(height: 8),
        SettingsGroup(
          color: groupColor,
          borderColor: borderColor,
          children: [
            SettingsTile(
              icon: Icons.dark_mode_outlined,
              title: 'Switch themes',
              foregroundColor: foregroundColor,
              trailing: Obx(
                () => Switch.adaptive(
                  value: themeController.isDarkMode.value,
                  onChanged: themeController.toggleTheme,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SectionTitle('Security', color: _sectionColor(context)),
        const SizedBox(height: 8),
        SettingsGroup(
          color: groupColor,
          borderColor: borderColor,
          children: [
            SettingsTile(
              icon: Icons.fingerprint_rounded,
              title: 'Biometric unlock',
              foregroundColor: foregroundColor,
              trailing: Switch.adaptive(
                value: biometricEnabled,
                onChanged: onBiometricChanged,
              ),
            ),
            SettingsTile(
              icon: Icons.password_rounded,
              title: 'Passcode lock',
              foregroundColor: foregroundColor,
              trailing: Switch.adaptive(
                value: passcodeEnabled,
                onChanged: onPasscodeChanged,
              ),
            ),
            SettingsTile(
              icon: Icons.lock_outline_rounded,
              title: 'App PIN',
              foregroundColor: foregroundColor,
              showChevron: true,
              onTap: onPinTap,
            ),
          ],
        ),
      ],
    );
  }

  Color _sectionColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFB7BDC3) : const Color(0xFF6F7378);
  }
}
