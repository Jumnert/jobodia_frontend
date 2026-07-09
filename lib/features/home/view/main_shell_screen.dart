import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/ai_chat/view/ai_chat_screen.dart';
import 'package:jobodia_frontend/features/cv_builder/view/cv_builder_screen.dart';
import 'package:jobodia_frontend/features/home/controller/main_nav_controller.dart';
import 'package:jobodia_frontend/features/home/view/home_screen.dart';
import 'package:jobodia_frontend/features/search/view/search_screen.dart';

/// The main tabbed shell of the app.
///
/// Renders a single [AdaptiveBottomNavigationBar] (Liquid Glass on iOS 26+,
/// Cupertino on iOS <26, Material on Android) over an [IndexedStack] body.
/// Tab selection is owned by [MainNavController] — the single source of truth
/// that other screens drive through `navigateMainDestination` — so navigation
/// stays consistent and there is exactly one navigation bar in the tree.
class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final nav = Get.find<MainNavController>();

    // Built once and kept alive inside the IndexedStack so each tab preserves
    // its scroll position and state when switching. Each page is wrapped in a
    // RepaintBoundary so painting in one tab never repaints the others.
    final pages = <Widget>[
      const RepaintBoundary(child: HomeScreen()),
      const RepaintBoundary(child: CvBuilderScreen()),
      RepaintBoundary(child: AiChatScreen()),
      const RepaintBoundary(child: SearchScreen()),
    ];

    return Obx(() {
      final index = nav.selectedTab.value;

      return AdaptiveScaffold(
        body: Container(
          color: palette.scaffold,
          child: IndexedStack(index: index, children: pages),
        ),
        bottomNavigationBar: AdaptiveBottomNavigationBar(
          useNativeBottomBar: true,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: palette.iconMuted,
          selectedIndex: index,
          onTap: nav.goToTab,
          items: const [
            AdaptiveNavigationDestination(
              icon: 'house',
              selectedIcon: 'house.fill',
              label: 'Home',
            ),
            AdaptiveNavigationDestination(
              icon: 'doc.on.doc',
              selectedIcon: 'doc.on.doc.fill',
              label: 'CV',
            ),
            AdaptiveNavigationDestination(
              icon: 'message',
              selectedIcon: 'message.fill',
              label: 'Chat',
            ),
            AdaptiveNavigationDestination(
              icon: 'magnifyingglass',
              label: 'Search',
            ),
          ],
        ),
      );
    });
  }
}
