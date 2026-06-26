import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

/// Animated shimmer effect for loading placeholders.
/// Uses [ShaderMask] + [LinearGradient] sweeping left-to-right over ~1.5 s.
class ShimmerPlaceholder extends StatefulWidget {
  const ShimmerPlaceholder({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  State<ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final base = palette.surfaceMuted;
    final highlight = context.isDark ? palette.surface : Colors.white;

    final child = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: base,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
      ),
    );

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: const Alignment(-1.0, 0),
              end: const Alignment(1.0, 0),
              colors: [base, highlight, base],
              stops: [
                (_ctrl.value - 0.3).clamp(0.0, 1.0),
                _ctrl.value,
                (_ctrl.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: child,
    );
  }
}
