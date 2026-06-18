import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';

class OnboardingController extends GetxController {
  OnboardingController({GetStorage? storage})
    : _storage = storage ?? GetStorage();

  static const hasSeenOnboardingKey = 'hasSeenOnboarding';
  static const totalPages = 3;

  final GetStorage _storage;
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  bool get isLastPage => currentPage.value == totalPages - 1;

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void goNext() {
    if (isLastPage) {
      completeOnboarding();
      return;
    }

    pageController.animateToPage(
      currentPage.value + 1,
      duration: const Duration(milliseconds: 430),
      curve: Curves.easeInOutCubic,
    );
  }

  void nextPage() {
    goNext();
  }

  Future<void> completeOnboarding() async {
    await _storage.write(hasSeenOnboardingKey, true);
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
