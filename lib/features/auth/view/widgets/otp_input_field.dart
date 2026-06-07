import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/auth/controller/auth_controller.dart';

/// Six-box OTP input. Each box stores one numeric digit.
class OtpInputField extends StatefulWidget {
  const OtpInputField({super.key});

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  static const _otpLength = 6;

  final AuthController _authController = Get.find<AuthController>();
  late final List<TextEditingController> _boxControllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _boxControllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _boxControllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 6.0;
        final rawBoxSize = (constraints.maxWidth - (spacing * 5)) / _otpLength;
        final boxSize = rawBoxSize.clamp(42.0, 56.0);

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_otpLength, (index) {
            return Padding(
              padding: EdgeInsets.only(
                right: index == _otpLength - 1 ? 0 : spacing,
              ),
              child: SizedBox(
                width: boxSize,
                child: _OtpBox(
                  controller: _boxControllers[index],
                  focusNode: _focusNodes[index],
                  onChanged: (value) => _handleChanged(index, value),
                  onBackspaceOnEmpty: () => _moveToPreviousBox(index),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  void _handleChanged(int index, String value) {
    if (value.length > 1) {
      _boxControllers[index].text = value.substring(value.length - 1);
      _boxControllers[index].selection = TextSelection.fromPosition(
        TextPosition(offset: _boxControllers[index].text.length),
      );
    }

    _updateControllerOtp();

    if (_boxControllers[index].text.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    if (_authController.otpController.text.length == _otpLength) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  void _moveToPreviousBox(int index) {
    if (index == 0) return;
    _focusNodes[index - 1].requestFocus();
    _boxControllers[index - 1].clear();
    _updateControllerOtp();
  }

  void _updateControllerOtp() {
    _authController.otpController.text = _boxControllers
        .map((controller) => controller.text)
        .join();
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspaceOnEmpty,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspaceOnEmpty;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            controller.text.isEmpty) {
          onBackspaceOnEmpty();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.4,
              ),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
