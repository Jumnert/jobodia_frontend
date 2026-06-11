import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/features/ai_chat/controller/ai_chat_controller.dart';
import 'package:jobodia_frontend/features/ai_chat/view/ai_chat_screen.dart';
import 'package:jobodia_frontend/features/cv_builder/controller/cv_builder_controller.dart';
import 'package:jobodia_frontend/features/cv_builder/view/cv_builder_screen.dart';
import 'package:jobodia_frontend/features/pricing/view/pricing_screen.dart';

class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
        child: Center(
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.8,
            child: Container(
              height: 62,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Icon(Icons.home_outlined),
                  IconButton(
                    onPressed: () {
                      if (!Get.isRegistered<CvBuilderController>()) {
                        Get.put(CvBuilderController());
                      }

                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const CvBuilderScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.layers_outlined),
                  ),
                  IconButton(
                    onPressed: () {
                      if (!Get.isRegistered<AiChatController>()) {
                        Get.put(AiChatController());
                      }

                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const AiChatScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const PricingScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.star_border_rounded),
                  ),
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFF2F4250),
                    child: Icon(
                      Icons.work_outline_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
