import 'package:flutter/material.dart';

/// Circle avatar that shows a company's initials with a deterministic
/// background color derived from the company name hash.
class CompanyAvatar extends StatelessWidget {
  const CompanyAvatar({
    super.key,
    required this.companyName,
    this.size = 44,
    this.imageUrl,
  });

  final String companyName;
  final double size;
  final String? imageUrl;

  /// Deterministic color from company name.
  Color _colorFromName(String name) {
    final hash = name.codeUnits.fold<int>(0, (acc, c) => acc * 31 + c);
    final hue = (hash % 360).toDouble().abs();
    return HSLColor.fromAHSL(1.0, hue, 0.45, 0.45).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final initials = companyName.isNotEmpty
        ? companyName.trim().split('').first.toUpperCase()
        : '?';

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _InitialsCircle(
            initials: initials,
            size: size,
            color: _colorFromName(companyName),
          ),
        ),
      );
    }

    return _InitialsCircle(
      initials: initials,
      size: size,
      color: _colorFromName(companyName),
    );
  }
}

class _InitialsCircle extends StatelessWidget {
  const _InitialsCircle({
    required this.initials,
    required this.size,
    required this.color,
  });

  final String initials;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
