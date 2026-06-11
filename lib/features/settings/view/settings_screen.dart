import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/features/home/view/widgets/app_bottom_navigation_bar.dart';
import 'package:jobodia_frontend/features/home/view/widgets/app_navigation.dart';
import 'package:jobodia_frontend/features/pricing/view/pricing_screen.dart';
import 'package:jobodia_frontend/features/search/view/search_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _darkMode;

  @override
  void initState() {
    super.initState();
    _darkMode = Get.isDarkMode;
  }

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
                  trailing: Switch.adaptive(
                    value: _darkMode,
                    onChanged: _toggleTheme,
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
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: 3,
        onDestinationSelected: (index) =>
            navigateMainDestination(context, index, currentIndex: 3),
        onSearchPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const SearchScreen())),
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

  void _toggleTheme(bool value) {
    setState(() => _darkMode = value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
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
