import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/ai_chat/view/ai_chat_screen.dart';
import 'package:jobodia_frontend/features/ai_chat/controller/ai_chat_controller.dart';
import 'package:jobodia_frontend/features/home/controller/home_controller.dart';
import 'package:jobodia_frontend/features/cv_builder/view/cv_builder_screen.dart';
import 'package:jobodia_frontend/features/home/controller/main_nav_controller.dart';
import 'package:jobodia_frontend/features/home/view/home_screen.dart';
import 'package:jobodia_frontend/features/job_post/view/job_post_screen.dart';
import 'package:jobodia_frontend/features/notifications/controller/notifications_controller.dart';
import 'package:jobodia_frontend/features/notifications/view/notifications_screen.dart';
import 'package:jobodia_frontend/features/settings/view/settings_screen.dart';
import 'package:jobodia_frontend/features/role/controller/role_controller.dart';

/// The main tabbed shell of the app.
class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key});

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
        const RepaintBoundary(child: SettingsScreen(showBottomNav: false)),
        const RepaintBoundary(child: NotificationsScreen(embedded: true)),
        const RepaintBoundary(child: AiChatScreen(embedded: true)),
      ];
      return PopScope(
        canPop: index == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && index != 0) nav.goToTab(0);
        },
        child: FScaffold(
          childPad: false,
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  color: palette.scaffold,
                  child: IndexedStack(
                    index: index,
                    children: [
                      for (var tab = 0; tab < pages.length; tab++)
                        KeyedSubtree(
                          key: ValueKey(
                            'main-tab-$tab-${nav.tabRevisions[tab]}',
                          ),
                          child: pages[tab],
                        ),
                    ],
                  ),
                ),
              ),
              if (index != 4)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _BottomNavBar(
                    selectedIndex: index,
                    isEmployer: isEmployer,
                    animateAiBorder: index == 0,
                    onTap: (tapped) async {
                      nav.goToTab(tapped);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (tapped == 0 && Get.isRegistered<HomeController>()) {
                          final scroll =
                              Get.find<HomeController>().scrollController;
                          if (scroll.hasClients) scroll.jumpTo(0);
                        }
                        if (tapped == 4 &&
                            Get.isRegistered<AiChatController>()) {
                          Get.find<AiChatController>()
                              .resetConversationViewport();
                        }
                      });
                    },
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Floating bottom navigation bar
// ─────────────────────────────────────────────────────────────────────────────

class _BottomNavBar extends StatefulWidget {
  const _BottomNavBar({
    required this.selectedIndex,
    required this.isEmployer,
    required this.animateAiBorder,
    required this.onTap,
  });

  final int selectedIndex;
  final bool isEmployer;
  final bool animateAiBorder;
  final Future<void> Function(int) onTap;

  List<({String? asset, IconData? icon, String label})> get items => [
    const (
      asset: 'assets/animations/nav_icons/home.json',
      icon: null,
      label: 'nav_home',
    ),
    isEmployer
        ? const (asset: null, icon: FLucideIcons.squarePlus, label: 'post_job')
        : const (
            asset: 'assets/animations/nav_icons/cv.json',
            icon: null,
            label: 'nav_cv',
          ),
    const (asset: null, icon: FLucideIcons.settings, label: 'settings'),
    const (asset: null, icon: FLucideIcons.bell, label: 'nav_notifications'),
    const (
      asset: 'assets/animations/nav_icons/E V E.json',
      icon: null,
      label: 'AI',
    ),
  ];

  @override
  State<_BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<_BottomNavBar>
    with TickerProviderStateMixin {
  static const _count = 5;

  late final AnimationController _ctrl = AnimationController(vsync: this);
  // Drives the jelly wobble while the capsule is being held/dragged.
  late final AnimationController _wobble = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
  );
  late final AnimationController _aiBorder = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();
  double _fromIndex = 0;
  double _toIndex = 0;
  bool _dragging = false;
  double _dragIndex = 0;
  int? _dragTarget;

  @override
  void initState() {
    super.initState();
    _fromIndex = widget.selectedIndex.toDouble();
    _toIndex = _fromIndex;
    _ctrl.value = 1;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _wobble.dispose();
    _aiBorder.dispose();
    super.dispose();
  }

  Duration _durationFor(double distance) => Duration(
    milliseconds: (200 + distance.clamp(0, _count - 1) * 55).round(),
  );

