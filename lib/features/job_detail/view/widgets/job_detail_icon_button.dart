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
    final button = IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      style: IconButton.styleFrom(
        backgroundColor:
            backgroundColor ?? Colors.black.withValues(alpha: 0.38),
        shape: const CircleBorder(),
        minimumSize: const Size(44, 44),
      ),
    );
    return tooltip != null ? Tooltip(message: tooltip!, child: button) : button;
  }
}
