import 'dart:math' as math;

import 'package:flutter/material.dart';

enum OnboardingVisualType { jobs, resume, interview }

/// Displays the rendered onboarding artwork with a quiet floating motion.
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
    duration: const Duration(milliseconds: 3600),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visual = _visualFor(widget.type);

    return Semantics(
      image: true,
      label: visual.semanticLabel,
      child: AnimatedBuilder(
        animation: _controller,
        child: RepaintBoundary(
          child: Image.asset(
            visual.assetPath,
            width: widget.compact ? 245 : 292,
            height: widget.compact ? 225 : 280,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            gaplessPlayback: true,
          ),
        ),
        builder: (context, child) {
          final phase = _controller.value * math.pi * 2;
          final lift = math.sin(phase) * (widget.compact ? 3.5 : 5.0);
          final tilt = math.sin(phase + math.pi / 2) * .008;

          return Transform.translate(
            offset: Offset(0, lift),
            child: Transform.rotate(angle: tilt, child: child),
          );
        },
      ),
    );
  }
}

_OnboardingArtwork _visualFor(OnboardingVisualType type) => switch (type) {
  OnboardingVisualType.jobs => const _OnboardingArtwork(
    assetPath: 'assets/images/onboarding/onboarding_jobs_3d.png',
    semanticLabel: 'Job discovery illustration',
  ),
  OnboardingVisualType.resume => const _OnboardingArtwork(
    assetPath: 'assets/images/onboarding/onboarding_resume_3d.png',
    semanticLabel: 'CV building illustration',
  ),
  OnboardingVisualType.interview => const _OnboardingArtwork(
    assetPath: 'assets/images/onboarding/onboarding_ai_3d.png',
    semanticLabel: 'AI career assistant illustration',
  ),
};

class _OnboardingArtwork {
  const _OnboardingArtwork({
    required this.assetPath,
    required this.semanticLabel,
  });

  final String assetPath;
  final String semanticLabel;
}
