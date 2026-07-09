import 'package:flutter/material.dart';

class JobCardShape extends ShapeBorder {
  final double cutoutWidth;
  final double cutoutHeight;
  final double cornerRadius;
  final double cardRadius;

  const JobCardShape({
    this.cutoutWidth = 105,
    this.cutoutHeight = 56,
    this.cornerRadius = 24,
    this.cardRadius = 24,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final path = Path();

    // Start at top-left, after the corner radius
    path.moveTo(rect.left + cardRadius, rect.top);

    // Top edge to the notch
    path.lineTo(rect.right - cutoutWidth - cornerRadius, rect.top);

    // Convex corner into the notch
    path.quadraticBezierTo(
      rect.right - cutoutWidth,
      rect.top,
      rect.right - cutoutWidth,
      rect.top + cornerRadius,
    );

    // Down into the notch
    path.lineTo(
      rect.right - cutoutWidth,
      rect.top + cutoutHeight - cornerRadius,
    );

    // Concave corner of the notch
    path.quadraticBezierTo(
      rect.right - cutoutWidth,
      rect.top + cutoutHeight,
      rect.right - cutoutWidth + cornerRadius,
      rect.top + cutoutHeight,
    );

    // Right edge of the notch
    path.lineTo(rect.right - cardRadius, rect.top + cutoutHeight);

    // Top-right corner of the bottom section
    path.quadraticBezierTo(
      rect.right,
      rect.top + cutoutHeight,
      rect.right,
      rect.top + cutoutHeight + cardRadius,
    );

    // Right edge down to bottom-right
    path.lineTo(rect.right, rect.bottom - cardRadius);

    // Bottom-right corner
    path.quadraticBezierTo(
      rect.right,
      rect.bottom,
      rect.right - cardRadius,
      rect.bottom,
    );

    // Bottom edge
    path.lineTo(rect.left + cardRadius, rect.bottom);

    // Bottom-left corner
    path.quadraticBezierTo(
      rect.left,
      rect.bottom,
      rect.left,
      rect.bottom - cardRadius,
    );

    // Left edge
    path.lineTo(rect.left, rect.top + cardRadius);

    // Top-left corner
    path.quadraticBezierTo(
      rect.left,
      rect.top,
      rect.left + cardRadius,
      rect.top,
    );

    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) {
    return JobCardShape(
      cutoutWidth: cutoutWidth * t,
      cutoutHeight: cutoutHeight * t,
      cornerRadius: cornerRadius * t,
      cardRadius: cardRadius * t,
    );
  }
}
