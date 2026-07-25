import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jobodia_frontend/app/theme/app_theme.dart';

/// A subtle global atmosphere for selected visual themes.
class SeasonalAtmosphere extends StatefulWidget {
  const SeasonalAtmosphere({
    required this.preset,
    required this.child,
    super.key,
  });

  final AppThemePreset preset;
  final Widget child;

  @override
  State<SeasonalAtmosphere> createState() => _SeasonalAtmosphereState();
}

class _SeasonalAtmosphereState extends State<SeasonalAtmosphere>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 16),
  );

  bool get _hasSeasonalEffect =>
      widget.preset == AppThemePreset.midnight ||
      widget.preset == AppThemePreset.lavender;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant SeasonalAtmosphere oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.preset != widget.preset) _syncAnimation();
  }

  void _syncAnimation() {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (_hasSeasonalEffect && !reduceMotion) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasSeasonalEffect) return widget.child;

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _SeasonalParticlePainter(
                  animation: _controller,
                  preset: widget.preset,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SeasonalParticlePainter extends CustomPainter {
  _SeasonalParticlePainter({required this.animation, required this.preset})
    : super(repaint: animation);

  final Animation<double> animation;
  final AppThemePreset preset;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final isWinter = preset == AppThemePreset.midnight;
    final particleCount = isWinter ? 26 : 17;

    for (var index = 0; index < particleCount; index++) {
      final seed = _fraction(index * 0.61803398875 + 0.17);
      final speed = 0.55 + _fraction(index * 0.371) * 0.75;
      final progress = _fraction(animation.value * speed + seed);
      final baseX = _fraction(index * 0.754877666 + 0.11) * size.width;
      final drift =
          math.sin((progress * math.pi * 2) + index) * (isWinter ? 18 : 32);
      final x = baseX + drift;
      final y = -28 + progress * (size.height + 56);
      final particleSize = isWinter
          ? 2.8 + _fraction(index * 0.43) * 4.8
          : 5.5 + _fraction(index * 0.29) * 6.5;
      final opacity = isWinter
          ? 0.28 + _fraction(index * 0.51) * 0.34
          : 0.24 + _fraction(index * 0.47) * 0.26;

      if (isWinter) {
        _paintSnowflake(canvas, Offset(x, y), particleSize, opacity, index);
      } else {
        _paintMapleLeaf(
          canvas,
          Offset(x, y),
          particleSize,
          opacity,
          progress * math.pi * 4 + index,
          index,
        );
      }
    }
  }

  void _paintSnowflake(
    Canvas canvas,
    Offset center,
    double radius,
    double opacity,
    int index,
  ) {
    final colors = [
      Colors.white,
      const Color(0xFFB9E5FF),
      const Color(0xFF7AB9EB),
    ];
    final paint = Paint()
      ..color = colors[index % colors.length].withValues(alpha: opacity)
      ..strokeWidth = radius < 5 ? 1 : 1.25
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var arm = 0; arm < 3; arm++) {
      final angle = arm * math.pi / 3;
      final delta = Offset(math.cos(angle), math.sin(angle)) * radius;
      canvas.drawLine(center - delta, center + delta, paint);
    }
    canvas.drawCircle(center, radius * 0.2, paint..style = PaintingStyle.fill);
  }

  void _paintMapleLeaf(
    Canvas canvas,
    Offset center,
    double radius,
    double opacity,
    double rotation,
    int index,
  ) {
    final colors = [
      const Color(0xFFD35B2D),
      const Color(0xFFE8923C),
      const Color(0xFFB83A2E),
      const Color(0xFFF1B34D),
    ];
    final paint = Paint()
      ..color = colors[index % colors.length].withValues(alpha: opacity)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, -radius)
      ..lineTo(radius * 0.24, -radius * 0.38)
      ..lineTo(radius * 0.68, -radius * 0.58)
      ..lineTo(radius * 0.48, -radius * 0.08)
      ..lineTo(radius, radius * 0.12)
      ..lineTo(radius * 0.38, radius * 0.34)
      ..lineTo(radius * 0.46, radius * 0.9)
      ..lineTo(0, radius * 0.56)
      ..lineTo(-radius * 0.46, radius * 0.9)
      ..lineTo(-radius * 0.38, radius * 0.34)
      ..lineTo(-radius, radius * 0.12)
      ..lineTo(-radius * 0.48, -radius * 0.08)
      ..lineTo(-radius * 0.68, -radius * 0.58)
      ..lineTo(-radius * 0.24, -radius * 0.38)
      ..close();

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  double _fraction(double value) => value - value.floorToDouble();

  @override
  bool shouldRepaint(covariant _SeasonalParticlePainter oldDelegate) =>
      oldDelegate.preset != preset;
}
