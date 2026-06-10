import 'package:flutter/material.dart';

class CompanyLogo extends StatelessWidget {
  const CompanyLogo({
    super.key,
    this.size = 106,
    this.hasBorder = true,
    this.hasShadow = true,
    this.borderRadius,
  });

  final double size;
  final bool hasBorder;
  final bool hasShadow;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6FD),
        borderRadius: BorderRadius.circular(borderRadius ?? 14),
        border: hasBorder ? Border.all(color: Colors.white, width: 5) : null,
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
      child: Icon(
        Icons.all_inclusive_rounded,
        color: Colors.blue.shade700,
        size: size * 0.58,
      ),
    );
  }
}
