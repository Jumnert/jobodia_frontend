import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/features/home/controller/home_controller.dart';
import 'package:jobodia_frontend/features/home/controller/main_nav_controller.dart';

/// Switches the main bottom-nav tab.
///
/// Tab selection lives in [MainNavController] (the single source of truth that
/// the live [MainShellScreen] renders). Tapping a tab updates that controller
/// and then returns to the shell, rather than pushing a duplicate standalone
/// screen on top of it — which was the cause of taps that appeared to do
/// nothing (a second copy of the same tab was shown over the real one).
void navigateMainDestination(
  BuildContext context,
  int index, {
  required int currentIndex,
}) {
  // Re-tapping the active tab scrolls Home back to the top.
  if (currentIndex == index) {
    if (index == 0 && Get.isRegistered<HomeController>()) {
      final ctrl = Get.find<HomeController>().scrollController;
      if (ctrl.hasClients) {
        ctrl.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
    return;
  }

  // Drive the shared selection so the live shell shows the requested tab.
  if (Get.isRegistered<MainNavController>()) {
    Get.find<MainNavController>().goToTab(index);
  }

  // Already on the shell — the Obx rebuild above is all that's needed.
  if (Get.currentRoute == AppRoutes.home) {
    return;
  }

  // Reached from a standalone screen: pop back to the live shell. The
  // `isFirst` guard prevents popping past the root if the shell isn't found.
  Get.until((route) => route.settings.name == AppRoutes.home || route.isFirst);
}