  /// Current linear position — lets us interrupt an in-flight animation
  /// smoothly from wherever the capsule currently is.
  double get _display => _dragging
      ? _dragIndex
      : _fromIndex + (_toIndex - _fromIndex) * _ctrl.value;

  void _animateTo(double from, double to) {
    _fromIndex = from;
    _toIndex = to;
    _ctrl
      ..duration = _durationFor((to - from).abs())
      ..forward(from: 0);
  }

  @override
  void didUpdateWidget(_BottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = widget.selectedIndex.toDouble();
    if (!_dragging &&
        oldWidget.selectedIndex != widget.selectedIndex &&
        target != _toIndex) {
      _animateTo(_display, target);
    }
  }

  int _indexAt(double dx, double width) {
    const aiExtent = 64.0;
    const gap = 10.0;
    final aiStart = width - aiExtent;
    if (dx >= aiStart - gap / 2) return _count - 1;

    final mainBarWidth = width - aiExtent - gap;
    return (dx / (mainBarWidth / (_count - 1))).floor().clamp(0, _count - 2);
  }

  double _pillAt(double dx, double width) => _indexAt(dx, width).toDouble();

  void _updateDrag(double dx, double width) {
    final target = _indexAt(dx, width);
    if (target != _dragTarget) {
      _dragTarget = target;
      HapticFeedback.lightImpact();
    }
    setState(() => _dragIndex = _pillAt(dx, width));
  }

