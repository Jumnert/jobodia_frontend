import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

/// Interactive screenshot upload tile for the Report screen.
/// Shows a dashed-border + icon when empty, or a thumbnail when an image is
/// attached. [onTap] opens the picker; [onRemove] clears the selection.
class ScreenshotUploadBox extends StatelessWidget {
  const ScreenshotUploadBox({
    super.key,
    required this.onTap,
    this.imageBytes,
    this.onRemove,
  });

  final VoidCallback onTap;
  final Uint8List? imageBytes;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final hasImage = imageBytes != null && imageBytes!.isNotEmpty;

    return GestureDetector(
      onTap: hasImage ? null : onTap,
      child: Container(
        width: 82,
        height: 82,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: hasImage ? null : Colors.transparent,
          image: hasImage
              ? DecorationImage(
                  image: MemoryImage(imageBytes!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: hasImage
            ? Stack(
                children: [
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : CustomPaint(
                painter: _DashedBorderPainter(palette.border),
                child: Center(
                  child: Icon(
                    Icons.add_rounded,
                    color: palette.textSecondary,
                    size: 30,
                  ),
                ),
              ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter(this.borderColor);

  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    const dashLength = 5.0;
    const gapLength = 4.0;
    const radius = Radius.circular(12);
    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(Offset.zero & size, radius));

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashLength),
          paint,
        );
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) => false;
}
