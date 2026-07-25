import 'package:jobodia_frontend/core/widgets/platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/features/auth/controller/auth_controller.dart';

/// Custom pill-style Login/Register switcher, now using AdaptiveSegmentedControl
class AuthTabSwitcher extends GetView<AuthController> {
  const AuthTabSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedIndex = controller.selectedAuthTab.value;

      return AdaptiveSegmentedControl(
        labels: const ['Log in', 'Sign up'],
        selectedIndex: selectedIndex,
        onValueChanged: controller.changeAuthTab,
      );
    });
  }
}
