import 'package:flutter/material.dart';
import 'package:jobodia_frontend/features/ai_chat/controller/ai_chat_controller.dart';

class BotAvatar extends StatelessWidget {
  const BotAvatar({
    super.key,
    required this.size,
    this.model = JobodiaAiModel.flash,
  });

  final double size;
  final JobodiaAiModel model;

  String get _assetPath => switch (model) {
    JobodiaAiModel.flash => 'assets/images/ai_chat/jobodia_flash_mascot.png',
    JobodiaAiModel.pro => 'assets/images/ai_chat/jobodia_pro_mascot.png',
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        _assetPath,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
