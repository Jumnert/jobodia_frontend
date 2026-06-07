import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/auth/view/widgets/social_login_button.dart';

/// Shared social login/sign-up row used by both auth forms.
class SocialLoginSection extends StatelessWidget {
  const SocialLoginSection({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
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
              child: SocialLoginButton(
                text: 'Google',
                iconPath: 'assets/icons/google.png',
                onTap: () => Get.snackbar(
                  'Coming soon',
                  'Google login coming soon',
                  snackPosition: SnackPosition.BOTTOM,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SocialLoginButton(
                text: 'Github',
                iconPath: 'assets/icons/github.png',
                onTap: () => Get.snackbar(
                  'Coming soon',
                  'GitHub login coming soon',
                  snackPosition: SnackPosition.BOTTOM,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
