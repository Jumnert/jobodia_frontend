import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

/// Three-dot pulsing typing indicator animation.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key, this.dotSize = 8});

  final double dotSize;

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
    });
    _animations = _controllers
        .map(
          (c) => Tween<double>(
            begin: 0.4,
            end: 1.0,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)),
        )
        .toList();

    // Stagger the animations.
    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.palette.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return FadeTransition(
          opacity: _animations[i],
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: widget.dotSize * 0.4),
            width: widget.dotSize,
            height: widget.dotSize,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        );
      }),
    );
  }
}
