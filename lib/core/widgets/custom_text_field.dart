import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart' show PaletteX;

/// Reusable rounded input field for auth forms.
///
/// Wraps [AdaptiveTextField] so the input renders with platform-native styling
/// while keeping the Jobodia pill shape, soft shadow, and label layout.
class CustomTextField extends StatelessWidget {
  const CustomTextField({
    required this.label,
    required this.hintText,
    required this.controller,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.inputFormatters,
    this.maxLength,
    this.errorText,
    super.key,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final hasError = errorText != null && errorText!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: AdaptiveTextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            inputFormatters: inputFormatters,
            maxLength: maxLength,
            onSubmitted: onSubmitted,
            placeholder: hintText,
            prefixIcon: Icon(prefixIcon, color: palette.textPrimary),
            suffixIcon: suffixIcon,
            decoration: InputDecoration(
              filled: true,
              fillColor: palette.surface,
              hintText: hintText,
              hintStyle: TextStyle(color: palette.textTertiary, fontSize: 14),
              prefixIcon: Icon(prefixIcon, color: palette.textPrimary),
              suffixIcon: suffixIcon,
              contentPadding: const EdgeInsets.symmetric(vertical: 17),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: palette.textPrimary, width: 1.4),
              ),
            ),
            // iOS renders a CupertinoTextField and ignores the Material
            // `decoration` above, so style the native field here to keep the
            // pill shape + surface fill instead of the default gray box.
            cupertinoDecoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: palette.border),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              errorText!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
