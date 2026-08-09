import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class ScreenshotUploadBox extends StatelessWidget {
  const ScreenshotUploadBox({
    required this.onTap,
    this.imageBytes,
    this.onRemove,
    super.key,
  });

  final VoidCallback onTap;
  final Uint8List? imageBytes;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final bytes = imageBytes;
    if (bytes == null || bytes.isEmpty) {
      return FButton(
        variant: FButtonVariant.outline,
        onPress: onTap,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FLucideIcons.imagePlus, size: 18),
            SizedBox(width: 8),
            Text('Choose screenshot'),
          ],
        ),
      );
    }

    final theme = FTheme.of(context);
    return FCard(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.memory(
              bytes,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Screenshot attached',
                  style: theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ready to include with your report',
                  style: theme.typography.body.xs.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          FButton.icon(
            variant: FButtonVariant.ghost,
            onPress: onRemove,
            child: const Icon(FLucideIcons.trash2),
          ),
        ],
      ),
    );
  }
}
