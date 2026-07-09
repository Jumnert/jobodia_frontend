import 'package:flutter/material.dart';

class JobCardTopClipper extends CustomClipper<Path> {
  final double cutoutWidth;
  final double cutoutHeight;
  final double cornerRadius;

  JobCardTopClipper({
    this.cutoutWidth = 120,
    this.cutoutHeight = 56,
    this.cornerRadius = 24,
  });

  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, 0);

    path.lineTo(size.width - cutoutWidth - cornerRadius, 0);

    path.quadraticBezierTo(
      size.width - cutoutWidth,
      0,
      size.width - cutoutWidth,
      cornerRadius,
    );

    path.lineTo(size.width - cutoutWidth, cutoutHeight - cornerRadius);

    path.quadraticBezierTo(
      size.width - cutoutWidth,
      cutoutHeight,
      size.width - cutoutWidth + cornerRadius,
      cutoutHeight,
    );

    path.lineTo(size.width, cutoutHeight);

    path.lineTo(size.width, size.height);

    path.lineTo(0, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
