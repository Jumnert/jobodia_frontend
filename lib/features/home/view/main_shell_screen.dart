import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/ai_chat/view/ai_chat_screen.dart';
import 'package:jobodia_frontend/features/cv_builder/view/cv_builder_screen.dart';
import 'package:jobodia_frontend/features/home/controller/main_nav_controller.dart';
import 'package:jobodia_frontend/features/home/view/home_screen.dart';
import 'package:jobodia_frontend/features/profile/controller/profile_controller.dart';
import 'package:jobodia_frontend/features/profile/view/profile_screen.dart';

/// The main tabbed shell of the app.
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
      final barIndex = index >= _searchTabIndex ? index + 1 : index;
      return PopScope(
        canPop: index == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && index != 0) nav.goToTab(0);
        },
        child: FScaffold(
          childPad: false,
          child: Stack(
            children: [
              // Content fills full height. Scrolling down collapses the nav,
              // scrolling up expands it again.
              Positioned.fill(
                child: NotificationListener<UserScrollNotification>(
                  onNotification: (n) {
                    if (n.metrics.axis != Axis.vertical) return false;
                    if (n.direction == ScrollDirection.reverse) {
                      nav.setCollapsed(true);
                    } else if (n.direction == ScrollDirection.forward) {
                      nav.setCollapsed(false);
                    }
                    return false;
                  },
                  child: Container(
                    color: palette.scaffold,
                    child: IndexedStack(index: index, children: pages),
                  ),
                ),
              ),
              // Floating pill nav bar — sits just above the device safe zone.
              Positioned(
                left: 0,
                right: 0,
                bottom: math.max(
                  MediaQuery.viewPaddingOf(context).bottom * 0.5,
                  10,
                ),
                child: Center(
                  child: Obx(
                    () => _FloatingNavBar(
                      selectedIndex: barIndex,
                      collapsed: nav.collapsed.value,
                      fullWidth: MediaQuery.sizeOf(context).width - 32,
                      onTap: (tapped) async {
                        if (tapped == _searchTabIndex) {
                          await Get.toNamed<void>(AppRoutes.search);
                          return;
                        }
                        nav.goToTab(
                          tapped > _searchTabIndex ? tapped - 1 : tapped,
                        );
                      },
                    ),
                  ),
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
// Floating nav bar with a single sliding pill indicator
// ─────────────────────────────────────────────────────────────────────────────

class _FloatingNavBar extends StatefulWidget {
  const _FloatingNavBar({
    required this.selectedIndex,
    required this.onTap,
    required this.collapsed,
    required this.fullWidth,
  });

  final int selectedIndex;
  final Future<void> Function(int) onTap;

  /// When true the bar shrinks toward the centre and hides labels (icons only).
  final bool collapsed;

  /// The bar's expanded width (screen width minus horizontal insets).
  final double fullWidth;

  static const _items = [
    (asset: 'assets/animations/nav_icons/home.json', label: 'Home'),
    (asset: 'assets/animations/nav_icons/cv.json', label: 'CV'),
    (asset: 'assets/animations/nav_icons/chat.json', label: 'Chat'),
    (asset: 'assets/animations/nav_icons/search.json', label: 'Search'),
    (asset: 'assets/animations/nav_icons/profile.json', label: 'Profile'),
  ];

  @override
  State<_FloatingNavBar> createState() => _FloatingNavBarState();
}

class _FloatingNavBarState extends State<_FloatingNavBar>
    with TickerProviderStateMixin {
  static const _count = 5;

  late final AnimationController _ctrl = AnimationController(vsync: this);
  // Drives the jelly wobble while the capsule is being held/dragged.
  late final AnimationController _wobble = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
  );
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
  void didUpdateWidget(_FloatingNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = widget.selectedIndex.toDouble();
    if (!_dragging &&
        oldWidget.selectedIndex != widget.selectedIndex &&
        target != _toIndex) {
      _animateTo(_display, target);
    }
  }

  int _indexAt(double dx, double width) =>
      (dx / (width / _count)).floor().clamp(0, _count - 1);

  double _pillAt(double dx, double width) =>
      (dx / (width / _count) - 0.5).clamp(0.0, _count - 1.0);

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

    // Search is a pushed route, not a persisted tab. Once it closes, glide
    // the capsule back to the currently selected persisted tab.
    if (mounted && widget.selectedIndex != index) {
      _animateTo(_display, widget.selectedIndex.toDouble());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final bg = theme.colors.background;
    final border = theme.colors.border;
    final primary = theme.colors.primary;
    final dark = theme.colors.brightness == Brightness.dark;
    // Keep the original bar surface; only the shadow adapts per theme.
    final barColor = bg;
    // Theme-aware drop shadow: soft in light, deeper in dark for depth.
    final shadows = dark
        ? const [
            BoxShadow(
              color: Color(0x73000000),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ]
        : const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 26,
              offset: Offset(0, 14),
              spreadRadius: -6,
            ),
          ];

    final collapsed = widget.collapsed;

    return AnimatedScale(
      // The bar pops slightly bigger while being manipulated (liquid grab).
      scale: _dragging ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      child: AnimatedSize(
        // Smoothly shrink toward the centre on scroll (labels drop out).
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
        alignment: Alignment.center,
        child: SizedBox(
          width: collapsed ? 232 : widget.fullWidth,
          child: Container(
            clipBehavior: Clip.none,
            decoration: BoxDecoration(
              color: barColor,
              border: Border.all(color: border),
              borderRadius: BorderRadius.circular(30),
              boxShadow: shadows,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 6,
                vertical: collapsed ? 9 : 4,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final itemWidth = width / _count;
                  final pillWidth = itemWidth * 0.98;

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
                    onLongPressEnd: (_) =>
                        _select(_dragTarget ?? _display.round()),
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_ctrl, _wobble]),
                      builder: (context, _) {
                        final double centerAt;
                        if (_dragging) {
                          centerAt = _dragIndex;
                        } else {
                          final t = Curves.easeInOutCubic.transform(
                            _ctrl.value,
                          );
                          centerAt = _fromIndex + (_toIndex - _fromIndex) * t;
                        }
                        final left =
                            (centerAt + 0.5) * itemWidth - pillWidth / 2;
                        final right =
                            (centerAt + 0.5) * itemWidth + pillWidth / 2;
                        final visualIndex = (_dragging ? _dragIndex : _toIndex)
                            .round()
                            .clamp(0, _count - 1);

                        final double grow;
                        if (_dragging) {
                          grow = 1.22;
                        } else if (_ctrl.isAnimating) {
                          grow = 1 + 0.2 * math.sin(_ctrl.value * math.pi);
                        } else {
                          grow = 1.0;
                        }
                        final wob = _dragging
                            ? 0.05 * math.sin(_wobble.value * 2 * math.pi)
                            : 0.0;

                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: left,
                              width: right - left,
                              top: 3,
                              bottom: 3,
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.diagonal3Values(
                                  grow * (1 + wob),
                                  grow * (1 - wob),
                                  1,
                                ),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        primary.withValues(alpha: 0.30),
                                        primary.withValues(alpha: 0.12),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: primary.withValues(alpha: 0.40),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: primary.withValues(alpha: 0.22),
                                        blurRadius: 12,
                                        spreadRadius: -2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              children: List.generate(_count, (i) {
                                final item = _FloatingNavBar._items[i];
                                final selected = visualIndex == i;
                                return Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _AnimatedNavIcon(
                                        asset: item.asset,
                                        selected: selected,
                                      ),
                                      if (!collapsed) ...[
                                        const SizedBox(height: 1),
                                        AnimatedDefaultTextStyle(
                                          duration: const Duration(
                                            milliseconds: 180,
                                          ),
                                          style: theme.typography.body.xs
                                              .copyWith(
                                                fontSize: 9,
                                                height: 1,
                                                color: selected
                                                    ? primary
                                                    : theme
                                                          .colors
                                                          .mutedForeground,
                                                fontWeight: FontWeight.w500,
                                              ),
                                          child: Text(item.label),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lottie animated icon (unchanged)
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedNavIcon extends StatefulWidget {
  const _AnimatedNavIcon({required this.asset, required this.selected});

  final String asset;
  final bool selected;

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
    _ctrl = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onLoaded(LottieComposition composition) {
    _ctrl.duration = composition.duration;
    if (!_initialised) {
      _initialised = true;
      _ctrl.value = widget.selected ? 1.0 : 0.0;
    }
  }

  @override
  void didUpdateWidget(_AnimatedNavIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
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

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => ColorFiltered(
        colorFilter: ColorFilter.mode(tint, BlendMode.srcATop),
        child: Lottie.asset(
          widget.asset,
          controller: _ctrl,
          width: widget.selected ? 30 : 25,
          height: widget.selected ? 30 : 25,
          onLoaded: _onLoaded,
        ),
      ),
    );
  }
}
