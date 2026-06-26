import 'package:flutter/widgets.dart';

/// Wraps a child widget so that when it gains focus, the nearest
/// [Scrollable] ancestor scrolls to make it fully visible.
///
/// Usage:
/// ```dart
/// AutoScrollOnFocus(
///   child: TextField(...),
/// )
/// ```
class AutoScrollOnFocus extends StatefulWidget {
  const AutoScrollOnFocus({
    super.key,
    required this.child,
    this.alignment = 0.3,
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.easeOutCubic,
  });

  final Widget child;

  /// Where in the viewport the field should appear (0 = top, 1 = bottom).
  final double alignment;
  final Duration duration;
  final Curve curve;

  @override
  State<AutoScrollOnFocus> createState() => _AutoScrollOnFocusState();
}

class _AutoScrollOnFocusState extends State<AutoScrollOnFocus> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) return;
    // Delay so the keyboard animation has started and the viewport has
    // begun resizing — this gives a more accurate scroll target.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Scrollable.ensureVisible(
        context,
        alignment: widget.alignment,
        duration: widget.duration,
        curve: widget.curve,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(focusNode: _focusNode, child: widget.child);
  }
}
