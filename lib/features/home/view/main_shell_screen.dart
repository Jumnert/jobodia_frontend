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
/// Adaptive UI provides the app's platform-aware navigation surface. Tab
/// selection remains in [MainNavController], so screens have one source of
/// truth and switching tabs preserves each page's state.
class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final nav = Get.find<MainNavController>();
    final pages = <Widget>[
      const RepaintBoundary(child: HomeScreen()),
      const RepaintBoundary(child: CvBuilderScreen(embedded: true)),
      RepaintBoundary(child: AiChatScreen()),
      const RepaintBoundary(child: SearchScreen()),
    ];

    return Obx(() {
      final index = nav.selectedTab.value;
      return PopScope(
        canPop: index == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && index != 0) nav.goToTab(0);
        },
        child: AdaptiveScaffold(
          // Keep the native bar stable: the package only supports a centered
          // shrink, not the left-docked behavior Jobodia needs.
          minimizeBehavior: TabBarMinimizeBehavior.never,
          body: Container(
            color: palette.scaffold,
            child: Stack(
              children: List.generate(
                pages.length,
                (pageIndex) => Positioned.fill(
                  child: IgnorePointer(
                    ignoring: pageIndex != index,
                    child: TickerMode(
                      enabled: pageIndex == index,
                      child: AnimatedOpacity(
                        opacity: pageIndex == index ? 1 : 0,
                        duration: const Duration(milliseconds: 420),
                        curve: Curves.easeInOutCubic,
                        child: ExcludeSemantics(
                          excluding: pageIndex != index,
                          child: pages[pageIndex],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: AdaptiveBottomNavigationBar(
            useNativeBottomBar: true,
            selectedItemColor: AppColors.brandTeal,
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
        ),
      );
    });
  }
}
