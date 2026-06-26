import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

class JobTextSection extends StatelessWidget {
  const JobTextSection({
    required this.title,
    required this.body,
    this.isExpanded = false,
    this.actionLabel,
    this.onActionPressed,
    super.key,
  });

  final String title;
  final String body;
  final bool isExpanded;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    final textStyle = TextStyle(
      color: palette.textSecondary,
      fontSize: 15.5,
      height: 1.4,
      fontWeight: FontWeight.w400,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 260),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: Text(
            body,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: textStyle,
          ),
          secondChild: Text(body, style: textStyle),
        ),
        if (actionLabel != null && onActionPressed != null) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onActionPressed,
            child: Text(
              actionLabel!,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
