import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

/// Brief branded startup layer shown above the app's resolved initial route.
class SplashScreen extends StatefulWidget {
  const SplashScreen({required this.child, this.onFinished, super.key});

  final Widget child;
  final VoidCallback? onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _displayDuration = Duration(seconds: 5);
  static const _fadeDuration = Duration(milliseconds: 450);

  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _hideAfterDelay();
  }

  Future<void> _hideAfterDelay() async {
    await Future<void>.delayed(_displayDuration);
    if (!mounted) return;

    final onFinished = widget.onFinished;
    if (onFinished != null) {
      onFinished();
      return;
    }

    setState(() => _isVisible = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        AnimatedSwitcher(
          duration: _fadeDuration,
          switchOutCurve: Curves.easeInCubic,
          child: _isVisible
              ? const _SplashContent(key: ValueKey('jobodia-splash'))
              : const SizedBox.shrink(key: ValueKey('app-content')),
        ),
      ],
    );
  }
}

class _SplashContent extends StatefulWidget {
  const _SplashContent({super.key});

  @override
  State<_SplashContent> createState() => _SplashContentState();
}

class _SplashContentState extends State<_SplashContent>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  );
  late final AnimationController _ambientController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return ColoredBox(
      color: palette.scaffold,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: CustomPaint(
              painter: _SplashAtmospherePainter(
                animation: _ambientController,
                background: palette.scaffold,
                foreground: palette.textPrimary,
              ),
            ),
          ),
          Center(
            child: SizedBox(
              width: screenWidth.clamp(260, 420),
              child: AnimatedBuilder(
                animation: _ambientController,
                child: Lottie.asset(
                  'assets/animations/nav_icons/Welcome.json',
                  controller: _controller,
                  fit: BoxFit.contain,
                  repeat: false,
                  renderCache: RenderCache.raster,
                  onLoaded: (_) => _controller.forward(from: 0),
                ),
                builder: (context, child) => ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Color.lerp(AppColors.brandPrimary, Colors.black, 0.24)!,
                      AppColors.brandPrimary,
                      Color.lerp(AppColors.brandPrimary, Colors.white, 0.36)!,
                      AppColors.brandPrimary,
                    ],
                    stops: const [0, 0.34, 0.68, 1],
                    transform: GradientRotation(
                      _ambientController.value * math.pi * 2,
                    ),
                  ).createShader(bounds),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashAtmospherePainter extends CustomPainter {
  _SplashAtmospherePainter({
    required this.animation,
    required this.background,
    required this.foreground,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color background;
  final Color foreground;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final bounds = Offset.zero & size;
    final cycle = t * math.pi * 2;

    canvas.drawRect(
      bounds,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(size.width * (0.05 + 0.12 * math.sin(cycle)), 0),
          Offset(size.width, size.height),
          [
            Color.lerp(background, AppColors.brandPrimary, 0.1)!,
            background,
            Color.lerp(background, AppColors.brandPrimary, 0.07)!,
          ],
          const [0, 0.5, 1],
        ),
    );

    _drawGlow(
      canvas,
      bounds,
      center: Offset(
        size.width * (0.22 + 0.08 * math.sin(cycle)),
        size.height * (0.35 + 0.06 * math.cos(cycle)),
      ),
      radius: size.shortestSide * 0.72,
      color: AppColors.brandPrimary.withValues(alpha: 0.17),
    );
    _drawGlow(
      canvas,
      bounds,
      center: Offset(
        size.width * (0.78 + 0.07 * math.cos(cycle)),
        size.height * (0.64 + 0.08 * math.sin(cycle)),
      ),
      radius: size.shortestSide * 0.62,
      color: Color.lerp(AppColors.brandPrimary, foreground, 0.2)!
          .withValues(alpha: 0.13),
    );

    for (var index = 0; index < 34; index++) {
      final phase = index * 1.731;
      final x =
          ((math.sin(index * 12.9898) + 1) * 0.5 * size.width +
              t * (12 + index % 5)) %
          size.width;
      final y =
          ((math.cos(index * 7.233) + 1) * 0.5 * size.height +
              math.sin(cycle + phase) * 8) %
          size.height;
      final dotColor = index.isEven
          ? AppColors.brandPrimary
          : Color.lerp(AppColors.brandPrimary, foreground, 0.22)!;
      canvas.drawCircle(
        Offset(x, y),
        1.2 + (index % 3) * 0.55,
        Paint()..color = dotColor.withValues(alpha: 0.1),
      );
    }

    final noiseStep = (t * 24).floor();
    final noisePoints = List<Offset>.generate(150, (index) {
      final seed = index * 37.719 + noiseStep * 11.13;
      return Offset(
        (math.sin(seed) + 1) * 0.5 * size.width,
        (math.cos(seed * 1.417) + 1) * 0.5 * size.height,
      );
    });
    canvas.drawPoints(
      ui.PointMode.points,
      noisePoints,
      Paint()
        ..color = foreground.withValues(alpha: 0.035)
        ..strokeWidth = 1,
    );
  }

  void _drawGlow(
    Canvas canvas,
    Rect bounds, {
    required Offset center,
    required double radius,
    required Color color,
  }) {
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = ui.Gradient.radial(center, radius, [
          color,
          color.withValues(alpha: 0),
        ]),
    );
  }

  @override
  bool shouldRepaint(covariant _SplashAtmospherePainter oldDelegate) =>
      oldDelegate.background != background ||
      oldDelegate.foreground != foreground ||
      oldDelegate.animation != animation;
}
