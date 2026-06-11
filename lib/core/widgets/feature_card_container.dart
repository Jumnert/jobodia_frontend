import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

/// Shared rounded content container used below a feature header.
class FeatureCardContainer extends StatelessWidget {
  const FeatureCardContainer({
    required this.child,
    this.minHeight = 0,
    this.padding = const EdgeInsets.fromLTRB(22, 22, 22, 32),
    super.key,
  });

  final Widget child;
  final double minHeight;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      padding: padding,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: child,
    );
  }
}
