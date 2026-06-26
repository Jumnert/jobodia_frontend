import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/features/job_detail/view/widgets/job_detail_icon_button.dart';

class ProfileCoverHeader extends StatelessWidget {
  const ProfileCoverHeader({
    required this.imageUrl,
    required this.isSaved,
    required this.onShare,
    required this.onSave,
    super.key,
  });

  final String imageUrl;
  final bool isSaved;
  final VoidCallback onShare;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
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
          ),
          Container(color: Colors.black.withValues(alpha: 0.1)),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  JobDetailIconButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Back',
                    onPressed: () => _goBack(context),
                  ),
                  const Spacer(),
                  JobDetailIconButton(
                    icon: Icons.ios_share_rounded,
                    tooltip: 'Share',
                    onPressed: onShare,
                  ),
                  const SizedBox(width: 10),
                  JobDetailIconButton(
                    icon: isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    tooltip: isSaved ? 'Saved' : 'Save',
                    onPressed: onSave,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Get.offAllNamed('/home');
    }
  }
}
