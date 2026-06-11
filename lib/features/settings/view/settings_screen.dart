import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/features/home/view/widgets/app_bottom_navigation_bar.dart';
import 'package:jobodia_frontend/features/home/view/widgets/app_navigation.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: Get.back,
                  icon: const Icon(Icons.chevron_left_rounded, size: 30),
                ),
                const Expanded(
                  child: Text(
                    'Settings',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 18),
            const _SectionTitle('General'),
            const SizedBox(height: 8),
            _SettingsGroup(
              children: [
                _SettingsTile(
                  icon: Icons.thumb_up_alt_outlined,
                  title: 'Leave feedback',
                  subtitle: 'Help us improve the app experience.',
                  onTap: () => _showMockSnack('Feedback'),
                ),
                _SettingsTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Switch themes',
                  trailing: Switch.adaptive(
                    value: _darkMode,
                    onChanged: (value) => setState(() => _darkMode = value),
                  ),
                ),
                _SettingsTile(
                  icon: Icons.public_rounded,
                  title: 'Clear cache',
                  onTap: () => _showMockSnack('Cache cleared'),
                ),
                _SettingsTile(
                  icon: Icons.help_outline_rounded,
                  title: 'FAQ',
                  showChevron: true,
                  onTap: () => _showMockSnack('FAQ'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const _SectionTitle('Legal'),
            const SizedBox(height: 8),
            _SettingsGroup(
              children: [
                _SettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Data Privacy Terms',
                  showChevron: true,
                  onTap: () => _showMockSnack('Data Privacy Terms'),
                ),
                _SettingsTile(
                  icon: Icons.library_books_outlined,
                  title: 'Terms and Conditions',
                  showChevron: true,
                  onTap: () => _showMockSnack('Terms and Conditions'),
                ),
              ],
            ),
            const SizedBox(height: 26),
            TextButton.icon(
              onPressed: () => _showMockSnack('Sign out'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
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
        selectedIndex: 4,
        onDestinationSelected: (index) =>
            navigateMainDestination(context, index, currentIndex: 4),
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
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF6F7378),
        fontSize: 13,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9E9E9)),
      ),
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index != children.length - 1)
              const Divider(height: 1, indent: 52, color: Color(0xFFEDEDED)),
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
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF44484C), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: Color(0xFF84888D),
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
