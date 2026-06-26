// ignore_for_file: deprecated_member_use, avoid_print, curly_braces_in_flow_control_structures, unused_import, unnecessary_underscores, unused_field, unused_local_variable, use_build_context_synchronously, duplicate_ignore
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/features/auth/controller/auth_controller.dart';
import 'package:jobodia_frontend/features/settings/controller/feedback_controller.dart';
import 'package:jobodia_frontend/features/settings/controller/theme_controller.dart';
import 'package:jobodia_frontend/features/settings/view/widgets/about_section.dart';
import 'package:jobodia_frontend/features/settings/view/widgets/account_section.dart';
import 'package:jobodia_frontend/features/settings/view/widgets/appearance_section.dart';
import 'package:jobodia_frontend/features/settings/view/widgets/settings_helpers.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/feature_discovery/controller/feature_discovery_controller.dart';
import 'package:jobodia_frontend/services/secure_storage_service.dart';
import 'package:jobodia_frontend/features/settings/view/widgets/support_section.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.showBottomNav = true});

  final bool? showBottomNav;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ThemeController _themeController = Get.find<ThemeController>();
  final GetStorage _storage = GetStorage();

  static const _biometricKey = 'biometricEnabled';
  static const _passcodeKey = 'passcodeEnabled';

  bool _biometricEnabled = false;
  bool _passcodeEnabled = false;

  @override
  void initState() {
    super.initState();
    _biometricEnabled = _storage.read<bool>(_biometricKey) ?? false;
    _passcodeEnabled = _storage.read<bool>(_passcodeKey) ?? false;
  }

  void _toggleBiometric(bool value) {
    setState(() => _biometricEnabled = value);
    _storage.write(_biometricKey, value);
  }

  void _togglePasscode(bool value) {
    setState(() => _passcodeEnabled = value);
    _storage.write(_passcodeKey, value);
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
                  tooltip: 'Back',
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
            AccountSection(
              foregroundColor: foregroundColor,
              groupColor: groupColor,
              borderColor: borderColor,
              isDark: isDark,
            ),
            const SizedBox(height: 20),
            SectionTitle('Your Activity', color: sectionColor),
            const SizedBox(height: 8),
            SupportSection(
              foregroundColor: foregroundColor,
              groupColor: groupColor,
              borderColor: borderColor,
              isDark: isDark,
              onFeedbackTap: () => _showFeedbackSheet(context),
              onClearCacheTap: () => _clearCache(context),
              onFaqTap: () => _showFaqSheet(context),
            ),
            const SizedBox(height: 20),
            SectionTitle('Discover Features', color: sectionColor),
            const SizedBox(height: 8),
            _FeatureDiscoverySection(
              foregroundColor: foregroundColor,
              groupColor: groupColor,
              borderColor: borderColor,
            ),
            const SizedBox(height: 20),
            AppearanceSection(
              foregroundColor: foregroundColor,
              groupColor: groupColor,
              borderColor: borderColor,
              biometricEnabled: _biometricEnabled,
              passcodeEnabled: _passcodeEnabled,
              onBiometricChanged: _toggleBiometric,
              onPasscodeChanged: _togglePasscode,
              onPinTap: () => _showPinDialog(context),
            ),
            AboutSection(
              foregroundColor: foregroundColor,
              groupColor: groupColor,
              borderColor: borderColor,
              isDark: isDark,
            ),
            const SizedBox(height: 26),
            TextButton.icon(
              onPressed: () => _showLogoutDialog(context),
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showFeedbackSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _FeedbackSheet(),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foregroundColor = isDark ? Colors.white : Colors.black;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1D20) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Log out',
          style: TextStyle(color: foregroundColor, fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: foregroundColor.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: foregroundColor.withValues(alpha: 0.6)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Get.find<AuthController>().logout();
            },
            child: const Text(
              'Log out',
              style: TextStyle(
                color: Color(0xFFD93B3B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearCache(BuildContext context) {
    final storage = GetStorage();
    final themeValue = storage.read(ThemeController.themeKey);
    final seenOnboarding = storage.read('hasSeenOnboarding');
    storage.erase();
    if (themeValue != null) storage.write(ThemeController.themeKey, themeValue);
    if (seenOnboarding != null) {
      storage.write('hasSeenOnboarding', seenOnboarding);
    }
    Get.snackbar(
      'Cache cleared',
      'Local data has been cleared.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  void _showPinDialog(BuildContext context) {
    final storage = GetStorage();
    const pinKey = 'appPin';
    final existingPin = storage.read<String>(pinKey);
    final pinController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(existingPin != null ? 'Change PIN' : 'Set PIN'),
          content: TextField(
            controller: pinController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Enter 4-digit PIN',
              counterText: '',
            ),
          ),
          actions: [
            if (existingPin != null)
              TextButton(
                onPressed: () {
                  storage.remove(pinKey);
                  Navigator.of(ctx).pop();
                  Get.snackbar(
                    'PIN Removed',
                    'App PIN has been cleared.',
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                  );
                },
                child: const Text('Remove PIN'),
              ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final pin = pinController.text.trim();
                if (pin.length == 4 && RegExp(r'^\d{4}$').hasMatch(pin)) {
                  storage.write(pinKey, pin);
                  Navigator.of(ctx).pop();
                  Get.snackbar(
                    'PIN Set',
                    'Your 4-digit PIN has been saved.',
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                  );
                } else {
                  Get.snackbar(
                    'Invalid',
                    'Please enter exactly 4 digits.',
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showFaqSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? Colors.white : Colors.black;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FAQ',
                  style: TextStyle(
                    color: fg,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                ..._faqItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.$1,
                          style: TextStyle(
                            color: fg,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.$2,
                          style: TextStyle(
                            color: fg.withValues(alpha: 0.6),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static const _faqItems = [
    (
      'How do I save a job?',
      'Long-press any job card to open the context menu, then tap "Fave". You can find all saved jobs in Settings → Saved Jobs.',
    ),
    (
      'How does the match score work?',
      'The match score is calculated based on your skills, location, experience level, and salary expectations compared to the job listing.',
    ),
    (
      'Can I edit my CV after generating it?',
      'Yes! Go to the CV Builder from the bottom navigation and you can regenerate your CV at any time with updated information.',
    ),
    (
      'How do I report a job listing?',
      'Long-press the job card and select "Report" from the context menu. Describe the issue and submit.',
    ),
  ];
}

class _FeedbackSheet extends StatefulWidget {
  const _FeedbackSheet();

  @override
  State<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<_FeedbackSheet> {
  late final TextEditingController _commentCtrl;
  int _selectedRating = 0;

  @override
  void initState() {
    super.initState();
    _commentCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foregroundColor = isDark ? Colors.white : Colors.black;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Leave Feedback',
            style: TextStyle(
              color: foregroundColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'We appreciate your thoughts!',
            style: TextStyle(
              color: foregroundColor.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = i < _selectedRating;
              return IconButton(
                onPressed: () => setState(() => _selectedRating = i + 1),
                icon: Icon(
                  filled ? Icons.star_rounded : Icons.star_border_rounded,
                  color: filled
                      ? const Color(0xFFFFC107)
                      : foregroundColor.withValues(alpha: 0.4),
                  size: 32,
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commentCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Tell us what you think...',
              hintStyle: TextStyle(
                color: foregroundColor.withValues(alpha: 0.4),
              ),
              filled: true,
              fillColor: isDark
                  ? const Color(0xFF22262B)
                  : const Color(0xFFF3F5F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            style: TextStyle(color: foregroundColor),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedRating == 0
                  ? null
                  : () {
                      if (!Get.isRegistered<FeedbackController>()) {
                        Get.lazyPut<FeedbackController>(FeedbackController.new);
                      }
                      Get.find<FeedbackController>().submit(
                        _selectedRating,
                        _commentCtrl.text.trim(),
                      );
                      Navigator.of(context).pop();
                      Get.snackbar(
                        'Thank you!',
                        'Thanks for your feedback!',
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.all(16),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00856F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Submit',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureDiscoverySection extends StatelessWidget {
  const _FeatureDiscoverySection({
    required this.foregroundColor,
    required this.groupColor,
    required this.borderColor,
  });

  final Color foregroundColor;
  final Color groupColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<FeatureDiscoveryController>()) {
      return const SizedBox.shrink();
    }

    final ctrl = Get.find<FeatureDiscoveryController>();

    return Container(
      decoration: BoxDecoration(
        color: groupColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Obx(() {
        final undiscovered = ctrl.undiscoveredCount();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...FeatureDiscoveryController.features.map((f) {
              final isDisc = ctrl.isDiscovered(f.id);
              return ListTile(
                leading: Icon(
                  f.icon,
                  color: isDisc
                      ? foregroundColor.withAlpha(150)
                      : AppColors.brandTeal,
                ),
                title: Text(
                  f.title,
                  style: TextStyle(
                    color: foregroundColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  f.description,
                  style: TextStyle(
                    color: foregroundColor.withAlpha(150),
                    fontSize: 12,
                  ),
                ),
                trailing: isDisc
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 20,
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.brandTeal,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                onTap: () {
                  ctrl.markDiscovered(f.id);
                  Get.toNamed<void>(f.route);
                },
              );
            }),
            const Divider(height: 1),
            TextButton(
              onPressed: () {
                ctrl.resetDiscovery();
                Get.snackbar(
                  'Discovery Reset',
                  'You will see feature tooltips again.',
                );
              },
              child: const Text(
                'Reset Discovery',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      }),
    );
  }
}
