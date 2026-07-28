import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/core/widgets/blurred_header.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/adaptive_dialog.dart';
import 'package:jobodia_frontend/features/auth/controller/auth_controller.dart';
import 'package:jobodia_frontend/features/settings/controller/feedback_controller.dart';
import 'package:jobodia_frontend/features/settings/controller/theme_controller.dart';
import 'package:jobodia_frontend/features/settings/view/widgets/theme_picker.dart';
import 'package:jobodia_frontend/features/feature_discovery/controller/feature_discovery_controller.dart';
import 'package:jobodia_frontend/features/onboarding/controllers/onboarding_controller.dart';
import 'package:jobodia_frontend/features/onboarding/views/onboarding_view.dart';
import 'package:jobodia_frontend/features/role/view/role_selection_screen.dart';
import 'package:jobodia_frontend/features/splash/view/splash_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.showBottomNav = true});

  final bool? showBottomNav;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _faceIdKey = 'mockFaceIdEnabled';
  bool _faceIdEnabled = false;

  @override
  void initState() {
    super.initState();
    _faceIdEnabled = GetStorage().read<bool>(_faceIdKey) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.paddingOf(context).top + 64,
        16,
        32,
      ),
      children: [
        FTileGroup(
          label: const Text('Other settings'),
          children: [
            FTile(
              prefix: const Icon(FLucideIcons.circleUser),
              title: const Text('Profile details'),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () => Get.toNamed<void>(AppRoutes.profile),
            ),
            FTile(
              prefix: const Icon(FLucideIcons.lock),
              title: const Text('App PIN'),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () => _showPinDialog(context),
            ),
            FTile(
              prefix: const Icon(FLucideIcons.scanFace),
              title: const Text('Face ID'),
              subtitle: const Text('Unlock with biometrics'),
              suffix: FSwitch(
                value: _faceIdEnabled,
                onChange: (value) => _setFaceId(context, value),
              ),
            ),
            FTile(
              prefix: const Icon(FLucideIcons.workflow),
              title: const Text('Plans & pricing'),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () => Get.toNamed<void>(AppRoutes.pricing),
            ),
            FTile(
              prefix: const Icon(FLucideIcons.compass),
              title: const Text('Discover Features'),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () {
                if (Get.isRegistered<FeatureDiscoveryController>()) {
                  Get.find<FeatureDiscoveryController>().resetDiscovery();
                  Get.snackbar(
                    'Discovery Reset',
                    'You will see feature tooltips again.',
                  );
                }
              },
            ),
            FTile(
              prefix: const Icon(FLucideIcons.moon),
              title: const Text('Dark mode'),
              subtitle: const Text('Switch between light and dark'),
              suffix: FSwitch(
                value: isDark,
                onChange: (val) {
                  if (!Get.isRegistered<ThemeController>()) return;
                  Get.find<ThemeController>().toggleTheme(val);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text('Visual theme', style: theme.typography.body.sm),
        ),
        const ThemePicker(),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text('App profile icon', style: theme.typography.body.sm),
        ),
        const _ProfileIconPicker(),
        const SizedBox(height: 24),
        FTileGroup(
          label: const Text('Testing'),
          children: [
            FTile(
              prefix: const Icon(FLucideIcons.circlePlay),
              title: const Text('Onboarding preview'),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: _openOnboardingPreview,
            ),
            FTile(
              prefix: const Icon(FLucideIcons.rocket),
              title: const Text('Splash screen preview'),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: _openSplashPreview,
            ),
            FTile(
              prefix: const Icon(FLucideIcons.userCog),
              title: const Text('Select role'),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: _openRolePreview,
            ),
          ],
        ),
        const SizedBox(height: 24),
        FTileGroup(
          children: [
            FTile(
              prefix: const Icon(FLucideIcons.info),
              title: const Text('About application'),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () => Get.toNamed<void>(AppRoutes.aboutUs),
            ),
            FTile(
              prefix: const Icon(FLucideIcons.circleHelp),
              title: const Text('Help/FAQ'),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () => _showFaqSheet(context),
            ),
            FTile(
              prefix: const Icon(FLucideIcons.messageSquare),
              title: const Text('Leave Feedback'),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () => _showFeedbackSheet(context),
            ),
            FTile(
              prefix: const Icon(FLucideIcons.scrollText),
              title: const Text('Dev Logs'),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () => Get.toNamed<void>(AppRoutes.devLogs),
            ),
            FTile(
              prefix: const Icon(FLucideIcons.sparkles),
              title: const Text('Clear Cache'),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () => _clearCache(context),
            ),
            FTile(
              variant: FItemVariant.destructive,
              prefix: const Icon(FLucideIcons.logOut),
              title: const Text('Sign out'),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () => _showLogoutDialog(context),
            ),
          ],
        ),
      ],
    );

    // Build the header widget separately so we can measure its height.
    final header = BlurredHeader(
      child: FHeader.nested(
        title: const Text('Settings'),
        prefixes: [FHeaderAction.back(onPress: () => Get.back<void>())],
        suffixes: [
          FHeaderAction(
            icon: const Icon(FLucideIcons.flag),
            onPress: () => Get.toNamed<void>(AppRoutes.report),
          ),
        ],
      ),
    );

    return FScaffold(
      child: Stack(
        children: [
          Positioned.fill(child: content),
          Positioned(top: 0, left: 0, right: 0, child: header),
        ],
      ),
    );
  }

  void _setFaceId(BuildContext context, bool value) {
    if (!value) {
      setState(() => _faceIdEnabled = false);
      GetStorage().write(_faceIdKey, false);
      return;
    }
    AdaptiveDialog.show(
      context: context,
      title: 'Allow Face ID?',
      message:
          'This is a preview setting. Device authentication will be connected later.',
      actions: [
        DialogAction(
          title: 'Not now',
          style: DialogActionStyle.cancel,
          onPressed: () {},
        ),
        DialogAction(
          title: 'Allow',
          style: DialogActionStyle.primary,
          onPressed: () {
            if (!mounted) return;
            setState(() => _faceIdEnabled = true);
            GetStorage().write(_faceIdKey, true);
          },
        ),
      ],
    );
  }

  void _openRolePreview() {
    Get.to<void>(() => const RoleSelectionScreen(preview: true));
  }

  void _openOnboardingPreview() {
    Get.to<void>(
      () => const OnboardingView(previewMode: true),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<OnboardingController>()) {
          Get.put(OnboardingController());
        }
      }),
    );
  }

  void _openSplashPreview() {
    Get.to<void>(
      () => SplashScreen(
        onFinished: () => Get.back<void>(),
        child: const SizedBox.shrink(),
      ),
      transition: Transition.fadeIn,
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
    AdaptiveDialog.show(
      context: context,
      title: 'Log out',
      message: 'Are you sure you want to log out?',
      actions: [
        DialogAction(
          title: 'Cancel',
          style: DialogActionStyle.cancel,
          onPressed: () {},
        ),
        DialogAction(
          title: 'Log out',
          style: DialogActionStyle.destructive,
          // The dialog pops itself before invoking this callback.
          onPressed: () => Get.find<AuthController>().logout(),
        ),
      ],
    );
  }

  void _clearCache(BuildContext context) {
    final storage = GetStorage();
    final themeValue = storage.read(ThemeController.themeKey);
    final presetValue = storage.read(ThemeController.presetKey);
    final seenOnboarding = storage.read('hasSeenOnboarding');
    storage.erase();
    if (themeValue != null) storage.write(ThemeController.themeKey, themeValue);
    if (presetValue != null) {
      storage.write(ThemeController.presetKey, presetValue);
    }
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

    final result = await AdaptiveDialog.inputShow(
      context: context,
      title: existingPin != null ? 'Change PIN' : 'Set PIN',
      input: const AdaptiveDialogInput(
        placeholder: 'Enter 4-digit PIN',
        keyboardType: TextInputType.number,
        obscureText: true,
        maxLength: 4,
      ),
      actions: [
        if (existingPin != null)
          DialogAction(
            title: 'Remove PIN',
            style: DialogActionStyle.destructive,
            onPressed: () => tapped = 'remove',
          ),
        DialogAction(
          title: 'Cancel',
          style: DialogActionStyle.cancel,
          onPressed: () => tapped = 'cancel',
        ),
        DialogAction(
          title: 'Save',
          style: DialogActionStyle.primary,
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

class _ProfileIconPicker extends StatelessWidget {
  const _ProfileIconPicker();

  static const _icons = [
    'assets/images/profile_icons/aqua_orbit.png',
    'assets/images/profile_icons/briefcase.png',
    'assets/images/profile_icons/rocket.png',
    'assets/images/profile_icons/compass.png',
    'assets/images/profile_icons/document.png',
    'assets/images/profile_icons/idea.png',
    'assets/images/profile_icons/summit.png',
    'assets/images/profile_icons/ai_orb.png',
    'assets/images/profile_icons/handshake.png',
    'assets/images/profile_icons/gem.png',
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ThemeController>();
    final palette = context.palette;
    return SizedBox(
      height: 72,
      child: Obx(() {
        final selectedIndex = controller.profileIconIndex.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _icons.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final selected = selectedIndex == index;
            return GestureDetector(
              onTap: () => AdaptiveDialog.show(
                context: context,
                title: 'Use this profile icon?',
                message:
                    'It will appear in the app header and on your profile.',
                actions: [
                  DialogAction(
                    title: 'Cancel',
                    style: DialogActionStyle.cancel,
                    onPressed: () {},
                  ),
                  DialogAction(
                    title: 'Use icon',
                    style: DialogActionStyle.primary,
                    onPressed: () => controller.selectProfileIcon(index),
                  ),
                ],
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 64,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.brandTeal : palette.border,
                    width: selected ? 3 : 1,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    _icons[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => ColoredBox(
                      color: palette.surfaceMuted,
                      child: Icon(
                        FLucideIcons.userRound,
                        color: palette.iconMuted,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
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
                  filled ? FLucideIcons.star : FLucideIcons.star,
                  color: filled
                      ? const Color(0xFFFFC107)
                      : foregroundColor.withValues(alpha: 0.4),
                  size: 32,
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          FTextField.multiline(
            control: FTextFieldControl.managed(controller: _commentCtrl),
            hint: 'Tell us what you think...',
            minLines: 4,
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          FButton(
            onPress: _selectedRating == 0
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
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
