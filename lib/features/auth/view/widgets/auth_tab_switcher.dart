import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/auth/controller/auth_controller.dart';

/// Custom pill-style Login/Register switcher.
class AuthTabSwitcher extends GetView<AuthController> {
  const AuthTabSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedIndex = controller.selectedAuthTab.value;

      return Container(
        width: double.infinity,
        height: 55,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E2E2),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              alignment: selectedIndex == 0
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                heightFactor: 1,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.16),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: _TabText(
                    label: 'Log in',
                    isSelected: selectedIndex == 0,
                    onTap: () => controller.changeAuthTab(0),
                  ),
                ),
                Expanded(
                  child: _TabText(
                    label: 'Sign up',
                    isSelected: selectedIndex == 1,
                    onTap: () => controller.changeAuthTab(1),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _TabText extends StatelessWidget {
  const _TabText({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontSize: 17,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
        child: Center(child: Text(label)),
      ),
    );
  }
}
