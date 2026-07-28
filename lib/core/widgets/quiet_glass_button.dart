import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

/// A glass icon control without the medium native-button haptic.
///
/// Navigation actions intentionally leave [lightHaptic] disabled. Small
/// state-changing actions may opt into a light impact.
class QuietGlassIconButton extends StatelessWidget {
  const QuietGlassIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.lightHaptic = false,
    this.foregroundColor,
    super.key,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final bool lightHaptic;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      label: tooltip,
      child: ClipOval(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Material(
            color: palette.surface.withValues(
              alpha: context.isDark ? .68 : .78,
            ),
            child: InkWell(
              onTap: () {
                if (lightHaptic) HapticFeedback.lightImpact();
                onPressed();
              },
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  icon,
                  color: foregroundColor ?? palette.iconPrimary,
                  size: 21,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QuietGlassBackButton extends StatelessWidget {
  const QuietGlassBackButton({
    required this.onPressed,
    this.foregroundColor,
    super.key,
  });

  final VoidCallback onPressed;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) => QuietGlassIconButton(
    icon: FLucideIcons.arrowLeft,
    tooltip: 'Back',
    onPressed: onPressed,
    foregroundColor: foregroundColor,
  );
}
