import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

/// A floating action button that appears after scrolling past [threshold] px.
/// Tapping it animates the scroll position back to the top.
///
/// Wrap your scrollable with a [Builder] to get the [ScrollController], then
/// place this widget in a [Stack] above the scrollable:
///
/// ```dart
/// Stack(
///   children: [
///     ListView(controller: _scrollCtrl, ...),
///     ScrollToTopButton(controller: _scrollCtrl),
///   ],
/// )
/// ```
class ScrollToTopButton extends StatefulWidget {
  const ScrollToTopButton({
    super.key,
    required this.controller,
    this.threshold = 500,
  });

  final ScrollController controller;
  final double threshold;

  @override
  State<ScrollToTopButton> createState() => _ScrollToTopButtonState();
}

class _ScrollToTopButtonState extends State<ScrollToTopButton> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final shouldShow = widget.controller.offset > widget.threshold;
    if (shouldShow != _visible) setState(() => _visible = shouldShow);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: IgnorePointer(
        ignoring: !_visible,
        child: Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24, right: 20),
            child: FloatingActionButton.small(
              heroTag: 'scroll-to-top',
              backgroundColor: AppColors.brandTeal,
              onPressed: () {
                widget.controller.animateTo(
                  0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                );
              },
              child: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
