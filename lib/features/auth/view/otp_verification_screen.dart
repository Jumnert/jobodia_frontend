import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/custom_button.dart';
import 'package:jobodia_frontend/core/widgets/gradient_header_painter.dart';
import 'package:jobodia_frontend/features/auth/controller/auth_controller.dart';
import 'package:jobodia_frontend/features/auth/view/widgets/otp_input_field.dart';

/// OTP verification screen shown after Register succeeds.
class OtpVerificationScreen extends GetView<AuthController> {
  const OtpVerificationScreen({super.key});

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
                const headerHeight = 238.0;

                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      children: [
                        _OtpHeader(
                          height: headerHeight,
                          controller: controller,
                        ),
                        Container(
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
                              14,
                              26,
                              14,
                              MediaQuery.paddingOf(context).bottom + 28,
                            ),
                            child: const _OtpContent(),
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

class _OtpHeader extends StatelessWidget {
  const _OtpHeader({required this.height, required this.controller});

  final double height;
  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
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
                      onPressed: controller.goBackToLogin,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF5B5D5F)),
                        padding: EdgeInsets.zero,
                        shape: const StadiumBorder(),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, size: 18),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Verify Your Email',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Enter the 6-digit code sent to your email',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpContent extends GetView<AuthController> {
  const _OtpContent();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Verify Gmail',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            controller.registeredEmail.value.isEmpty
                ? 'your email'
                : controller.registeredEmail.value,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 22),
          const OtpInputField(),
          const SizedBox(height: 8),
          _AnimatedErrorMessage(controller.errorMessage.value),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: controller.isResendingOtp.value
                  ? null
                  : controller.resendOtp,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.only(left: 12),
              ),
              child: Text(
                controller.isResendingOtp.value ? 'Sending...' : 'Resend OTP',
              ),
            ),
          ),
          const SizedBox(height: 4),
          CustomButton(
            label: 'Confirm',
            isLoading: controller.isLoading.value,
            onPressed: controller.isLoading.value ? null : controller.verifyOtp,
          ),
          const SizedBox(height: 22),
          Center(
            child: GestureDetector(
              onTap: controller.goBackToLogin,
              child: const Text(
                'Back to Login',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
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
          ? const SizedBox.shrink(key: ValueKey('otp_no_error'))
          : Padding(
              key: ValueKey(message),
              padding: const EdgeInsets.only(bottom: 8),
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
