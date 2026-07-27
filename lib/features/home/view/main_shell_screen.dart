import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/ai_chat/view/ai_chat_screen.dart';
import 'package:jobodia_frontend/features/cv_builder/view/cv_builder_screen.dart';
import 'package:jobodia_frontend/features/home/controller/main_nav_controller.dart';
import 'package:jobodia_frontend/features/home/view/home_screen.dart';
import 'package:jobodia_frontend/features/profile/controller/profile_controller.dart';
import 'package:jobodia_frontend/features/profile/view/profile_screen.dart';

/// The main tabbed shell of the app.
///
/// Uses forui's [FBottomNavigationBar] for navigation. Tab selection remains
/// in [MainNavController], so screens have one source of truth and switching
/// tabs preserves each page's state. Search is a dedicated pushed screen
/// (not a persisted tab), so tapping it opens [AppRoutes.search] instead of
/// switching the [IndexedStack].
class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key});

  static const _searchTabIndex = 3;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final nav = Get.find<MainNavController>();
    Get.lazyPut<ProfileController>(ProfileController.new, fenix: true);
    final pages = <Widget>[
      const RepaintBoundary(child: HomeScreen()),
      const RepaintBoundary(child: CvBuilderScreen(embedded: true)),
      RepaintBoundary(child: AiChatScreen()),
      const RepaintBoundary(child: ProfileScreen(embedded: true)),
    ];

    return Obx(() {
      final index = nav.selectedTab.value;
      // Bar position 3 is Search (pushed, not an IndexedStack tab), so
      // positions after it are shifted right by one relative to `index`.
      final barIndex = index >= _searchTabIndex ? index + 1 : index;
      return PopScope(
        canPop: index == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && index != 0) nav.goToTab(0);
        },
        child: FScaffold(
          childPad: false,
          footer: FBottomNavigationBar(
            index: barIndex,
            onChange: (tapped) {
              if (tapped == _searchTabIndex) {
                Get.toNamed<void>(AppRoutes.search);
                return;
              }
              // Pages after Search are shifted left by one in the IndexedStack
              // since Search itself has no IndexedStack entry.
              nav.goToTab(tapped > _searchTabIndex ? tapped - 1 : tapped);
            },
            children: const [
              FBottomNavigationBarItem(
                icon: Icon(FLucideIcons.house),
                label: Text('Home'),
              ),
              FBottomNavigationBarItem(
                icon: Icon(FLucideIcons.fileText),
                label: Text('CV'),
              ),
              FBottomNavigationBarItem(
                icon: Icon(FLucideIcons.messageCircle),
                label: Text('Chat'),
              ),
              FBottomNavigationBarItem(
                icon: Icon(FLucideIcons.search),
                label: Text('Search'),
              ),
              FBottomNavigationBarItem(
                icon: Icon(FLucideIcons.user),
                label: Text('Profile'),
              ),
            ],
          ),
          child: Container(
            color: palette.scaffold,
            child: IndexedStack(
              index: index,
              children: pages,
            ),
          ),
        ),
      );
    });
  }
}
