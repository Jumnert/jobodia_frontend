import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/gradient_header_painter.dart';
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
                  FButton.icon(
                    variant: FButtonVariant.ghost,
                    onPress: onBack,
                    child: const Icon(
                      FLucideIcons.arrowLeft,
                      color: Colors.white,
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
        FTextField(
          control: FTextFieldControl.managed(
            controller: controller.resetEmailController,
          ),
          label: const Text('Account Email'),
          hint: 'you@example.com',
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: FTextField(
                control: FTextFieldControl.managed(
                  controller: controller.resetOtpController,
                ),
                label: const Text('Reset Code'),
                hint: '6 digits',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                prefixBuilder: (context, style, variants) =>
                    FTextField.prefixIconBuilder(
                      context,
                      style,
                      variants,
                      const Icon(FLucideIcons.shieldCheck),
                    ),
              ),
            ),
            const SizedBox(width: 10),
            Obx(
              () => FButton(
                onPress: controller.isResendingOtp.value
                    ? null
                    : controller.sendResetOtp,
                child: Text(
                  controller.isResendingOtp.value ? 'Sending' : 'Send code',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(
          () => FTextField(
            control: FTextFieldControl.managed(
              controller: controller.newPasswordController,
            ),
            label: const Text('New Password'),
            hint: 'Min 8 chars, upper + lower + number',
            obscureText: !controller.isNewPasswordVisible.value,
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
                onPress: controller.toggleNewPasswordVisibility,
                child: Icon(
                  controller.isNewPasswordVisible.value
                      ? FLucideIcons.eye
                      : FLucideIcons.eyeClosed,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => FTextField(
            control: FTextFieldControl.managed(
              controller: controller.resetConfirmPasswordController,
            ),
            label: const Text('Confirm Password'),
            hint: 'Confirm new password',
            obscureText: !controller.isResetConfirmPasswordVisible.value,
            textInputAction: TextInputAction.done,
            onSubmit: (_) {
              if (!controller.isResetPasswordLoading.value) {
                controller.resetPassword();
              }
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
                onPress: controller.toggleResetConfirmPasswordVisibility,
                child: Icon(
                  controller.isResetConfirmPasswordVisible.value
                      ? FLucideIcons.eye
                      : FLucideIcons.eyeClosed,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () =>
              _AnimatedErrorMessage(controller.resetPasswordErrorMessage.value),
        ),
        Obx(
          () => FButton(
            onPress: controller.isResetPasswordLoading.value
                ? null
                : controller.resetPassword,
            prefix: controller.isResetPasswordLoading.value
                ? const FCircularProgress()
                : null,
            child: Text(
              controller.isResetPasswordLoading.value
                  ? 'Please wait'
                  : 'Reset Password',
            ),
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
