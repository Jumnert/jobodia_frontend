import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Single source of truth for the main bottom-nav tab selection.
///
/// Both [MainShellScreen] (the IndexedStack host) and any standalone screen
/// reached via a deep link drive the selected tab through this controller, so
/// tab navigation behaves consistently no matter how a screen was opened.
class MainNavController extends GetxController {
  static const tabCount = 4;

  final RxInt selectedTab = 0.obs;

  /// Whether the floating nav bar is collapsed (shrunk to just the active
  /// tab) — driven by scroll direction in the content area.
  final RxBool collapsed = false.obs;

  void setCollapsed(bool value) {
    if (collapsed.value != value) collapsed.value = value;
  }

  void goToTab(int index) {
    if (index < 0 || index >= tabCount) return;
    if (selectedTab.value == index) return;
    HapticFeedback.selectionClick();
    selectedTab.value = index;
  }
}
