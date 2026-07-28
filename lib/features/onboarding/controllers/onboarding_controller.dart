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
  bool _isPreviewMode = false;

  bool get isLastPage => currentPage.value == totalPages - 1;

  /// Enables a non-persistent preview launched from Settings.
  void configurePreview(bool value) {
    if (_isPreviewMode == value) return;
    _isPreviewMode = value;
    if (!value) return;

    currentPage.value = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pageController.hasClients) pageController.jumpToPage(0);
    });
  }

  @override
  void onInit() {
    super.onInit();
    final savedPage = _storage.read<int>(_pageIndexKey) ?? 0;
    currentPage.value = savedPage.clamp(0, totalPages - 1);
    pageController = PageController(initialPage: currentPage.value);
  }

  void onPageChanged(int index) {
    currentPage.value = index;
    if (!_isPreviewMode) _storage.write(_pageIndexKey, index);
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

  void goBack() {
    if (currentPage.value == 0) return;

    pageController.animateToPage(
      currentPage.value - 1,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> completeOnboarding() async {
    if (_isPreviewMode) {
      Get.back<void>();
      return;
    }
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
