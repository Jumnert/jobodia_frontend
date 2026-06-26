import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum HapticType { light, medium, heavy, selection }

class HapticWrapper extends StatelessWidget {
  const HapticWrapper({
    super.key,
    required this.child,
    this.onTap,
    this.hapticType = HapticType.light,
  });

  final Widget child;
  final VoidCallback? onTap;
  final HapticType hapticType;

  void _triggerHaptic() {
    switch (hapticType) {
      case HapticType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticType.selection:
        HapticFeedback.selectionClick();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          _triggerHaptic();
          onTap!();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}
