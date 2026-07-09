import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/utils/safe_image_loader.dart';

class JobDetailHeader extends StatelessWidget {
  const JobDetailHeader({
    required this.imageUrl,
    required this.isSaved,
    required this.onShare,
    required this.onSave,
    this.heroTag,
    super.key,
  });

  final String imageUrl;
  final bool isSaved;
  final VoidCallback onShare;
  final VoidCallback onSave;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final imageWidget = SafeImageLoader(
      url: imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: const Color(0xFFD8E6EF),
        child: const Icon(Icons.business_rounded, size: 64),
      ),
    );

    return AspectRatio(
      aspectRatio: 1.62,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (heroTag != null)
              Hero(tag: heroTag!, child: imageWidget)
            else
              imageWidget,
          ],
        ),
      ),
    );
  }
}
