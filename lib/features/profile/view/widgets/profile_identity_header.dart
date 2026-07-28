import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/utils/safe_image_loader.dart';

class ProfileIdentityHeader extends StatelessWidget {
  const ProfileIdentityHeader({
    required this.name,
    required this.role,
    required this.avatarUrl,
    super.key,
  });

  final String name;
  final String role;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Hero(
          tag: 'user-avatar',
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: palette.surface, width: 4),
            ),
            child: ClipOval(
              child: SafeImageLoader(
                url: avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: palette.surfaceMuted,
                  child: const Icon(FLucideIcons.userRound, size: 50),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                role,
                style: TextStyle(color: palette.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
