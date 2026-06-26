import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/features/job_detail/view/widgets/job_detail_icon_button.dart';

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
    final imageWidget = Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : Container(
              color: const Color(0xFFD8E6EF),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
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
            Container(color: Colors.black.withValues(alpha: 0.16)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  JobDetailIconButton(
                    tooltip: 'Back',
                    icon: Icons.arrow_back_rounded,
                    onPressed: Get.back,
                  ),
                  const Spacer(),
                  JobDetailIconButton(
                    tooltip: 'Share',
                    icon: Icons.ios_share_rounded,
                    onPressed: onShare,
                  ),
                  const SizedBox(width: 10),
                  JobDetailIconButton(
                    tooltip: isSaved ? 'Saved' : 'Save',
                    icon: isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    onPressed: onSave,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
