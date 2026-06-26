import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/profile/model/profile_model.dart';

class ExperienceTimeline extends StatelessWidget {
  const ExperienceTimeline({required this.experiences, super.key});

  final List<ExperienceModel> experiences;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Experience',
          style: TextStyle(
            color: context.palette.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          experiences.length,
          (index) => _ExperienceTimelineItem(
            experience: experiences[index],
            isLast: index == experiences.length - 1,
          ),
        ),
      ],
    );
  }
}

class _ExperienceTimelineItem extends StatelessWidget {
  const _ExperienceTimelineItem({
    required this.experience,
    required this.isLast,
  });

  final ExperienceModel experience;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 42,
            child: Column(
              children: [
                _ExperienceLogo(imageUrl: experience.logoImageUrl),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 4,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: palette.divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    experience.title,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    experience.duration,
                    style: TextStyle(
                      color: palette.textTertiary,
                      fontSize: 12.5,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    experience.description,
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 13,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExperienceLogo extends StatelessWidget {
  const _ExperienceLogo({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    if (imageUrl == null) {
      return SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: palette.iconMuted,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        shape: BoxShape.circle,
        border: Border.all(color: palette.border, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : const Center(
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 1.5),
                ),
              ),
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.business_rounded, size: 20),
      ),
    );
  }
}
