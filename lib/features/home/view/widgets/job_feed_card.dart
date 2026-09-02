import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/utils/localized_time_ago.dart';
import 'package:jobodia_frontend/core/widgets/company_avatar.dart';
import 'package:jobodia_frontend/features/home/model/job_feed_model.dart';
import 'package:jobodia_frontend/features/home/view/widgets/job_card_shape.dart';

class JobFeedCard extends StatelessWidget {
  const JobFeedCard({
    required this.job,
    this.colorIndex = 0,
    this.isSaved = false,
    this.onToggleSave,
    super.key,
  });

  final JobFeedModel job;
  final int colorIndex;
  final bool isSaved;
  final VoidCallback? onToggleSave;

  static const _pastelColors = [
    Color(0xFFE2DFFF), // Soft purple (Google-like in screenshot)
    Color(0xFFFFD4D4), // Soft pink (Airbnb-like in screenshot)
    Color(0xFFD4E5FF), // Soft blue
    Color(0xFFE1EFFF), // Soft blue
  ];

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = _pastelColors[colorIndex % _pastelColors.length];
    final topColor = baseColor; // Keep it colorful in dark mode too

    return Stack(
      children: [
        Container(
          decoration: ShapeDecoration(
            color: palette.surface,
            shape: const JobCardShape(),
            shadows: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: topColor,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CompanyAvatar(
                            companyName: job.company,
                            size: 44,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                job.company,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4B5563),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 80), // Space for Apply button
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _PastelPill(
                          icon: FLucideIcons.mapPin,
                          label: job.location,
                        ),
                        _PastelPill(
                          icon: FLucideIcons.graduationCap,
                          label: job.level,
                        ), // using level as exp placeholder
                        _PastelPill(
                          icon: FLucideIcons.clock,
                          label: 'full_time'.tr,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text.rich(
                      TextSpan(
                        text: job.description,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: Color(0xFF374151),
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(
                            text: ' ...${'read_more'.tr}',
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          FLucideIcons.history,
                          size: 16,
                          color: palette.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'posted_time'.trParams({
                            'time': localizedTimeAgo(job.timeAgo),
                          }),
                          style: TextStyle(
                            fontSize: 13,
                            color: palette.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      job.salary,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: palette.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white : const Color(0xFF222222),
              foregroundColor: isDark ? Colors.black : Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: Row(
              children: [
                Text(
                  'apply'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(FLucideIcons.arrowUpRight, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PastelPill extends StatelessWidget {
  const _PastelPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5), // Semi-transparent white
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF4B5563)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF374151),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
