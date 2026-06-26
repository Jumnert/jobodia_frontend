import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

class ProfileAboutSection extends StatelessWidget {
  const ProfileAboutSection({
    required this.about,
    required this.isExpanded,
    required this.onReadMore,
    super.key,
  });

  final String about;
  final bool isExpanded;
  final VoidCallback onReadMore;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About me',
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: about),
              if (!isExpanded)
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: GestureDetector(
                    onTap: onReadMore,
                    child: Text(
                      '...show more',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          maxLines: isExpanded ? null : 4,
          overflow: isExpanded ? TextOverflow.visible : TextOverflow.clip,
          style: TextStyle(
            color: palette.textSecondary,
            fontSize: 13,
            height: 1.1,
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onReadMore,
            child: Text(
              'Show less',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
