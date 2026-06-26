import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/features/ai_chat/controller/ai_chat_controller.dart';
import 'package:jobodia_frontend/features/ai_chat/view/ai_chat_screen.dart';
import 'package:jobodia_frontend/features/cv_builder/controller/cv_builder_controller.dart';
import 'package:jobodia_frontend/features/cv_builder/view/cv_builder_screen.dart';
import 'package:jobodia_frontend/features/home/view/home_screen.dart';
import 'package:jobodia_frontend/features/home/view/widgets/app_bottom_navigation_bar.dart';
import 'package:jobodia_frontend/features/interview/controller/interview_schedule_controller.dart';
import 'package:jobodia_frontend/features/interview/view/interview_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  var _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<CvBuilderController>()) {
      Get.put(CvBuilderController());
    }
    if (!Get.isRegistered<AiChatController>()) {
      Get.put(AiChatController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          HomeScreen(showBottomNav: false),
          CvBuilderScreen(showBottomNav: false),
          AiChatScreen(showBottomNav: false),
          InterviewScreen(showBottomNav: false),
        ],
      ),
      bottomNavigationBar: Obx(() {
        final hasBadge =
            Get.isRegistered<InterviewScheduleController>() &&
            Get.find<InterviewScheduleController>().hasUpcomingIn7Days();
        return AppBottomNavigationBar(
          selectedIndex: _selectedIndex,
          interviewHasBadge: hasBadge,
          onDestinationSelected: (index) {
            if (_selectedIndex == index) {
              return;
            }
            setState(() => _selectedIndex = index);
          },
          onSearchPressed: () => Get.toNamed<void>(AppRoutes.search),
        );
      }),
    );
  }
}
