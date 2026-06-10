import 'package:flutter/material.dart';

class JobTextSection extends StatelessWidget {
  const JobTextSection({
    required this.title,
    required this.body,
    this.maxLines,
    this.actionLabel,
    this.onActionPressed,
    super.key,
  });

  final String title;
  final String body;
  final int? maxLines;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          body,
          maxLines: maxLines,
          overflow: maxLines == null ? null : TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF8B8B8B),
            fontSize: 15.5,
            height: 1.12,
            fontWeight: FontWeight.w400,
          ),
        ),
        if (actionLabel != null && onActionPressed != null) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onActionPressed,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                color: Colors.black,
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
