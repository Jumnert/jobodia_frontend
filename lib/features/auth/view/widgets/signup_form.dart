import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/custom_button.dart';
import 'package:jobodia_frontend/core/widgets/custom_text_field.dart';
import 'package:jobodia_frontend/features/auth/controller/auth_controller.dart';
import 'package:jobodia_frontend/features/auth/view/widgets/social_login_section.dart';

/// Register form UI. Validation and actions live in AuthController.
class SignUpForm extends GetView<AuthController> {
  const SignUpForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          label: 'Username',
          hintText: 'Elon Musk',
          controller: controller.usernameController,
          prefixIcon: Icons.person_outline_rounded,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
          ],
        ),
        const SizedBox(height: 12),
        CustomTextField(
          label: 'Email',
          hintText: 'example@gmail.com',
          controller: controller.emailController,
          prefixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        Obx(
          () => CustomTextField(
            label: 'Password',
            hintText: 'Create a password',
            controller: controller.passwordController,
            prefixIcon: Icons.key_rounded,
            obscureText: !controller.isPasswordVisible.value,
            textInputAction: TextInputAction.next,
            suffixIcon: _PasswordVisibilityButton(
              isVisible: controller.isPasswordVisible.value,
              onPressed: controller.togglePasswordVisibility,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => CustomTextField(
            label: 'Confirm Password',
            hintText: 'Confirm your password',
            controller: controller.confirmPasswordController,
            prefixIcon: Icons.key_rounded,
            obscureText: !controller.isConfirmPasswordVisible.value,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              if (!controller.isLoading.value) controller.signUp();
            },
            suffixIcon: _PasswordVisibilityButton(
              isVisible: controller.isConfirmPasswordVisible.value,
              onPressed: controller.toggleConfirmPasswordVisibility,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(() => _AnimatedErrorMessage(controller.errorMessage.value)),
        Obx(
          () => CustomButton(
            label: 'Sign up',
            isLoading: controller.isLoading.value,
            onPressed: controller.isLoading.value ? null : controller.signUp,
          ),
        ),
        const SizedBox(height: 18),
        const SocialLoginSection(title: 'or Sign up with'),
        const SizedBox(height: 22),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              'Already have an account? ',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            GestureDetector(
              onTap: () => controller.changeAuthTab(0),
              child: const Text(
                'Log in',
                style: TextStyle(
                  color: AppColors.textPrimary,
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
          color: AppColors.textSecondary,
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
          ? const SizedBox.shrink(key: ValueKey('signup_no_error'))
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
