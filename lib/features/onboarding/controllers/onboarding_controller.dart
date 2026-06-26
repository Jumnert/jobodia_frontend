import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';

class OnboardingController extends GetxController {
  OnboardingController({GetStorage? storage})
    : _storage = storage ?? GetStorage();

  static const hasSeenOnboardingKey = 'hasSeenOnboarding';
  static const _pageIndexKey = 'onboardingPageIndex';
  static const totalPages = 3;

  final GetStorage _storage;
  late final PageController pageController;
  final RxInt currentPage = 0.obs;

  bool get isLastPage => currentPage.value == totalPages - 1;

  @override
  void onInit() {
    super.onInit();
    final savedPage = _storage.read<int>(_pageIndexKey) ?? 0;
    currentPage.value = savedPage.clamp(0, totalPages - 1);
    pageController = PageController(initialPage: currentPage.value);
  }

  void onPageChanged(int index) {
    currentPage.value = index;
    _storage.write(_pageIndexKey, index);
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

  Future<void> completeOnboarding() async {
    await _storage.write(hasSeenOnboardingKey, true);
    await _storage.remove(_pageIndexKey);
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
