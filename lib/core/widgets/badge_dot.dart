import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

/// Small red dot or counter badge, typically overlaid on an icon.
class BadgeDot extends StatelessWidget {
  const BadgeDot({super.key, this.count});

  /// When non-null and > 0, shows the count as text. When null, shows a plain dot.
  final int? count;

  @override
  Widget build(BuildContext context) {
    final showCount = count != null && count! > 0;
    final label = showCount ? (count! > 99 ? '99+' : '$count') : null;

    return Container(
      constraints: BoxConstraints(
        minWidth: label != null ? 18 : 8,
        minHeight: 8,
      ),
      padding: label != null
          ? const EdgeInsets.symmetric(horizontal: 4, vertical: 1)
          : null,
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(label != null ? 9 : 4),
      ),
      child: label != null
          ? Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            )
          : null,
    );
  }
}
