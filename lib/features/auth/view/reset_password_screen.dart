import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/custom_button.dart';
import 'package:jobodia_frontend/core/widgets/gradient_header_painter.dart';
import 'package:jobodia_frontend/core/widgets/custom_text_field.dart';
import 'package:jobodia_frontend/features/auth/controller/auth_controller.dart';

/// Displays the reset password form backed by AuthController.
class ResetPasswordScreen extends GetView<AuthController> {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.headerStart,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final headerHeight = (constraints.maxHeight * 0.34).clamp(
                  220.0,
                  270.0,
                );

                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      children: [
                        _ResetPasswordHeader(
                          height: headerHeight,
                          onBack: () {
                            controller.clearResetPasswordForm();
                            Get.back<void>();
                          },
                        ),
                        Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight - headerHeight,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(28),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              18,
                              18,
                              18,
                              MediaQuery.paddingOf(context).bottom + 24,
                            ),
                            child: const _ResetPasswordForm(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ResetPasswordHeader extends StatelessWidget {
  const _ResetPasswordHeader({required this.height, required this.onBack});

  final double height;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const CustomPaint(painter: GradientHeaderPainter()),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 13, 25, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 46,
                    height: 32,
                    child: OutlinedButton(
                      onPressed: onBack,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                        shape: const StadiumBorder(),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 15),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Reset Your Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Create a new password to secure your account.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResetPasswordForm extends GetView<AuthController> {
  const _ResetPasswordForm();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(
          () => CustomTextField(
            label: 'New Password',
            hintText: 'Min 8 chars, upper + lower + number',
            controller: controller.newPasswordController,
            prefixIcon: Icons.key_rounded,
            obscureText: !controller.isNewPasswordVisible.value,
            textInputAction: TextInputAction.next,
            maxLength: 128,
            suffixIcon: _PasswordVisibilityButton(
              isVisible: controller.isNewPasswordVisible.value,
              onPressed: controller.toggleNewPasswordVisibility,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => CustomTextField(
            label: 'Confirm Password',
            hintText: 'Confirm new password',
            controller: controller.resetConfirmPasswordController,
            prefixIcon: Icons.key_rounded,
            obscureText: !controller.isResetConfirmPasswordVisible.value,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              if (!controller.isResetPasswordLoading.value) {
                controller.resetPassword();
              }
            },
            suffixIcon: _PasswordVisibilityButton(
              isVisible: controller.isResetConfirmPasswordVisible.value,
              onPressed: controller.toggleResetConfirmPasswordVisibility,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () =>
              _AnimatedErrorMessage(controller.resetPasswordErrorMessage.value),
        ),
        Obx(
          () => CustomButton(
            label: 'Reset Password',
            isLoading: controller.isResetPasswordLoading.value,
            onPressed: controller.isResetPasswordLoading.value
                ? null
                : controller.resetPassword,
          ),
        ),
      ],
    );
  }
}

class _AnimatedErrorMessage extends StatelessWidget {
  const _AnimatedErrorMessage(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
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
          ? const SizedBox.shrink(key: ValueKey('reset_password_no_error'))
          : Padding(
              key: ValueKey(message),
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
    );
  }
}

class _PasswordVisibilityButton extends StatelessWidget {
  const _PasswordVisibilityButton({
    required this.isVisible,
    required this.onPressed,
  });

  final bool isVisible;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: isVisible ? 'Hide password' : 'Show password',
      onPressed: onPressed,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeInOutCubic,
        switchOutCurve: Curves.easeInOutCubic,
        child: Icon(
          isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          key: ValueKey(isVisible),
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
