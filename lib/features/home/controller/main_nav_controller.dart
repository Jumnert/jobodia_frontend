import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Single source of truth for the main bottom-nav tab selection.
///
/// Both [MainShellScreen] (the IndexedStack host) and any standalone screen
/// reached via a deep link drive the selected tab through this controller, so
/// tab navigation behaves consistently no matter how a screen was opened.
class MainNavController extends GetxController {
  static const tabCount = 5;

  final RxInt selectedTab = 0.obs;
  final RxList<int> tabRevisions = List<int>.filled(tabCount, 0).obs;
  int _tabBeforeAi = 0;

  void goToTab(int index) {
    if (index < 0 || index >= tabCount) return;
    tabRevisions[index]++;
    if (selectedTab.value == index) {
      HapticFeedback.selectionClick();
      return;
    }
    if (index == 4 && selectedTab.value != 4) {
      _tabBeforeAi = selectedTab.value;
    }
    HapticFeedback.selectionClick();
    selectedTab.value = index;
  }

  void leaveAi() => goToTab(_tabBeforeAi == 4 ? 0 : _tabBeforeAi);
}