  Future<void> _select(int index) async {
    final start = _display;
    _wobble.stop();
    setState(() {
      _dragging = false;
      _dragTarget = null;
    });
    _animateTo(start, index.toDouble());
    await widget.onTap(index);

    // Notifications is a pushed route, not a persisted tab. Once it closes, glide
    // the capsule back to the currently selected persisted tab.
    if (mounted && widget.selectedIndex != index) {
      _animateTo(_display, widget.selectedIndex.toDouble());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final border = theme.colors.border;
    final primary = theme.colors.primary;
    final barColor = theme.colors.background.withValues(alpha: 0.52);

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(14, 0, 14, 0),
      child: SizedBox(
        height: 64,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) =>
                  _select(_indexAt(details.localPosition.dx, width)),
              onHorizontalDragStart: (details) {
                _ctrl.stop();
                _dragging = true;
                _wobble.repeat();
                _updateDrag(details.localPosition.dx, width);
              },
              onHorizontalDragUpdate: (details) =>
                  _updateDrag(details.localPosition.dx, width),
              onHorizontalDragEnd: (_) =>
                  _select(_dragTarget ?? _display.round()),
              onHorizontalDragCancel: () {
                final start = _display;
                _wobble.stop();
                setState(() {
                  _dragging = false;
                  _dragTarget = null;
                });
                _animateTo(start, widget.selectedIndex.toDouble());
              },
              onLongPressStart: (details) {
                _ctrl.stop();
                HapticFeedback.mediumImpact();
                _dragging = true;
                _wobble.repeat();
                _updateDrag(details.localPosition.dx, width);
              },
              onLongPressMoveUpdate: (details) =>
                  _updateDrag(details.localPosition.dx, width),
              onLongPressEnd: (_) => _select(_dragTarget ?? _display.round()),
              child: AnimatedBuilder(
                animation: Listenable.merge([_ctrl, _wobble, _aiBorder]),
                builder: (context, _) {
                  final visualIndex = (_dragging ? _dragIndex : _toIndex)
                      .round()
                      .clamp(0, _count - 1);
                  final items = widget.items;
                  final aiItem = items.last;
                  final aiSelected = visualIndex == _count - 1;
                  final animateAiBorder = widget.animateAiBorder;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Container(
                          height: 62,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 18,
                                offset: const Offset(0, 7),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: barColor,
                                  borderRadius: BorderRadius.circular(32),
                                  border: Border.all(color: border),
                                ),
                                child: Row(
                                  children: List.generate(_count - 1, (i) {
                                    final item = items[i];
                                    final selected = visualIndex == i;
                                    return Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (i == 3)
                                            _NotificationNavIcon(
                                              selected: selected,
                                            )
                                          else
                                            _AnimatedNavIcon(
                                              asset: item.asset,
                                              icon: item.icon,
                                              selected: selected,
                                            ),
                                          const SizedBox(height: 3),
                                          AnimatedDefaultTextStyle(
                                            duration: const Duration(
                                              milliseconds: 180,
                                            ),
                                            style: theme.typography.body.xs
                                                .copyWith(
                                                  fontSize: 10,
                                                  height: 1,
                                                  color: selected
                                                      ? primary
                                                      : theme
                                                            .colors
                                                            .mutedForeground,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                item.label.tr,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Semantics(
                        label: 'ai_assistant'.tr,
                        button: true,
                        selected: aiSelected,
                        child: Container(
                          width: 64,
                          height: 64,
                          padding: EdgeInsets.all(animateAiBorder ? 2.5 : 0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: animateAiBorder
                                ? SweepGradient(
                                    transform: GradientRotation(
                                      _aiBorder.value * 6.28318530718,
                                    ),
                                    colors: [
                                      primary.withValues(alpha: 0),
                                      primary.withValues(alpha: 0.75),
                                      Colors.white.withValues(
                                        alpha: context.isDark ? 0.42 : 0.9,
                                      ),
                                      primary,
                                      primary.withValues(alpha: 0),
                                    ],
                                  )
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color:
                                      (context.isDark
                                              ? Colors.black
                                              : Colors.white)
                                          .withValues(alpha: 0.68),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: aiSelected ? primary : border,
                                    width: aiSelected ? 2.5 : 1,
                                  ),
                                ),
                                child: Transform.scale(
                                  scale: 1.18,
                                  child: _AnimatedNavIcon(
                                    asset: aiItem.asset,
                                    icon: aiItem.icon,
                                    selected: aiSelected,
                                    size: 58,
                                    alwaysAnimate: true,
                                    useOriginalColors: true,
                                    playbackSpeed: 1.65,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lottie animated icon (unchanged)
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedNavIcon extends StatefulWidget {
  const _AnimatedNavIcon({
    this.asset,
    this.icon,
    required this.selected,
    this.size = 28,
    this.alwaysAnimate = false,
    this.useOriginalColors = false,
    this.playbackSpeed = 1,
  });

  final String? asset;
  final IconData? icon;
  final bool selected;
  final double size;
  final bool alwaysAnimate;
  final bool useOriginalColors;
  final double playbackSpeed;

  @override
  State<_AnimatedNavIcon> createState() => _AnimatedNavIconState();
}

class _AnimatedNavIconState extends State<_AnimatedNavIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _initialised = false;

  @override
  void initState() {
    super.initState();
    // Lottie replaces this with the composition's duration when loaded. The
    // fallback keeps selection changes safe before that callback runs and
    // powers the static settings icon's rotation.
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onLoaded(LottieComposition composition) {
    _ctrl.duration = Duration(
      microseconds: (composition.duration.inMicroseconds / widget.playbackSpeed)
          .round(),
    );
    if (widget.alwaysAnimate) {
      _initialised = true;
      if (!_ctrl.isAnimating) _ctrl.repeat();
      return;
    }
    if (!_initialised) {
      _initialised = true;
      _ctrl.value = widget.selected ? 1.0 : 0.0;
    }
  }

  @override
  void didUpdateWidget(_AnimatedNavIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.alwaysAnimate) {
      if (!_ctrl.isAnimating) _ctrl.repeat();
      return;
    }
    if (oldWidget.selected != widget.selected) {
      if (widget.selected) {
        _ctrl.forward();
      } else {
        _ctrl.value = 0.0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final tint = widget.selected
        ? theme.colors.primary
        : theme.colors.mutedForeground;

    if (widget.asset == null) {
      if (widget.icon != FLucideIcons.settings) {
        return Icon(widget.icon, color: tint, size: widget.size);
      }
      return RotationTransition(
        turns: _ctrl,
        child: Icon(widget.icon, color: tint, size: widget.size),
      );
    }

    final lottie = Lottie.asset(
      widget.asset!,
      controller: _ctrl,
      width: widget.size,
      height: widget.size,
      renderCache: RenderCache.raster,
      onLoaded: _onLoaded,
    );

    if (widget.useOriginalColors) return lottie;
    return ColorFiltered(
      colorFilter: ColorFilter.mode(tint, BlendMode.srcATop),
      child: lottie,
    );
  }
}

class _NotificationNavIcon extends StatelessWidget {
  const _NotificationNavIcon({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _AnimatedNavIcon(icon: FLucideIcons.bell, selected: selected),
        Obx(() {
          final count = Get.find<NotificationsController>().unreadCount;
          if (count == 0) return const SizedBox.shrink();
          return Positioned(
            right: -7,
            top: -5,
            child: Container(
              constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
              padding: const EdgeInsets.symmetric(horizontal: 3),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: Text(
                count > 9 ? '9+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
