import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class BlurredHeader extends StatelessWidget {
  const BlurredHeader({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bg = FTheme.of(context).colors.background;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: ColoredBox(color: bg.withValues(alpha: 0.85), child: child),
      ),
    );
  }
}
