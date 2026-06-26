import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

enum ValidationState { neutral, success, error }

class ValidatedTextField extends StatelessWidget {
  const ValidatedTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.label,
    this.validationState = ValidationState.neutral,
    this.errorMessage,
    this.onChanged,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String? hintText;
  final String? label;
  final ValidationState validationState;
  final String? errorMessage;
  final void Function(String)? onChanged;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    Color borderColor;
    switch (validationState) {
      case ValidationState.success:
        borderColor = AppColors.success;
        break;
      case ValidationState.error:
        borderColor = AppColors.error;
        break;
      case ValidationState.neutral:
        borderColor = Colors.transparent;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: controller,
          onChanged: onChanged,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: AppColors.hint),
            filled: true,
            fillColor: palette.surfaceMuted,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: validationState == ValidationState.error
                    ? AppColors.error
                    : AppColors.primary,
                width: 2,
              ),
            ),
          ),
        ),
        if (validationState == ValidationState.error &&
            errorMessage != null) ...[
          const SizedBox(height: 6),
          Text(
            errorMessage!,
            style: const TextStyle(color: AppColors.error, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
