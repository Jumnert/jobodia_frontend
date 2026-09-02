import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/localization/language_controller.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

/// First-run language choice shown after onboarding and before authentication.
class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  AppLanguage? _selectedLanguage;

  LanguageController get _controller => Get.find<LanguageController>();

  Future<void> _select(AppLanguage language) async {
    HapticFeedback.selectionClick();
    await _controller.selectLanguage(language);
    if (!mounted) return;
    setState(() => _selectedLanguage = language);
  }

  void _continue() {
    if (_selectedLanguage == null) return;
    HapticFeedback.lightImpact();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.isDark;
    final overlayStyle = isDark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: palette.scaffold,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: palette.scaffold,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Jobodia',
                      style: FTheme.of(context).typography.body.lg.copyWith(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 38),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'language_setup_title'.tr,
                              style: FTheme.of(context).typography.display.lg
                                  .copyWith(
                                    color: palette.textPrimary,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.6,
                                    height: 1.05,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'language_setup_subtitle'.tr,
                              style: FTheme.of(context).typography.body.md
                                  .copyWith(
                                    color: palette.textSecondary,
                                    height: 1.45,
                                  ),
                            ),
                            const SizedBox(height: 34),
                            _LanguageCard(
                              language: AppLanguage.english,
                              assetPath: 'assets/images/branding/usa_flag.png',
                              title: 'English',
                              subtitle: 'Continue in English',
                              selected:
                                  _selectedLanguage == AppLanguage.english,
                              onTap: () => _select(AppLanguage.english),
                            ),
                            const SizedBox(height: 14),
                            _LanguageCard(
                              language: AppLanguage.khmer,
                              assetPath:
                                  'assets/images/branding/cambodia_flag.png',
                              title: 'ខ្មែរ',
                              subtitle: 'បន្តជាភាសាខ្មែរ',
                              selected: _selectedLanguage == AppLanguage.khmer,
                              onTap: () => _select(AppLanguage.khmer),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      child: FilledButton(
                        onPressed: _selectedLanguage == null ? null : _continue,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.brandPrimary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: palette.surfaceMuted,
                          disabledForegroundColor: palette.textTertiary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'language_setup_continue'.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.language,
    required this.assetPath,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final AppLanguage language;
  final String assetPath;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final selectedFill = AppColors.brandPrimary.withValues(
      alpha: context.isDark ? 0.18 : 0.08,
    );

    return Semantics(
      button: true,
      selected: selected,
      label: subtitle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: selected ? selectedFill : palette.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? AppColors.brandPrimary : palette.border,
            width: selected ? 2 : 1,
          ),
          boxShadow: context.isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.035),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 64,
                      height: 44,
                      child: Image.asset(
                        assetPath,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                  ),
                  const SizedBox(width: 17),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: FTheme.of(context).typography.body.lg.copyWith(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontFamily: language.fontFamily,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: FTheme.of(context).typography.body.sm.copyWith(
                            color: palette.textSecondary,
                            fontFamily: language.fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? AppColors.brandPrimary
                          : Colors.transparent,
                      border: Border.all(
                        color: selected
                            ? AppColors.brandPrimary
                            : palette.border,
                        width: 1.5,
                      ),
                    ),
                    child: selected
                        ? const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
