import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/features/auth/controller/auth_controller.dart';
import 'package:jobodia_frontend/features/settings/controller/feedback_controller.dart';
import 'package:jobodia_frontend/features/settings/controller/theme_controller.dart';
import 'package:jobodia_frontend/features/settings/view/widgets/settings_helpers.dart';
import 'package:jobodia_frontend/features/feature_discovery/controller/feature_discovery_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.showBottomNav = true});

  final bool? showBottomNav;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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

    return AdaptiveScaffold(
      body: Material(
        color: backgroundColor,
        child: Stack(
          children: [
            Positioned.fill(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.paddingOf(context).top + 80,
                  20,
                  112,
                ),
                children: [
                  SectionTitle('Other settings', color: sectionColor),
                  const SizedBox(height: 8),
                  SettingsGroup(
                    color: groupColor,
                    borderColor: borderColor,
                    children: [
                      SettingsTile(
                        icon: Icons.person_rounded,
                        title: 'Profile details',
                        showChevron: true,
                        foregroundColor: foregroundColor,
                        mutedColor: sectionColor,
                        onTap: () => Get.toNamed<void>(AppRoutes.profile),
                      ),
                      SettingsTile(
                        icon: Icons.lock_rounded,
                        title: 'App PIN',
                        showChevron: true,
                        foregroundColor: foregroundColor,
                        mutedColor: sectionColor,
                        onTap: () => _showPinDialog(context),
                      ),
                      SettingsTile(
                        icon: Icons.explore_rounded,
                        title: 'Discover Features',
                        showChevron: true,
                        foregroundColor: foregroundColor,
                        mutedColor: sectionColor,
                        onTap: () {
                          if (Get.isRegistered<FeatureDiscoveryController>()) {
                            Get.find<FeatureDiscoveryController>()
                                .resetDiscovery();
                            Get.snackbar(
                              'Discovery Reset',
                              'You will see feature tooltips again.',
                            );
                          }
                        },
                      ),
                      SettingsTile(
                        icon: Icons.dark_mode_rounded,
                        title: 'Dark mode',
                        foregroundColor: foregroundColor,
                        mutedColor: sectionColor,
                        trailing: AdaptiveSwitch(
                          value: isDark,
                          onChanged: (val) {
                            if (!Get.isRegistered<ThemeController>()) return;
                            Get.find<ThemeController>().toggleTheme(val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SettingsGroup(
                    color: groupColor,
                    borderColor: borderColor,
                    children: [
                      SettingsTile(
                        icon: Icons.info_rounded,
                        title: 'About application',
                        showChevron: true,
                        foregroundColor: foregroundColor,
                        mutedColor: sectionColor,
                        onTap: () => Get.toNamed<void>(AppRoutes.aboutUs),
                      ),
                      SettingsTile(
                        icon: Icons.help_rounded,
                        title: 'Help/FAQ',
                        showChevron: true,
                        foregroundColor: foregroundColor,
                        mutedColor: sectionColor,
                        onTap: () => _showFaqSheet(context),
                      ),
                      SettingsTile(
                        icon: Icons.feedback_rounded,
                        title: 'Leave Feedback',
                        showChevron: true,
                        foregroundColor: foregroundColor,
                        mutedColor: sectionColor,
                        onTap: () => _showFeedbackSheet(context),
                      ),
                      SettingsTile(
                        icon: Icons.cleaning_services_rounded,
                        title: 'Clear Cache',
                        showChevron: true,
                        foregroundColor: foregroundColor,
                        mutedColor: sectionColor,
                        onTap: () => _clearCache(context),
                      ),
                      SettingsTile(
                        icon: Icons
                            .delete_rounded, // Wait, Deactivate account icon in screenshot looks like a trash bin. delete_rounded is perfect.
                        title: 'Sign out',
                        showChevron: true,
                        isDestructive: true,
                        foregroundColor: foregroundColor,
                        mutedColor: sectionColor,
                        onTap: () => _showLogoutDialog(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Positioned(
              top: MediaQuery.paddingOf(context).top + 14,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  AdaptiveButton.icon(
                    onPressed: () => Get.back<void>(),
                    icon: PlatformInfo.isIOS
                        ? Icons.arrow_back_ios_new_rounded
                        : Icons.arrow_back_rounded,
                    iconColor: foregroundColor,
                    style: AdaptiveButtonStyle.glass,
                    minSize: const Size(44, 44),
                    useSmoothRectangleBorder: false,
                  ),
                  const Spacer(),
                  AdaptiveButton(
                    onPressed: () {},
                    label: 'Settings',
                    textColor: foregroundColor,
                    style: AdaptiveButtonStyle.glass,
                    minSize: const Size(150, 44),
                    useSmoothRectangleBorder: false,
                  ),
                  const Spacer(),
                  AdaptiveButton.icon(
                    onPressed: () => Get.toNamed<void>(AppRoutes.report),
                    icon: Icons.report_problem_rounded,
                    iconColor: foregroundColor,
                    style: AdaptiveButtonStyle.glass,
                    minSize: const Size(44, 44),
                    useSmoothRectangleBorder: false,
                  ),
                ],
              ),
            ),
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
    AdaptiveAlertDialog.show(
      context: context,
      title: 'Log out',
      message: 'Are you sure you want to log out?',
      icon: 'rectangle.portrait.and.arrow.right',
      actions: [
        AlertAction(
          title: 'Cancel',
          style: AlertActionStyle.cancel,
          onPressed: () {},
        ),
        AlertAction(
          title: 'Log out',
          style: AlertActionStyle.destructive,
          // The dialog pops itself before invoking this callback.
          onPressed: () => Get.find<AuthController>().logout(),
        ),
      ],
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

  Future<void> _showPinDialog(BuildContext context) async {
    final storage = GetStorage();
    const pinKey = 'appPin';
    final existingPin = storage.read<String>(pinKey);

    // inputShow auto-pops and resolves to the entered text; we track which
    // button was tapped via this flag because there can be three actions.
    var tapped = 'cancel';

    final result = await AdaptiveAlertDialog.inputShow(
      context: context,
      title: existingPin != null ? 'Change PIN' : 'Set PIN',
      icon: 'lock.fill',
      input: const AdaptiveAlertDialogInput(
        placeholder: 'Enter 4-digit PIN',
        keyboardType: TextInputType.number,
        obscureText: true,
        maxLength: 4,
      ),
      actions: [
        if (existingPin != null)
          AlertAction(
            title: 'Remove PIN',
            style: AlertActionStyle.destructive,
            onPressed: () => tapped = 'remove',
          ),
        AlertAction(
          title: 'Cancel',
          style: AlertActionStyle.cancel,
          onPressed: () => tapped = 'cancel',
        ),
        AlertAction(
          title: 'Save',
          style: AlertActionStyle.primary,
          onPressed: () => tapped = 'save',
        ),
      ],
    );

    switch (tapped) {
      case 'remove':
        storage.remove(pinKey);
        Get.snackbar(
          'PIN Removed',
          'App PIN has been cleared.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      case 'save':
        final pin = result?.trim() ?? '';
        if (pin.length == 4 && RegExp(r'^\d{4}$').hasMatch(pin)) {
          storage.write(pinKey, pin);
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
    }
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
