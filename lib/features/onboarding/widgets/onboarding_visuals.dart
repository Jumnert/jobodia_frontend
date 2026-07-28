import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

// These compositions intentionally use only Flutter primitives and local Jobodia
// artwork. No remote image, runtime download, or extra package is required.
enum OnboardingVisualType { jobs, resume, interview }

class OnboardingVisuals extends StatefulWidget {
  const OnboardingVisuals({
    required this.type,
    required this.compact,
    super.key,
  });

  final OnboardingVisualType type;
  final bool compact;

  @override
  State<OnboardingVisuals> createState() => _OnboardingVisualsState();
}

class _OnboardingVisualsState extends State<OnboardingVisuals>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = switch (widget.type) {
      OnboardingVisualType.jobs => const _JobDiscoveryVisual(),
      OnboardingVisualType.resume => const _ResumeVisual(),
      OnboardingVisualType.interview => const _CareerCoachVisual(),
    };

    return Semantics(
      image: true,
      label: switch (widget.type) {
        OnboardingVisualType.jobs => 'Smart job discovery illustration',
        OnboardingVisualType.resume => 'AI assisted CV builder illustration',
        OnboardingVisualType.interview =>
          'Career coaching and interview preparation illustration',
      },
      child: AnimatedBuilder(
        animation: _controller,
        child: RepaintBoundary(child: child),
        builder: (context, child) {
          final phase = _controller.value * math.pi * 2;
          return Transform.translate(
            offset: Offset(0, math.sin(phase) * (widget.compact ? 2.5 : 4)),
            child: child,
          );
        },
      ),
    );
  }
}

class _JobDiscoveryVisual extends StatelessWidget {
  const _JobDiscoveryVisual();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxHeight / 330;

        return ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(38),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.05),
                    radius: 0.86,
                    colors: [
                      Color(0xFFFFE5D1),
                      Color(0xFFFFD5B8),
                      Color(0xFFFFF8F3),
                    ],
                    stops: [0, 0.58, 1],
                  ),
                ),
              ),
              const CustomPaint(painter: _OrbitPainter()),
              Positioned(
                top: 35 * scale,
                left: 0,
                right: 0,
                child: Center(
                  child: Image.asset(
                    'assets/images/onboarding/onboarding_jobs_3d.png',
                    width: 188 * scale,
                    height: 188 * scale,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
              Positioned(
                left: 18,
                top: 86 * scale,
                child: const _RoundBadge(
                  color: Color(0xFF163F58),
                  icon: FLucideIcons.mapPin,
                ),
              ),
              Positioned(
                right: 18,
                top: 65 * scale,
                child: const _RoundBadge(
                  color: Color(0xFFDB755E),
                  icon: FLucideIcons.sparkles,
                ),
              ),
              Positioned(
                left: 30,
                bottom: 37 * scale,
                child: const _RoundBadge(
                  color: Color(0xFF2A7775),
                  icon: FLucideIcons.search,
                ),
              ),
              Positioned(
                right: 26,
                bottom: 49 * scale,
                child: const _RoundBadge(
                  color: Color(0xFF6554A6),
                  icon: FLucideIcons.briefcaseBusiness,
                ),
              ),
              Positioned(
                left: 52,
                right: 52,
                bottom: 17 * scale,
                child: const _FeaturePill(
                  icon: FLucideIcons.badgeCheck,
                  text: 'Smart job matches',
                ),
              ),
              const Positioned(
                top: 24,
                right: 62,
                child: _Sparkle(color: Colors.white, size: 25),
              ),
              const Positioned(
                bottom: 72,
                left: 86,
                child: _Sparkle(color: Color(0xFFFFA77B), size: 17),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ResumeVisual extends StatelessWidget {
  const _ResumeVisual();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxHeight / 330;

        return Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFF4F7F8), Color(0xFFFBFCFC)],
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(38),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 15 * scale,
              width: 238 * scale,
              height: 300 * scale,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3EF),
                  border: Border.all(color: const Color(0xFFB9A697), width: 4),
                  borderRadius: BorderRadius.circular(40 * scale),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x16000000),
                      blurRadius: 25,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35 * scale),
                  child: Stack(
                    children: [
                      const Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFFFFFFF), Color(0xFFF4F8F8)],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 25,
                        right: 25,
                        bottom: -8,
                        height: 175 * scale,
                        child: Image.asset(
                          'assets/images/onboarding/onboarding_resume_3d.png',
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 88 * scale,
              left: 9,
              right: 3,
              child: const _StatusCard(
                icon: FLucideIcons.fileCheck,
                title: 'ATS-ready profile',
                detail: 'Optimized for recruiters',
                badge: 'Ready',
                accent: Color(0xFFDD8D66),
              ),
            ),
            Positioned(
              top: 158 * scale,
              left: 28,
              right: 18,
              child: const _StatusCard(
                icon: FLucideIcons.wandSparkles,
                title: 'Skills matched',
                detail: 'AI suggestions added',
                badge: '92%',
                accent: Color(0xFF76A9A6),
              ),
            ),
            const Positioned(
              left: 24,
              bottom: 45,
              child: _Sparkle(color: Color(0xFFFFAE82), size: 24),
            ),
            const Positioned(
              right: 28,
              bottom: 64,
              child: _Sparkle(color: Color(0xFF89BDB8), size: 28),
            ),
          ],
        );
      },
    );
  }
}

