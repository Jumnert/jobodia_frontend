import 'package:jobodia_frontend/core/widgets/platform_ui.dart';
import 'package:flutter/material.dart';

class JobDetailIconButton extends StatelessWidget {
  const JobDetailIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.backgroundColor,
    super.key,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    // These buttons float over cover images, so glass styling reads well on
    // iOS 26 (and falls back to a Material circle on Android). The white icon
    // is kept for contrast over arbitrary photos regardless of theme.
    final button = AdaptiveButton.icon(
      onPressed: onPressed,
      icon: icon,
      iconColor: Colors.white,
      color: backgroundColor ?? Colors.black.withValues(alpha: 0.38),
      style: AdaptiveButtonStyle.glass,
      borderRadius: BorderRadius.circular(100),
      size: AdaptiveButtonSize.large,
      minSize: const Size(44, 44),
    );
    return tooltip != null ? Tooltip(message: tooltip!, child: button) : button;
  }
}
