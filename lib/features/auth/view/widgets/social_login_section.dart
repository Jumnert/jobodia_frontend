import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/auth/controller/auth_controller.dart';
import 'package:jobodia_frontend/features/auth/repository/auth_repository.dart';
import 'package:jobodia_frontend/features/auth/view/widgets/social_login_button.dart';

/// Shared social auth section for login and sign-up.
class SocialLoginSection extends StatelessWidget {
  const SocialLoginSection({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(indent: 20, endIndent: 16)),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const Expanded(child: Divider(indent: 16, endIndent: 20)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => IgnorePointer(
                  ignoring: controller.isLoading.value,
                  child: Opacity(
                    opacity: controller.isLoading.value ? 0.55 : 1,
                    child: SocialLoginButton(
                      text: 'Google',
                      iconPath: 'assets/icons/google.png',
                      onTap: () =>
                          controller.loginWithOAuth(OAuthProvider.google),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Obx(
                () => IgnorePointer(
                  ignoring: controller.isLoading.value,
                  child: Opacity(
                    opacity: controller.isLoading.value ? 0.55 : 1,
                    child: SocialLoginButton(
                      text: 'GitHub',
                      iconPath: 'assets/icons/github.png',
                      onTap: () =>
                          controller.loginWithOAuth(OAuthProvider.github),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