class _CareerCoachVisual extends StatelessWidget {
  const _CareerCoachVisual();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _ArtworkColumn(
                    height: height * 0.70,
                    width: 84,
                    color: const Color(0xFFFFD7C2),
                    asset: 'assets/images/onboarding/onboarding_resume_3d.png',
                    alignment: Alignment.bottomCenter,
                  ),
                  const SizedBox(width: 9),
                  _ArtworkColumn(
                    height: height * 0.88,
                    width: 92,
                    color: const Color(0xFFE8ECEF),
                    asset: 'assets/images/onboarding/onboarding_ai_3d.png',
                    alignment: Alignment.center,
                  ),
                  const SizedBox(width: 9),
                  _ArtworkColumn(
                    height: height * 0.70,
                    width: 84,
                    color: const Color(0xFFCFE5E1),
                    asset: 'assets/images/onboarding/onboarding_jobs_3d.png',
                    alignment: Alignment.bottomCenter,
                  ),
                ],
              ),
            ),
            const Positioned(
              left: 31,
              top: 92,
              child: _RoundBadge(
                color: Color(0xFFDF775B),
                icon: FLucideIcons.messagesSquare,
              ),
            ),
            const Positioned(
              right: 29,
              bottom: 72,
              child: _RoundBadge(
                color: Color(0xFF2D7774),
                icon: FLucideIcons.target,
              ),
            ),
            const Positioned(
              top: 27,
              right: 64,
              child: _Sparkle(color: Color(0xFFD8DDE0), size: 26),
            ),
            const Positioned(
              bottom: 23,
              left: 58,
              child: _Sparkle(color: Color(0xFFFFB38C), size: 22),
            ),
          ],
        );
      },
    );
  }
}

class _ArtworkColumn extends StatelessWidget {
  const _ArtworkColumn({
    required this.height,
    required this.width,
    required this.color,
    required this.asset,
    required this.alignment,
  });

  final double height;
  final double width;
  final Color color;
  final String asset;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(width / 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Image.asset(
          asset,
          alignment: alignment,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.title,
    required this.detail,
    required this.badge,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String detail;
  final String badge;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x15000000),
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Color(0xFF23130D),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Color(0xFF74787B),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              badge,
              style: TextStyle(
                color: accent,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F7D3F22),
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFF23130D),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 15),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              style: const TextStyle(
                color: Color(0xFF23130D),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundBadge extends StatelessWidget {
  const _RoundBadge({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x25000000),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(FLucideIcons.sparkles, color: color, size: size);
  }
}

class _OrbitPainter extends CustomPainter {
  const _OrbitPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.52)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final center = Offset(size.width / 2, size.height * 0.58);

    for (final multiplier in [0.72, 0.92, 1.12]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center,
            width: size.width * multiplier,
            height: size.height * multiplier * 0.48,
          ),
          const Radius.circular(80),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) => false;
}
