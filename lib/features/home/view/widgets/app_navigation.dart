import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/features/ai_chat/view/ai_chat_screen.dart';
import 'package:jobodia_frontend/features/cv_builder/view/cv_builder_screen.dart';
import 'package:jobodia_frontend/features/home/controller/home_controller.dart';
import 'package:jobodia_frontend/features/home/view/home_screen.dart';
import 'package:jobodia_frontend/features/interview/view/interview_screen.dart';

void navigateMainDestination(
  BuildContext context,
  int index, {
  required int currentIndex,
}) {
  if (currentIndex == index) {
    if (index == 0 && Get.isRegistered<HomeController>()) {
      final ctrl = Get.find<HomeController>().scrollController;
      if (ctrl.hasClients) {
        ctrl.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
    return;
  }

  late final Widget page;

  switch (index) {
    case 0:
      page = const HomeScreen();
    case 1:
      page = const CvBuilderScreen();
    case 2:
      page = const AiChatScreen();
    case 3:
      page = const InterviewScreen();
    default:
      page = const HomeScreen();
  }

  Get.off(
    () => page,
    transition: Transition.fadeIn,
    duration: const Duration(milliseconds: 200),
  );
}
