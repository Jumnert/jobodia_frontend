import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/app/localization/language_controller.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/blurred_header.dart';
import 'package:jobodia_frontend/core/widgets/performance_debug_overlay.dart';
import 'package:jobodia_frontend/core/widgets/passcode_screen.dart';
import 'package:jobodia_frontend/features/auth/controller/auth_controller.dart';
import 'package:jobodia_frontend/features/profile/controller/profile_controller.dart';
import 'package:jobodia_frontend/features/settings/controller/feedback_controller.dart';
import 'package:jobodia_frontend/features/settings/controller/theme_controller.dart';
import 'package:jobodia_frontend/features/settings/view/widgets/theme_picker.dart';
import 'package:jobodia_frontend/features/feature_discovery/controller/feature_discovery_controller.dart';
import 'package:jobodia_frontend/features/onboarding/controllers/onboarding_controller.dart';
import 'package:jobodia_frontend/features/onboarding/views/onboarding_view.dart';
import 'package:jobodia_frontend/features/role/view/role_selection_screen.dart';
import 'package:jobodia_frontend/features/splash/view/splash_screen.dart';
import 'package:jobodia_frontend/services/app_security_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.showBottomNav = true});

  final bool? showBottomNav;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _roundedTileGroupStyle = FTileGroupStyleDelta.delta(
    decoration: DecorationDelta.boxDelta(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
  );
  static const _roundedDialogStyle = FDialogStyleDelta.delta(
    decoration: DecorationDelta.boxDelta(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
  );

  bool _faceIdEnabled = false;
  OverlayEntry? _performanceOverlay;
  final ScrollController _scrollController = ScrollController(
    keepScrollOffset: false,
  );

  @override
  void initState() {
    super.initState();
    _syncSecurityState();
    Get.lazyPut<ProfileController>(ProfileController.new, fenix: true);
  }

  Future<void> _syncSecurityState() async {
    await AppSecurityService.to.ready;
    if (!mounted) return;
    setState(() {
      _faceIdEnabled = AppSecurityService.to.biometricEnabled.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final safeArea = MediaQuery.paddingOf(context);
    final bottomPadding = widget.showBottomNav == false
        ? safeArea.bottom + 112
        : 32.0;
    final isKhmer = Localizations.localeOf(context).languageCode == 'km';
    Text tileTitle(String key) => Text(
      key.tr,
      style: theme.typography.body.sm.copyWith(
        fontWeight: isKhmer ? FontWeight.w400 : FontWeight.w600,
        height: isKhmer ? 1.2 : null,
      ),
    );
    Text tileSubtitle(String key) => Text(
      key.tr,
      style: theme.typography.body.xs.copyWith(
        color: theme.colors.mutedForeground,
        fontWeight: isKhmer ? FontWeight.w400 : FontWeight.w500,
        height: isKhmer ? 1.2 : null,
      ),
    );
    Text sectionLabel(String key) => Text(
      key.tr,
      style: theme.typography.body.sm.copyWith(
        fontWeight: isKhmer ? FontWeight.w500 : FontWeight.w700,
        height: isKhmer ? 1.2 : null,
      ),
    );
    final profileController = Get.find<ProfileController>();

    final content = ListView(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(16, safeArea.top + 64, 16, bottomPadding),
      children: [
        Obx(() {
          final profile = profileController.profileRx.value;
          final authUser = Get.isRegistered<AuthController>()
              ? Get.find<AuthController>().currentUser.value
              : null;
          final trimmedName = (authUser?.name ?? profile.name).trim();
          final socialAvatar = authUser?.avatarUrl?.trim() ?? '';
          final initial = trimmedName.isEmpty
              ? 'U'
              : trimmedName.substring(0, 1).toUpperCase();
          final avatar = profile.hasAvatarBytes
              ? FAvatar(
                  size: 52,
                  image: MemoryImage(profile.avatarBytes!),
                  fallback: Text(initial),
                )
              : socialAvatar.isNotEmpty
              ? FAvatar(
                  size: 52,
                  image: NetworkImage(socialAvatar),
                  fallback: Text(initial),
                )
              : profile.avatarImageUrl.trim().isNotEmpty
              ? FAvatar(
                  size: 52,
                  image: NetworkImage(profile.avatarImageUrl),
                  fallback: Text(initial),
                )
              : FAvatar.raw(
                  size: 52,
                  child: Text(
                    initial,
                    style: theme.typography.body.lg.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                );

          return FTileGroup(
            style: _roundedTileGroupStyle,
            children: [
              FTile(
                prefix: avatar,
                title: Text(
                  trimmedName.isEmpty ? 'User' : trimmedName,
                  style: theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: Text(
                  authUser?.role ?? profile.role,
                  style: theme.typography.body.xs.copyWith(
                    color: theme.colors.mutedForeground,
                    fontWeight: isKhmer ? FontWeight.w400 : FontWeight.w500,
                    height: isKhmer ? 1.2 : null,
                  ),
                ),
                suffix: SizedBox.square(
                  dimension: 42,
                  child: FButton.raw(
                    variant: FButtonVariant.ghost,
                    onPress: () => Get.toNamed<void>(AppRoutes.myQr),
                    semanticsLabel: 'Show my QR code',
                    child: const Icon(FLucideIcons.qrCode),
                  ),
                ),
                onPress: _openProfile,
              ),
            ],
          );
        }),
        const SizedBox(height: 24),
        FTileGroup(
          style: _roundedTileGroupStyle,
          label: sectionLabel('other_settings'),
          children: [
            FTile(
              prefix: const Icon(FLucideIcons.scanLine),
              title: const Text('Scan user QR'),
              subtitle: const Text('Open another Jobodia user profile'),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () => Get.toNamed<void>(AppRoutes.scanQr),
            ),
            FTile(
              prefix: const Icon(FLucideIcons.languages),
              title: tileTitle('language'),
              subtitle: Obx(
                () => Text(
                  Get.find<LanguageController>().current.label,
                  style: theme.typography.body.xs.copyWith(
                    color: theme.colors.mutedForeground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () => _showLanguageDialog(context),
            ),
            FTile(
              prefix: const Icon(FLucideIcons.lock),
              title: tileTitle('app_pin'),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () => _showPinDialog(context),
            ),
            FTile(
              prefix: const Icon(FLucideIcons.scanFace),
              title: tileTitle('face_id'),
              subtitle: tileSubtitle('unlock_biometrics'),
              suffix: FSwitch(
                value: _faceIdEnabled,
                onChange: (value) => _setFaceId(context, value),
              ),
            ),
            FTile(
              prefix: const Icon(FLucideIcons.workflow),
              title: tileTitle('plans_pricing'),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () => Get.toNamed<void>(AppRoutes.pricing),
            ),
            FTile(
              prefix: const Icon(FLucideIcons.compass),
              title: tileTitle('discover_features'),
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
              title: tileTitle('dark_mode'),
              subtitle: tileSubtitle('switch_theme'),
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
          child: sectionLabel('visual_theme'),
        ),
        const ThemePicker(),
        const SizedBox(height: 24),
        FTileGroup(
          style: _roundedTileGroupStyle,
          label: sectionLabel('testing'),
          children: [
            FTile(
              prefix: const Icon(FLucideIcons.circlePlay),
              title: tileTitle('onboarding_preview'),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: _openOnboardingPreview,
            ),
            FTile(
              prefix: const Icon(FLucideIcons.rocket),
              title: tileTitle('splash_preview'),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: _openSplashPreview,
            ),
            FTile(
              prefix: const Icon(FLucideIcons.userCog),
              title: tileTitle('select_role'),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: _openRolePreview,
            ),
            FTile(
              prefix: const Icon(FLucideIcons.chartNoAxesCombined),
              title: tileTitle('performance_overlay'),
              subtitle: tileSubtitle('performance_subtitle'),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () => _togglePerformanceOverlay(context),
            ),
          ],
        ),
        const SizedBox(height: 24),
        FTileGroup(
          style: _roundedTileGroupStyle,
          children: [
            FTile(
              prefix: const Icon(FLucideIcons.info),
              title: tileTitle('about_application'),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () => Get.toNamed<void>(AppRoutes.aboutUs),
            ),
            FTile(
              prefix: const Icon(FLucideIcons.circleHelp),
              title: tileTitle('help_faq'),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () => _showFaqSheet(context),
            ),
            FTile(
              prefix: const Icon(FLucideIcons.messageSquare),
              title: tileTitle('leave_feedback'),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () => _showFeedbackSheet(context),
            ),
            FTile(
              prefix: const Icon(FLucideIcons.scrollText),
              title: tileTitle('dev_logs'),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () => Get.toNamed<void>(AppRoutes.devLogs),
            ),
            FTile(
              prefix: const Icon(FLucideIcons.sparkles),
              title: tileTitle('clear_cache'),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () => _clearCache(context),
            ),
            FTile(
              variant: FItemVariant.destructive,
              prefix: const Icon(FLucideIcons.trash2),
              title: tileTitle('delete_account'),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () => _showDeleteAccountDialog(context),
            ),
            FTile(
              variant: FItemVariant.destructive,
              prefix: const Icon(FLucideIcons.logOut),
              title: tileTitle('sign_out'),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () => _showLogoutDialog(context),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _AppCredits(),
      ],
    );

    // Build the header widget separately so we can measure its height.
    final header = BlurredHeader(
      child: FHeader.nested(
        title: Text(
          'settings'.tr,
          style: theme.typography.body.lg.copyWith(fontWeight: FontWeight.w700),
        ),
        prefixes: widget.showBottomNav ?? true
            ? [FHeaderAction.back(onPress: () => Get.back<void>())]
            : const [],
        suffixes: [
          FHeaderAction(
            icon: const Icon(FLucideIcons.flag),
            onPress: () => Get.toNamed<void>(AppRoutes.report),
          ),
        ],
      ),
    );

    final body = Stack(
      children: [
        Positioned.fill(child: content),
        Positioned(top: 0, left: 0, right: 0, child: header),
      ],
    );

    // The tab shell already provides an FScaffold. Avoid nesting another
    // ForUI scaffold/FSheets tree, which can trigger duplicate global-key and
    // adaptive-scope assertions when switching to Settings.
    if (widget.showBottomNav == false) return body;
    return FScaffold(child: body);
  }

  void _openProfile() {
    Get.toNamed<void>(AppRoutes.profile);
  }

  void _showLanguageDialog(BuildContext context) {
    final controller = Get.find<LanguageController>();

    showFDialog<void>(
      context: context,
      builder: (dialogContext, _, animation) => FDialog(
        style: _roundedDialogStyle,
        animation: animation,
        clipBehavior: Clip.antiAlias,
        semanticsLabel: 'choose_language'.tr,
        builder: (dialogContext, _) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'choose_language'.tr,
                style: FTheme.of(dialogContext).typography.display.lg,
              ),
              const SizedBox(height: 16),
              for (final language in AppLanguage.values) ...[
                Obx(
                  () => FButton(
                    variant: controller.current == language
                        ? FButtonVariant.primary
                        : FButtonVariant.secondary,
                    onPress: () {
                      controller.selectLanguage(language);
                      Navigator.of(dialogContext).pop();
                    },
                    prefix: controller.current == language
                        ? const Icon(FLucideIcons.check)
                        : const Icon(FLucideIcons.languages),
                    child: Text(
                      language == AppLanguage.english ? 'English' : 'ខ្មែរ',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              FButton(
                variant: FButtonVariant.ghost,
                onPress: () => Navigator.of(dialogContext).pop(),
                child: Text('cancel'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _setFaceId(BuildContext context, bool value) async {
    if (!value) {
      await AppSecurityService.to.setBiometricEnabled(false);
      if (!mounted) return;
      setState(() => _faceIdEnabled = false);
      return;
    }

    await AppSecurityService.to.ready;
    if (!AppSecurityService.to.hasPin.value) {
      Get.snackbar(
        'Set a passcode first',
        'A passcode is required as a fallback when Face ID is unavailable.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final available = await AppSecurityService.to.canUseBiometrics();
    if (!available) {
      Get.snackbar(
        'Face ID unavailable',
        'No enrolled biometric was found on this device.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    // Enable temporarily so the service permits this enrollment check.
    await AppSecurityService.to.setBiometricEnabled(true);
    final verified = await AppSecurityService.to.authenticateBiometrically(
      'Confirm Face ID to enable it for Jobodia',
    );
    if (!verified) {
      await AppSecurityService.to.setBiometricEnabled(false);
      return;
    }
    if (!mounted) return;
    setState(() => _faceIdEnabled = true);
  }

  void _openRolePreview() {
    Get.to<void>(() => const RoleSelectionScreen(preview: true));
  }

  void _togglePerformanceOverlay(BuildContext context) {
    if (_performanceOverlay != null) {
      _removePerformanceOverlay();
      return;
    }
    _performanceOverlay = OverlayEntry(
      builder: (overlayContext) => Positioned(
        right: 16,
        bottom: MediaQuery.paddingOf(overlayContext).bottom + 18,
        child: PerformanceDebugOverlay(onClose: _removePerformanceOverlay),
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_performanceOverlay!);
  }

  void _removePerformanceOverlay() {
    _performanceOverlay?.remove();
    _performanceOverlay = null;
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
    showFSheet<void>(
      context: context,
      side: FLayout.btt,
      mainAxisMaxRatio: 0.82,
      useSafeArea: true,
      barrierDismissible: true,
      builder: (_) => const _FeedbackSheet(),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showFDialog<void>(
      context: context,
      builder: (dialogContext, _, animation) => FDialog(
        style: _roundedDialogStyle,
        animation: animation,
        clipBehavior: Clip.antiAlias,
        semanticsLabel: 'Log out confirmation',
        builder: (dialogContext, _) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Log out?',
                style: FTheme.of(dialogContext).typography.display.lg,
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to log out?',
                style: FTheme.of(dialogContext).typography.body.sm,
              ),
              const SizedBox(height: 20),
              FButton(
                variant: FButtonVariant.destructive,
                onPress: () async {
                  Navigator.of(dialogContext).pop();
                  final authenticated = await requestAppAuthentication(
                    context,
                    reason: 'Confirm your identity to log out.',
                  );
                  if (!authenticated) return;
                  await Get.find<AuthController>().logout();
                },
                child: const Text('Log out'),
              ),
              const SizedBox(height: 10),
              FButton(
                variant: FButtonVariant.secondary,
                onPress: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showFDialog<void>(
      context: context,
      builder: (dialogContext, _, animation) => FDialog(
        style: _roundedDialogStyle,
        animation: animation,
        clipBehavior: Clip.antiAlias,
        semanticsLabel: 'delete_account_title'.tr,
        builder: (dialogContext, _) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: FTheme.of(
                      dialogContext,
                    ).colors.destructive.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    FLucideIcons.triangleAlert,
                    color: FTheme.of(dialogContext).colors.destructive,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'delete_account_title'.tr,
                style: FTheme.of(
                  dialogContext,
                ).typography.display.lg.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'delete_account_warning'.tr,
                style: FTheme.of(dialogContext).typography.body.sm.copyWith(
                  color: FTheme.of(dialogContext).colors.mutedForeground,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              FButton(
                variant: FButtonVariant.destructive,
                onPress: () async {
                  Navigator.of(dialogContext).pop();
                  final authenticated = await requestAppAuthentication(
                    context,
                    reason: 'Confirm your identity to delete your account.',
                  );
                  if (!authenticated) return;
                  Get.snackbar(
                    'delete_unavailable_title'.tr,
                    'delete_unavailable_message'.tr,
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                  );
                },
                child: Text('delete_account_confirm'.tr),
              ),
              const SizedBox(height: 10),
              FButton(
                variant: FButtonVariant.secondary,
                onPress: () => Navigator.of(dialogContext).pop(),
                child: Text('cancel'.tr),
              ),
            ],
          ),
        ),
      ),
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
    final security = AppSecurityService.to;
    await security.ready;
    if (!context.mounted) return;

    if (security.hasPin.value) {
      final authenticated = await requestAppAuthentication(
        context,
        reason: 'Confirm your current passcode to change it.',
      );
      if (!authenticated || !context.mounted) return;
    }

    final saved = await createAppPasscode(context);
    if (!mounted || !saved) return;
    Get.snackbar(
      'Passcode saved',
      'Sensitive actions are now protected.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
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

  @override
  void dispose() {
    _removePerformanceOverlay();
    _scrollController.dispose();
    super.dispose();
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
    final theme = FTheme.of(context);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: ColoredBox(
        color: theme.colors.background,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            10,
            20,
            MediaQuery.viewInsetsOf(context).bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Leave Feedback',
                style: theme.typography.display.sm.copyWith(
                  color: theme.colors.foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'We appreciate your thoughts!',
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final filled = i < _selectedRating;
                  return FButton.raw(
                    onPress: () => setState(() => _selectedRating = i + 1),
                    variant: FButtonVariant.ghost,
                    style: const FButtonStyleDelta.delta(
                      contentStyle: FButtonContentStyleDelta.delta(
                        constraints: BoxConstraints(
                          minWidth: 44,
                          minHeight: 44,
                        ),
                        padding: EdgeInsetsGeometryDelta.value(EdgeInsets.zero),
                      ),
                    ),
                    child: Icon(
                      FLucideIcons.star,
                      color: filled
                          ? const Color(0xFFFFC107)
                          : theme.colors.mutedForeground.withValues(alpha: 0.5),
                      size: 30,
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
              SizedBox(
                width: double.infinity,
                child: FButton(
                  onPress: _selectedRating == 0
                      ? null
                      : () {
                          if (!Get.isRegistered<FeedbackController>()) {
                            Get.lazyPut<FeedbackController>(
                              FeedbackController.new,
                            );
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppCredits extends StatelessWidget {
  const _AppCredits();

  static const _assetRoot = 'assets/images/branding';

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final typography = FTheme.of(context).typography;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(
            'app_version'.tr,
            style: typography.body.xs.copyWith(
              color: palette.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'made_by'.tr,
                style: typography.body.sm.copyWith(
                  color: palette.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  '$_assetRoot/cambodia_flag.png',
                  width: 28,
                  height: 18,
                  fit: BoxFit.cover,
                  cacheWidth: 84,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
