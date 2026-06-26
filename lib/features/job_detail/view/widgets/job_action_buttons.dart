import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

class JobActionButtons extends StatelessWidget {
  const JobActionButtons({
    required this.onApply,
    this.isApplied = false,
    this.isAboutExpanded = false,
    this.onToggleAbout,
    super.key,
  });

  final VoidCallback onApply;
  final bool isApplied;
  final bool isAboutExpanded;
  final VoidCallback? onToggleAbout;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onToggleAbout,
            style: OutlinedButton.styleFrom(
              foregroundColor: palette.textPrimary,
              side: BorderSide(color: palette.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            child: Text(
              isAboutExpanded ? 'Read less' : 'Read more',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: isApplied ? null : onApply,
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  gradient: isApplied
                      ? null
                      : const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0, 0.65, 1],
                          colors: [
                            AppColors.primary,
                            AppColors.primary,
                            Color(0xFF0D8585),
                          ],
                        ),
                  color: isApplied ? palette.surfaceMuted : null,
                  border: isApplied ? Border.all(color: palette.border) : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: isApplied
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 18,
                                color: palette.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Applied',
                                style: TextStyle(
                                  color: palette.textSecondary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Apply for this job',
                            style: TextStyle(
                              color: palette.scaffold,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
