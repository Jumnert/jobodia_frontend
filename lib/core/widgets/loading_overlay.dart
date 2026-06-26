import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

/// Semi-transparent overlay with a centered spinner.
///
/// Wrap any widget to show a loading state on top:
/// ```dart
/// LoadingOverlay(
///   isLoading: controller.isLoading.value,
///   child: MyContent(),
/// )
/// ```
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: ColoredBox(
              color: context.palette.scaffold.withValues(alpha: 0.6),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.brandTeal),
              ),
            ),
          ),
      ],
    );
  }
}
