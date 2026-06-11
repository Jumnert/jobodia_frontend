import 'package:flutter/material.dart';
import 'package:jobodia_frontend/features/home/model/job_feed_model.dart';

class JobFeedCard extends StatelessWidget {
  const JobFeedCard({required this.job, super.key});

  final JobFeedModel job;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact =
            constraints.hasBoundedHeight && constraints.maxHeight <= 260;
        final visibleTags = job.tags.take(isCompact ? 2 : 3).toList();
        final hiddenTagCount = job.tags.length - visibleTags.length;

        return Container(
          padding: EdgeInsets.all(isCompact ? 12 : 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF0F0F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 6),
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
                        color: Color(0xFF6D6D6D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.verified_rounded,
                    color: Color(0xFF4E79E7),
                    size: 15,
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.bookmark_border_rounded,
                    size: 18,
                    color: Color(0xFF8A8A8A),
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
                  color: Colors.black,
                ),
              ),
              SizedBox(height: isCompact ? 6 : 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _MetaPill(
                    icon: Icons.wifi_rounded,
                    label: job.level,
                    color: const Color(0xFFF4EFFF),
                  ),
                  _MetaPill(
                    icon: Icons.location_on_rounded,
                    label: job.location,
                    color: const Color(0xFFEAF4FF),
                  ),
                  _MetaPill(
                    icon: Icons.access_time_rounded,
                    label: job.timeAgo,
                    color: const Color(0xFFF1F2FF),
                  ),
                ],
              ),
              SizedBox(height: isCompact ? 6 : 10),
              Text(
                job.description,
                maxLines: isCompact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7B7B7B),
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
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      job.proposals,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8A8A8A),
                      ),
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
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Color(0xFF6D6D6D)),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF5D5D5D)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF5D5D5D)),
          ),
        ],
      ),
    );
  }
}
