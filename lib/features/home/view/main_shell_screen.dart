import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/ai_chat/controller/ai_chat_controller.dart';
import 'package:jobodia_frontend/features/ai_chat/view/ai_chat_screen.dart';
import 'package:jobodia_frontend/features/cv_builder/view/cv_builder_screen.dart';
import 'package:jobodia_frontend/features/feature_discovery/view/walkthrough_screen.dart';
import 'package:jobodia_frontend/features/home/controller/home_controller.dart';
import 'package:jobodia_frontend/features/home/controller/main_nav_controller.dart';
import 'package:jobodia_frontend/features/home/view/home_screen.dart';
import 'package:jobodia_frontend/features/job_post/view/job_post_screen.dart';
import 'package:jobodia_frontend/features/notifications/controller/notifications_controller.dart';
import 'package:jobodia_frontend/features/notifications/view/notifications_screen.dart';
import 'package:jobodia_frontend/features/role/controller/role_controller.dart';
import 'package:jobodia_frontend/features/settings/view/settings_screen.dart';

/// The main tabbed shell of the app.
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  final ScrollController _settingsScrollController = ScrollController(
    keepScrollOffset: false,
  );

  @override
  void dispose() {
    _settingsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final nav = Get.find<MainNavController>();
    final roleController = Get.find<RoleController>();
    return Obx(() {
      final index = nav.selectedTab.value;
      final isEmployer = roleController.role.value == UserRole.employer;
      final pages = <Widget>[
        const RepaintBoundary(child: HomeScreen()),
        RepaintBoundary(
          child: isEmployer
              ? const JobPostScreen()
              : const CvBuilderScreen(embedded: true),
        ),
        const RepaintBoundary(child: NotificationsScreen(embedded: true)),
        RepaintBoundary(
          child: SettingsScreen(
            showBottomNav: false,
            scrollController: _settingsScrollController,
          ),
        ),
        const RepaintBoundary(child: AiChatScreen(embedded: true)),
      ];
      return PopScope(
        canPop: index == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && index != 0) nav.goToTab(0);
        },
        child: GlassScaffold(
          backgroundColor: palette.scaffold,
          extendBody: true,
          edgeFade: false,
          bottomBar: index == 4
              ? null
              : _BottomNavBar(
                  selectedIndex: index,
                  isEmployer: isEmployer,
                  settingsScrollController: _settingsScrollController,
                  onTap: (tapped) {
                    nav.goToTab(tapped);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (tapped == 0 && Get.isRegistered<HomeController>()) {
                        final scroll =
                            Get.find<HomeController>().scrollController;
                        if (scroll.hasClients) scroll.jumpTo(0);
                      }
                      if (tapped == 4 && Get.isRegistered<AiChatController>()) {
                        Get.find<AiChatController>()
                            .resetConversationViewport();
                      }
                    });
                  },
                ),
          body: IndexedStack(
            index: index,
            children: [
              for (var tab = 0; tab < pages.length; tab++)
                KeyedSubtree(
                  key: ValueKey('main-tab-$tab-${nav.tabRevisions[tab]}'),
                  child: pages[tab],
                ),
            ],
          ),
        ),
      );
    });
  }
}

/// iOS-style liquid-glass navigation. The package owns the moving, deforming
/// selection pill and its scroll minimization, while Jobodia owns tab routing.
class _BottomNavBar extends StatefulWidget {
  const _BottomNavBar({
    required this.selectedIndex,
    required this.isEmployer,
    required this.settingsScrollController,
    required this.onTap,
  });

  final int selectedIndex;
  final bool isEmployer;
  final ScrollController settingsScrollController;
  final void Function(int) onTap;

