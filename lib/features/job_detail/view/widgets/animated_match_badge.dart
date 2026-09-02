import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

/// A compact match badge whose pill edge moves with its internal light wave.
class AnimatedMatchBadge extends StatefulWidget {
  const AnimatedMatchBadge({required this.text, this.onTap, super.key});

  final String text;
  final VoidCallback? onTap;

  @override
  State<AnimatedMatchBadge> createState() => _AnimatedMatchBadgeState();
}

class _AnimatedMatchBadgeState extends State<AnimatedMatchBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      button: widget.onTap != null,
      label: widget.text,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, _) {
            final progress = reduceMotion ? -1.0 : _animation.value;
            final clipper = _LiquidPillClipper(progress);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: CustomPaint(
                foregroundPainter: _LiquidPillBorderPainter(progress),
                child: ClipPath(
                  clipper: clipper,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      DecoratedBox(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              AppColors.brandDark,
                              AppColors.brandPrimary,
                              AppColors.chart3,
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          child: Text(
                            widget.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              height: 1,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _LiquidLightWavePainter(progress),
                          ),
                        ),
                      ),
                      if (!reduceMotion)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Transform.translate(
                                  offset: Offset(
                                    -constraints.maxWidth * 0.8 +
                                        constraints.maxWidth * 2.35 * progress,
                                    0,
                                  ),
                                  child: Transform.rotate(
                                    angle: -0.24,
                                    child: Center(
                                      child: Container(
                                        width: 16,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white.withValues(alpha: 0),
                                              Colors.white.withValues(
                                                alpha: 0.58,
                                              ),
                                              Colors.white.withValues(alpha: 0),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

Path _liquidPillPath(Size size, double progress) {
  const edgeInset = 2.0;
  final radius = (size.height - edgeInset * 2) / 2;
  final shineCenter = _shineCenter(size, progress);
  final influenceWidth = size.width * 0.17;

  double downwardBend(double x) {
    final distance = (x - shineCenter) / influenceWidth;
    final influence = math.exp(-distance * distance * 1.7);
    return influence * 1.15;
  }

  double top(double x) => edgeInset + downwardBend(x);

  double bottom(double x) => size.height - edgeInset + downwardBend(x);

  final path = Path()..moveTo(radius, top(radius));
  for (double x = radius; x <= size.width - radius; x += 2) {
    path.lineTo(x, top(x));
  }
  path.arcToPoint(
    Offset(size.width - radius, bottom(size.width - radius)),
    radius: Radius.circular(radius),
  );
  for (double x = size.width - radius; x >= radius; x -= 2) {
    path.lineTo(x, bottom(x));
  }
  path.arcToPoint(Offset(radius, top(radius)), radius: Radius.circular(radius));
  return path..close();
}

double _shineCenter(Size size, double progress) =>
    (-0.30 + 2.35 * progress) * size.width;

class _LiquidPillClipper extends CustomClipper<Path> {
  const _LiquidPillClipper(this.progress);

  final double progress;

  @override
  Path getClip(Size size) => _liquidPillPath(size, progress);

  @override
  bool shouldReclip(covariant _LiquidPillClipper oldClipper) =>
      oldClipper.progress != progress;
}

class _LiquidPillBorderPainter extends CustomPainter {
  const _LiquidPillBorderPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      _liquidPillPath(size, progress),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.32)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _LiquidPillBorderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _LiquidLightWavePainter extends CustomPainter {
  const _LiquidLightWavePainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = _shineCenter(size, progress);
    final influenceWidth = size.width * 0.17;
    final left = math.max(0.0, center - influenceWidth * 2.4);
    final right = math.min(size.width, center + influenceWidth * 2.4);
    if (right <= left) return;

    double wave(double x) {
      final distance = (x - center) / influenceWidth;
      final influence = math.exp(-distance * distance * 1.6);
      return size.height * 0.54 + influence * 1.4;
    }

    final path = Path()..moveTo(left, wave(left));
    for (double x = left; x <= right; x += 2) {
      path.lineTo(x, wave(x));
    }
    path
      ..lineTo(right, size.height)
      ..lineTo(left, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.20),
            Colors.white.withValues(alpha: 0.04),
          ],
        ).createShader(Rect.fromLTRB(left, 0, right, size.height)),
    );
  }

  @override
  bool shouldRepaint(covariant _LiquidLightWavePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
