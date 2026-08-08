import 'package:flutter/material.dart';
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
      const RepaintBoundary(child: AiChatScreen()),
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
          child: Column(
            children: [
              Expanded(
                child: Container(
                  color: palette.scaffold,
                  child: IndexedStack(index: index, children: pages),
                ),
              ),
              _BottomNavBar(
                selectedIndex: barIndex,
                onTap: (tapped) async {
                  if (tapped == _searchTabIndex) {
                    await Get.toNamed<void>(AppRoutes.search);
                    return;
                  }
                  nav.goToTab(tapped > _searchTabIndex ? tapped - 1 : tapped);
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fixed bottom navigation bar
// ─────────────────────────────────────────────────────────────────────────────

class _BottomNavBar extends StatefulWidget {
  const _BottomNavBar({required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final Future<void> Function(int) onTap;

  static const _items = [
    (asset: 'assets/animations/nav_icons/home.json', label: 'Home'),
    (asset: 'assets/animations/nav_icons/cv.json', label: 'CV'),
    (asset: 'assets/animations/nav_icons/chat.json', label: 'Chat'),
    (asset: 'assets/animations/nav_icons/search.json', label: 'Search'),
    (asset: 'assets/animations/nav_icons/profile.json', label: 'Profile'),
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
  void didUpdateWidget(_BottomNavBar oldWidget) {
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
    final barColor = bg;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.none,
      decoration: BoxDecoration(
        color: barColor,
        border: Border(top: BorderSide(color: border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
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
                  animation: Listenable.merge([_ctrl, _wobble]),
                  builder: (context, _) {
                    final visualIndex = (_dragging ? _dragIndex : _toIndex)
                        .round()
                        .clamp(0, _count - 1);

                    return Row(
                      children: List.generate(_count, (i) {
                        final item = _BottomNavBar._items[i];
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
                              const SizedBox(height: 3),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 180),
                                style: theme.typography.body.xs.copyWith(
                                  fontSize: 10,
                                  height: 1,
                                  color: selected
                                      ? primary
                                      : theme.colors.mutedForeground,
                                  fontWeight: FontWeight.w500,
                                ),
                                child: Text(item.label),
                              ),
                            ],
                          ),
                        );
                      }),
                    );
                  },
                ),
              );
            },
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
          width: 28,
          height: 28,
          onLoaded: _onLoaded,
        ),
      ),
    );
  }
}
