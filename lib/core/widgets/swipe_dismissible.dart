import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

/// A thin wrapper around [Dismissible] for swipe-to-delete list rows. Renders a
/// colored background with an icon aligned to the swipe direction and defers the
/// confirm/remove decision to [onDismiss].
///
/// ```dart
/// SwipeDismissible(
///   itemKey: ValueKey(job.id),
///   onDismiss: () => controller.confirmRemove(job),
///   child: JobCard(job: job),
/// )
/// ```
class SwipeDismissible extends StatelessWidget {
  const SwipeDismissible({
    super.key,
    required this.itemKey,
    required this.child,
    required this.onDismiss,
    this.direction = DismissDirection.endToStart,
    this.backgroundColor,
    this.icon = FLucideIcons.trash2,
  });

  /// Stable key identifying the row in its list.
  final Key itemKey;

  /// The row content shown above the swipe background.
  final Widget child;

  /// Called when the row is swiped. Return true to confirm dismissal.
  final Future<bool> Function() onDismiss;

  /// Allowed swipe direction. Defaults to right-to-left.
  final DismissDirection direction;

  /// Background color revealed while swiping. Defaults to the palette error.
  final Color? backgroundColor;

  /// Icon shown on the swipe background.
  final IconData icon;

  Alignment get _alignment {
    switch (direction) {
      case DismissDirection.startToEnd:
        return Alignment.centerLeft;
      case DismissDirection.endToStart:
        return Alignment.centerRight;
      default:
        return Alignment.centerRight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: itemKey,
      direction: direction,
      confirmDismiss: (_) => onDismiss(),
      background: Container(
        alignment: _alignment,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: backgroundColor ?? context.palette.error,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white),
      ),
      child: child,
    );
  }
}
