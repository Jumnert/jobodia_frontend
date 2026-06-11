import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/features/ai_chat/controller/ai_chat_controller.dart';
import 'package:jobodia_frontend/features/ai_chat/view/ai_chat_screen.dart';
import 'package:jobodia_frontend/features/cv_builder/controller/cv_builder_controller.dart';
import 'package:jobodia_frontend/features/cv_builder/view/cv_builder_screen.dart';
import 'package:jobodia_frontend/features/home/view/home_screen.dart';
import 'package:jobodia_frontend/features/pricing/view/pricing_screen.dart';
import 'package:jobodia_frontend/features/settings/view/settings_screen.dart';

void navigateMainDestination(
  BuildContext context,
  int index, {
  required int currentIndex,
}) {
  if (currentIndex == index) {
    return;
  }

  late final Widget page;

  switch (index) {
    case 0:
      page = const HomeScreen();
    case 1:
      if (!Get.isRegistered<CvBuilderController>()) {
        Get.put(CvBuilderController());
      }
      page = const CvBuilderScreen();
    case 2:
      if (!Get.isRegistered<AiChatController>()) {
        Get.put(AiChatController());
      }
      page = const AiChatScreen();
    case 3:
      page = const PricingScreen();
    default:
      page = const SettingsScreen();
  }

  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
}
