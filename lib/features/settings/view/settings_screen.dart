import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/features/pricing/view/pricing_screen.dart';
import 'package:jobodia_frontend/features/settings/controller/theme_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.showBottomNav = true});

  final bool? showBottomNav;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ThemeController _themeController = Get.find<ThemeController>();

  bool _biometricEnabled = false;
  bool _passcodeEnabled = false;
  int? _passcodeLength;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF101214)
        : const Color(0xFFF5F5F5);
    final foregroundColor = isDark ? Colors.white : Colors.black;
    final sectionColor = isDark
        ? const Color(0xFFB7BDC3)
        : const Color(0xFF6F7378);
    final groupColor = isDark ? const Color(0xFF1A1D20) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF2A2E33)
        : const Color(0xFFE9E9E9);

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBody: true,
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 112),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: Get.back,
                  icon: const Icon(Icons.chevron_left_rounded, size: 30),
                ),
                Expanded(
                  child: Text(
                    'Settings',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 18),
            _SectionTitle('General', color: sectionColor),
            const SizedBox(height: 8),
            _SettingsGroup(
              color: groupColor,
              borderColor: borderColor,
              children: [
                _SettingsTile(
                  icon: Icons.thumb_up_alt_outlined,
                  title: 'Leave feedback',
                  subtitle: 'Help us improve the app experience.',
                  foregroundColor: foregroundColor,
                  mutedColor: isDark
                      ? const Color(0xFFA5ABB1)
                      : const Color(0xFF84888D),
                  onTap: () => _showMockSnack('Feedback'),
                ),
                _SettingsTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Switch themes',
                  foregroundColor: foregroundColor,
                  trailing: Obx(
                    () => Switch.adaptive(
                      value: _themeController.isDarkMode.value,
                      onChanged: _themeController.toggleTheme,
                    ),
                  ),
                ),
                _SettingsTile(
                  icon: Icons.public_rounded,
                  title: 'Clear cache',
                  foregroundColor: foregroundColor,
                  onTap: () => _showMockSnack('Cache cleared'),
                ),
                _SettingsTile(
                  icon: Icons.help_outline_rounded,
                  title: 'FAQ',
                  foregroundColor: foregroundColor,
                  showChevron: true,
                  onTap: () => _showMockSnack('FAQ'),
                ),
                _SettingsTile(
                  icon: Icons.star_border_rounded,
                  title: 'Pricing Plan',
                  foregroundColor: foregroundColor,
                  showChevron: true,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PricingScreen(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SectionTitle('Security', color: sectionColor),
            const SizedBox(height: 8),
            _SettingsGroup(
              color: groupColor,
              borderColor: borderColor,
              children: [
                _SettingsTile(
                  icon: Icons.fingerprint_rounded,
                  title: 'Biometric Authentication',
                  subtitle: 'Unlock with Fingerprint or Face ID.',
                  foregroundColor: foregroundColor,
                  mutedColor: isDark
                      ? const Color(0xFFA5ABB1)
                      : const Color(0xFF84888D),
                  trailing: Switch.adaptive(
                    value: _biometricEnabled,
                    onChanged: _toggleBiometric,
                  ),
                ),
                _SettingsTile(
                  icon: Icons.password_rounded,
                  title: 'Passcode Lock',
                  subtitle: _passcodeEnabled && _passcodeLength != null
                      ? '$_passcodeLength-digit PIN enabled.'
                      : 'Secure the app with a 4 or 6-digit PIN.',
                  foregroundColor: foregroundColor,
                  mutedColor: isDark
                      ? const Color(0xFFA5ABB1)
                      : const Color(0xFF84888D),
                  trailing: Switch.adaptive(
                    value: _passcodeEnabled,
                    onChanged: _togglePasscode,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SectionTitle('Legal', color: sectionColor),
            const SizedBox(height: 8),
            _SettingsGroup(
              color: groupColor,
              borderColor: borderColor,
              children: [
                _SettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Data Privacy Terms',
                  foregroundColor: foregroundColor,
                  showChevron: true,
                  onTap: () => _showMockSnack('Data Privacy Terms'),
                ),
                _SettingsTile(
                  icon: Icons.library_books_outlined,
                  title: 'Terms and Conditions',
                  foregroundColor: foregroundColor,
                  showChevron: true,
                  onTap: () => _showMockSnack('Terms and Conditions'),
                ),
              ],
            ),
            const SizedBox(height: 26),
            TextButton.icon(
              onPressed: () => _showMockSnack('Sign out'),
              style: TextButton.styleFrom(
                foregroundColor: foregroundColor,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 14,
                ),
              ),
              icon: const Icon(Icons.logout_rounded, size: 20),
              label: const Text(
                'Sign out',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMockSnack(String title) {
    Get.snackbar(
      title,
      'This setting will be connected here.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  void _toggleBiometric(bool value) {
    setState(() => _biometricEnabled = value);
    _showMockSnack(
      value ? 'Biometric unlock enabled' : 'Biometric unlock disabled',
    );
  }

  Future<void> _togglePasscode(bool value) async {
    if (!value) {
      setState(() {
        _passcodeEnabled = false;
        _passcodeLength = null;
      });
      _showMockSnack('Passcode lock disabled');
      return;
    }

    final length = await _showPasscodeLengthSheet();
    if (length == null) {
      return;
    }

    setState(() {
      _passcodeEnabled = true;
      _passcodeLength = length;
    });
    _showMockSnack('$length-digit passcode set');
  }

  /// Lets the user pick a 4 or 6-digit PIN length. Returns null if dismissed.
  Future<int?> _showPasscodeLengthSheet() {
    return showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        final foregroundColor = isDark ? Colors.white : Colors.black;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set Passcode',
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose a PIN length to lock the app.',
                  style: TextStyle(
                    color: foregroundColor.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                _PasscodeLengthOption(
                  label: '4-digit PIN',
                  foregroundColor: foregroundColor,
                  onTap: () => Navigator.of(sheetContext).pop(4),
                ),
                const SizedBox(height: 10),
                _PasscodeLengthOption(
                  label: '6-digit PIN',
                  foregroundColor: foregroundColor,
                  onTap: () => Navigator.of(sheetContext).pop(6),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w800),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({
    required this.children,
    required this.color,
    required this.borderColor,
  });

  final List<Widget> children;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index != children.length - 1)
              Divider(height: 1, indent: 52, color: borderColor),
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showChevron = false,
    this.onTap,
    this.foregroundColor = Colors.black,
    this.mutedColor = const Color(0xFF84888D),
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showChevron;
  final VoidCallback? onTap;
  final Color foregroundColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        child: Row(
          children: [
            Icon(
              icon,
              color: foregroundColor.withValues(alpha: 0.76),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 12,
                        height: 1.2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
            if (showChevron)
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF00856F),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

class _PasscodeLengthOption extends StatelessWidget {
  const _PasscodeLengthOption({
    required this.label,
    required this.foregroundColor,
    required this.onTap,
  });

  final String label;
  final Color foregroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: foregroundColor.withValues(alpha: 0.14)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.pin_rounded,
              size: 20,
              color: foregroundColor.withValues(alpha: 0.76),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: foregroundColor.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
