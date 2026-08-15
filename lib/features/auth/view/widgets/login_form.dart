import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/localization/language_controller.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/auth/controller/auth_controller.dart';
import 'package:jobodia_frontend/features/auth/view/widgets/social_login_section.dart';

/// Login form UI. Validation and actions live in AuthController.
class LoginForm extends GetView<AuthController> {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FTextField(
          control: FTextFieldControl.managed(
            controller: controller.emailController,
          ),
          label: const Text('Email'),
          hint: 'example@gmail.com',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          prefixBuilder: (context, style, variants) =>
              FTextField.prefixIconBuilder(
                context,
                style,
                variants,
                const Icon(FLucideIcons.mail),
              ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => FTextField(
            control: FTextFieldControl.managed(
              controller: controller.passwordController,
            ),
            label: const Text('Password'),
            hint: 'Enter your password',
            obscureText: !controller.isPasswordVisible.value,
            textInputAction: TextInputAction.done,
            onSubmit: (_) {
              if (!controller.isLoading.value) controller.login();
            },
            prefixBuilder: (context, style, variants) =>
                FTextField.prefixIconBuilder(
                  context,
                  style,
                  variants,
                  const Icon(FLucideIcons.key),
                ),
            suffixBuilder: (context, style, variants) => Padding(
              padding: const EdgeInsetsDirectional.only(end: 4),
              child: FButton.icon(
                variant: FButtonVariant.ghost,
                onPress: controller.togglePasswordVisibility,
                child: Icon(
                  controller.isPasswordVisible.value
                      ? FLucideIcons.eye
                      : FLucideIcons.eyeClosed,
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              controller.clearResetPasswordForm();
              Get.toNamed(AppRoutes.resetPassword);
            },
            style: TextButton.styleFrom(
              foregroundColor: palette.textSecondary,
              padding: const EdgeInsets.only(left: 12),
            ),
            child: const Text('Forgot Password?'),
          ),
        ),
        Obx(() => _AnimatedErrorMessage(controller.errorMessage.value)),
        Obx(
          () => FButton(
            onPress: controller.isLoading.value
                ? null
                : () {
                    unawaited(HapticFeedback.lightImpact());
                    controller.login();
                  },
            prefix: controller.isLoading.value
                ? const FCircularProgress()
                : null,
            child: Text(controller.isLoading.value ? 'Please wait' : 'Log in'),
          ),
        ),
        const SizedBox(height: 20),
        const SocialLoginSection(title: 'Or continue with'),
        const SizedBox(height: 8),
        FButton(
          variant: FButtonVariant.ghost,
          onPress: () => _showOfflineDialog(context),
          child: const Text('Skip login'),
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: TextStyle(color: palette.textSecondary),
            ),
            GestureDetector(
              onTap: () => controller.changeAuthTab(1),
              child: Text(
                'Register',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showOfflineDialog(BuildContext context) {
    showFDialog<void>(
      context: context,
      barrierDismissible: false,
      useSafeArea: true,
      builder: (dialogContext, _, animation) => FDialog(
        animation: animation,
        clipBehavior: Clip.antiAlias,
        style: FDialogStyleDelta.delta(
          decoration: DecorationDelta.shapeDelta(
            shape: RoundedSuperellipseBorder(
              side: BorderSide(color: FTheme.of(context).colors.border),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        semanticsLabel: 'UAT testing notice',
        builder: (dialogContext, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    FLucideIcons.circleAlert,
                    size: 22,
                    color: AppColors.brandTeal,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'UAT testing notice',
                      style: FTheme.of(dialogContext).typography.body.md
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'This is a user acceptance testing build. Some features may be incomplete, and known bugs or unexpected behavior may occur while we test and improve the app.',
                style: FTheme.of(dialogContext).typography.body.md,
              ),
              const SizedBox(height: 24),
              FButton(
                onPress: () {
                  Navigator.of(dialogContext).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) _showLanguageDialog(context);
                  });
                },
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final languageController = Get.find<LanguageController>();

    showFDialog<void>(
      context: context,
      barrierDismissible: false,
      useSafeArea: true,
      builder: (dialogContext, _, animation) => FDialog(
        animation: animation,
        clipBehavior: Clip.antiAlias,
        style: FDialogStyleDelta.delta(
          decoration: DecorationDelta.shapeDelta(
            shape: RoundedSuperellipseBorder(
              side: BorderSide(color: FTheme.of(context).colors.border),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        semanticsLabel: 'Choose your language',
        builder: (dialogContext, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Choose your language',
                textAlign: TextAlign.center,
                style: FTheme.of(
                  dialogContext,
                ).typography.display.sm.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'ជ្រើសរើសភាសារបស់អ្នក',
                textAlign: TextAlign.center,
                style: FTheme.of(dialogContext).typography.body.md.copyWith(
                  color: FTheme.of(dialogContext).colors.mutedForeground,
                  fontFamily: 'KantumruyPro',
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _LanguageFlagButton(
                      assetPath: 'assets/images/branding/usa_flag.png',
                      label: 'English',
                      semanticsLabel: 'Continue in English',
                      onPress: () => _chooseLanguage(
                        dialogContext,
                        languageController,
                        AppLanguage.english,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _LanguageFlagButton(
                      assetPath: 'assets/images/branding/cambodia_flag.png',
                      label: 'ខ្មែរ',
                      semanticsLabel: 'បន្តជាភាសាខ្មែរ',
                      fontFamily: 'KantumruyPro',
                      onPress: () => _chooseLanguage(
                        dialogContext,
                        languageController,
                        AppLanguage.khmer,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _chooseLanguage(
    BuildContext dialogContext,
    LanguageController languageController,
    AppLanguage language,
  ) {
    HapticFeedback.selectionClick();
    languageController.selectLanguage(language);
    Navigator.of(dialogContext).pop();
    controller.skipLogin();
  }
}

class _LanguageFlagButton extends StatelessWidget {
  const _LanguageFlagButton({
    required this.assetPath,
    required this.label,
    required this.semanticsLabel,
    required this.onPress,
    this.fontFamily,
  });

  final String assetPath;
  final String label;
  final String semanticsLabel;
  final VoidCallback onPress;
  final String? fontFamily;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: SizedBox(
        height: 154,
        child: FButton.raw(
          variant: FButtonVariant.secondary,
          onPress: onPress,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Image.asset(
                      assetPath,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 32,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: theme.typography.body.lg.copyWith(
                        fontWeight: FontWeight.w700,
                        fontFamily: fontFamily,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedErrorMessage extends StatelessWidget {
  const _AnimatedErrorMessage(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            alignment: Alignment.topCenter,
            child: child,
          ),
        );
      },
      child: message.isEmpty
          ? const SizedBox.shrink(key: ValueKey('login_no_error'))
          : Padding(
              key: ValueKey(message),
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colors.destructive,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
    );
  }
}
