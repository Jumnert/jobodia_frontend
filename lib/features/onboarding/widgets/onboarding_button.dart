import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';

class OnboardingButton extends StatelessWidget {
  const OnboardingButton({
    required this.isLastPage,
    required this.onPressed,
    super.key,
  });

  final bool isLastPage;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final label = isLastPage ? 'Get Started' : 'Next';

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FButton(
        onPress: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        suffix: const Icon(FLucideIcons.arrowRight, size: 18),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Text(label, key: ValueKey(label)),
        ),
      ),
    );
  }
}
