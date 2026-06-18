import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/home/model/job_feed_model.dart';

class JobFeedCard extends StatelessWidget {
  const JobFeedCard({required this.job, this.colorIndex = 0, super.key});

  final JobFeedModel job;

  /// Used to pick a gradient pairing from [AppColors.cardGradients] so each
  /// card in the feed gets a distinct background.
  final int colorIndex;

  @override
  Widget build(BuildContext context) {
    final gradient =
        AppColors.cardGradients[colorIndex % AppColors.cardGradients.length];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact =
            constraints.hasBoundedHeight && constraints.maxHeight <= 260;
        final visibleTags = job.tags.take(isCompact ? 2 : 3).toList();
        final hiddenTagCount = job.tags.length - visibleTags.length;

        return Container(
          padding: EdgeInsets.all(isCompact ? 12 : 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: gradient.last.withValues(alpha: 0.28),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      job.company,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.verified_rounded,
                    color: Colors.white,
                    size: 15,
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.bookmark_border_rounded,
                    size: 18,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ],
              ),
              SizedBox(height: isCompact ? 8 : 12),
              Text(
                job.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: isCompact ? 6 : 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _MetaPill(icon: Icons.wifi_rounded, label: job.level),
                  _MetaPill(
                    icon: Icons.location_on_rounded,
                    label: job.location,
                  ),
                  _MetaPill(
                    icon: Icons.access_time_rounded,
                    label: job.timeAgo,
                  ),
                ],
              ),
              SizedBox(height: isCompact ? 6 : 10),
              Text(
                job.description,
                maxLines: isCompact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.2,
                ),
              ),
              SizedBox(height: isCompact ? 6 : 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  ...visibleTags.map((tag) => _TagChip(label: tag)),
                  if (hiddenTagCount > 0) _TagChip(label: '+$hiddenTagCount'),
                ],
              ),
              SizedBox(height: isCompact ? 8 : 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      job.salary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            job.distance,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.95),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11.5, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
