import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/custom_button.dart';
import 'package:jobodia_frontend/core/widgets/custom_text_field.dart';
import 'package:jobodia_frontend/features/auth/controller/auth_controller.dart';

/// Login form UI. Validation and actions live in AuthController.
class LoginForm extends GetView<AuthController> {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          label: 'Email',
          hintText: 'example@gmail.com',
          controller: controller.emailController,
          prefixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        Obx(
          () => CustomTextField(
            label: 'Password',
            hintText: 'Enter your password',
            controller: controller.passwordController,
            prefixIcon: Icons.key_rounded,
            obscureText: !controller.isPasswordVisible.value,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              if (!controller.isLoading.value) controller.login();
            },
            suffixIcon: _PasswordVisibilityButton(
              isVisible: controller.isPasswordVisible.value,
              onPressed: controller.togglePasswordVisibility,
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
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.only(left: 12),
            ),
            child: const Text('Forgot Password?'),
          ),
        ),
        Obx(() => _AnimatedErrorMessage(controller.errorMessage.value)),
        Obx(
          () => CustomButton(
            label: 'Log in',
            isLoading: controller.isLoading.value,
            onPressed: controller.isLoading.value
                ? null
                : () {
                    unawaited(HapticFeedback.lightImpact());
                    controller.login();
                  },
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            unawaited(HapticFeedback.lightImpact());
            controller.skipLogin();
          },
          style: TextButton.styleFrom(foregroundColor: palette.textSecondary),
          child: const Text('Skip login'),
        ),
        const SizedBox(height: 12),
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
          color: context.palette.textSecondary,
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
                style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
    );
  }
}
