import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/utils/safe_image_loader.dart';

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
          SafeImageLoader(
            url: imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFFD8E6EF),
              child: const Icon(Icons.business_rounded, size: 64),
            ),
          ),
          Container(color: Colors.black.withValues(alpha: 0.1)),
        ],
      ),
    );
  }
}