  @override
  State<_BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<_BottomNavBar> {
  late final GlassTabBarMinimizeController _minimizeController =
      GlassTabBarMinimizeController(
        behavior: GlassBarMinimizeBehavior.onScrollDown,
      );

  @override
  void didUpdateWidget(covariant _BottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex &&
        widget.selectedIndex != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _minimizeController.expand();
      });
    }
  }

  @override
  void dispose() {
    _minimizeController.dispose();
    super.dispose();
  }

  void _selectTab(int index) {
    _minimizeController.expand();
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final muted = theme.colors.mutedForeground;
    final selectedNavColor = context.isDark
        ? AppColors.brandLight
        : AppColors.brandPrimary;
    final unselectedNavColor = context.isDark
        ? Colors.white.withValues(alpha: 0.92)
        : muted;
    final tabIndex = widget.selectedIndex.clamp(0, 3);
    final activeScrollController = switch (widget.selectedIndex) {
      0 when Get.isRegistered<HomeController>() =>
        Get.find<HomeController>().scrollController,
      3 => widget.settingsScrollController,
      _ => null,
    };

    final tabs = <GlassTab>[
      GlassTab(
        icon: const Icon(FLucideIcons.house),
        activeIcon: const Icon(FLucideIcons.house),
        label: 'nav_home'.tr,
        glowColor: AppColors.brandPrimary,
      ),
      GlassTab(
        icon: KeyedSubtree(
          key: widget.isEmployer ? FeatureTourTargets.postJob : null,
          child: widget.isEmployer
              ? const Icon(FLucideIcons.squarePlus)
              : const Icon(FLucideIcons.fileText),
        ),
        activeIcon: widget.isEmployer
            ? const Icon(FLucideIcons.squarePlus)
            : const Icon(FLucideIcons.fileText),
        label: widget.isEmployer ? 'post_job'.tr : 'nav_cv'.tr,
        glowColor: AppColors.brandPrimary,
      ),
      GlassTab(
        icon: const _NotificationTabIcon(),
        activeIcon: const _NotificationTabIcon(),
        label: 'nav_notifications'.tr,
        glowColor: AppColors.brandPrimary,
      ),
      GlassTab(
        icon: const Icon(FLucideIcons.menu),
        activeIcon: const Icon(FLucideIcons.menu),
        label: 'nav_menu'.tr,
        glowColor: AppColors.brandPrimary,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: GlassTabBar.minimizable(
        tabs: tabs,
        selectedIndex: tabIndex,
        onTabSelected: _selectTab,
        minimizeController: _minimizeController,
        scrollController: activeScrollController,
        onMinimizedTabTap: _minimizeController.expand,
        trailingButton: GlassTabBarTrailingButton(
          icon: Semantics(
            key: FeatureTourTargets.aiAssistant,
            label: 'ai_assistant'.tr,
            button: true,
            child: SizedBox.square(
              dimension: 38,
              child: Lottie.asset(
                'assets/animations/nav_icons/robo.lottie',
                repeat: true,
                animate: true,
                fit: BoxFit.contain,
                frameRate: const FrameRate(60),
                renderCache: RenderCache.raster,
              ),
            ),
          ),
          onTap: () => _selectTab(4),
        ),
        horizontalPadding: 0,
        verticalPadding: 12,
        spacing: 10,
        barHeight: 64,
        barBorderRadius: 32,
        tabPadding: const EdgeInsets.symmetric(horizontal: 4),
        iconLabelSpacing: 3,
        iconSize: 24,
        labelFontSize: 10,
        minimizedBarHeight: 50,
        selectedIconColor: selectedNavColor,
        unselectedIconColor: unselectedNavColor,
        selectedLabelColor: selectedNavColor,
        unselectedLabelColor: unselectedNavColor,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        // A clear selection lens: retain the moving liquid-glass refraction,
        // but remove the cloudy tint and blue bloom over the outer glass bar.
        showIndicator: true,
        indicatorColor: Colors.transparent,
        indicatorSettings: const LiquidGlassSettings(
          thickness: 8,
          blur: 0,
          refractiveIndex: 1.03,
          lightIntensity: 0.25,
          saturation: 1,
          glowIntensity: 0,
          shadowElevation: 0,
        ),
        magnification: 1.04,
        innerBlur: 0,
        glowOpacity: 0,
        interactionGlowColor: Colors.transparent,
        indicatorExpansion: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 4,
        ),
        indicatorPinchStrength: 0.25,
        pressScale: 1.025,
      ),
    );
  }
}

class _NotificationTabIcon extends StatelessWidget {
  const _NotificationTabIcon();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(FLucideIcons.bell),
        if (Get.isRegistered<NotificationsController>())
          Obx(() {
            final count = Get.find<NotificationsController>().unreadCount;
            if (count <= 0) return const SizedBox.shrink();

            return Positioned(
              top: -5,
              right: -7,
              child: Container(
                constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                padding: const EdgeInsets.symmetric(horizontal: 3),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  count > 9 ? '9+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    height: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
