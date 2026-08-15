import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/auth/controller/auth_controller.dart';

/// Register form UI. Validation and actions live in AuthController.
class SignUpForm extends GetView<AuthController> {
  const SignUpForm({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FTextField(
          control: FTextFieldControl.managed(
            controller: controller.usernameController,
          ),
          label: const Text('Username'),
          hint: 'John Doe',
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 -]')),
          ],
          prefixBuilder: (context, style, variants) =>
              FTextField.prefixIconBuilder(
                context,
                style,
                variants,
                const Icon(FLucideIcons.circleUser),
              ),
        ),
        const SizedBox(height: 12),
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
        const SizedBox(height: 12),
        Obx(
          () => FTextField(
            control: FTextFieldControl.managed(
              controller: controller.passwordController,
            ),
            label: const Text('Password'),
            hint: 'Min 8 chars, upper + lower + number',
            obscureText: !controller.isPasswordVisible.value,
            textInputAction: TextInputAction.next,
            maxLength: 128,
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
        const SizedBox(height: 12),
        Obx(
          () => FTextField(
            control: FTextFieldControl.managed(
              controller: controller.confirmPasswordController,
            ),
            label: const Text('Confirm Password'),
            hint: 'Confirm your password',
            obscureText: !controller.isConfirmPasswordVisible.value,
            textInputAction: TextInputAction.done,
            onSubmit: (_) {
              if (!controller.isLoading.value) controller.signUp();
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
                onPress: controller.toggleConfirmPasswordVisibility,
                child: Icon(
                  controller.isConfirmPasswordVisible.value
                      ? FLucideIcons.eye
                      : FLucideIcons.eyeClosed,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(() => _AnimatedErrorMessage(controller.errorMessage.value)),
        Obx(
          () => FButton(
            onPress: controller.isLoading.value
                ? null
                : () {
                    unawaited(HapticFeedback.lightImpact());
                    controller.signUp();
                  },
            prefix: controller.isLoading.value
                ? const FCircularProgress()
                : null,
            child: Text(controller.isLoading.value ? 'Please wait' : 'Sign up'),
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Already have an account? ',
              style: TextStyle(color: palette.textSecondary),
            ),
            GestureDetector(
              onTap: () => controller.changeAuthTab(0),
              child: Text(
                'Log in',
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
          ? const SizedBox.shrink(key: ValueKey('signup_no_error'))
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
