import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

class CompanyLogo extends StatelessWidget {
  const CompanyLogo({
    super.key,
    this.companyName,
    this.size = 106,
    this.hasBorder = true,
    this.hasShadow = true,
    this.borderRadius,
  });

  final String? companyName;
  final double size;
  final bool hasBorder;
  final bool hasShadow;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final initials = companyName != null && companyName!.isNotEmpty
        ? companyName!
              .split(' ')
              .take(2)
              .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
              .join()
        : '';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: companyName != null
            ? AppColors.primary.withValues(alpha: 0.12)
            : const Color(0xFFEAF6FD),
        borderRadius: BorderRadius.circular(borderRadius ?? 14),
        border: hasBorder
            ? Border.all(color: context.palette.surface, width: 5)
            : null,
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: companyName != null && initials.isNotEmpty
          ? Text(
              initials,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: size * 0.32,
                fontWeight: FontWeight.w800,
              ),
            )
          : Icon(
              Icons.all_inclusive_rounded,
              color: Colors.blue.shade700,
              size: size * 0.58,
            ),
    );
  }
}
