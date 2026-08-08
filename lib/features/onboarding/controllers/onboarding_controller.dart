import 'dart:async';

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
  static const _autoAdvanceDuration = Duration(seconds: 3);
  static const _autoAdvanceTick = Duration(milliseconds: 50);

  final GetStorage _storage;
  late final PageController pageController;
  final RxInt currentPage = 0.obs;
  final RxDouble autoProgress = 0.0.obs;
  bool _isPreviewMode = false;
  bool _isChangingPage = false;
  Timer? _autoAdvanceTimer;

  bool get isLastPage => currentPage.value == totalPages - 1;

  /// Enables a non-persistent preview launched from Settings.
  void configurePreview(bool value) {
    if (_isPreviewMode == value) return;
    _isPreviewMode = value;
    if (!value) return;

    _autoAdvanceTimer?.cancel();
    currentPage.value = 0;
    autoProgress.value = 0;
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

  @override
  void onReady() {
    super.onReady();
    _startAutoAdvance();
  }

  void _startAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    if (_isPreviewMode) return;

    _autoAdvanceTimer = Timer.periodic(_autoAdvanceTick, (_) {
      if (_isChangingPage) return;

      final nextProgress =
          autoProgress.value +
          _autoAdvanceTick.inMilliseconds / _autoAdvanceDuration.inMilliseconds;
      if (nextProgress < 1) {
        autoProgress.value = nextProgress;
        return;
      }

      autoProgress.value = 1;
      _isChangingPage = true;
      Future<void>.delayed(const Duration(milliseconds: 160), () {
        if (isClosed) return;
        autoProgress.value = 0;
        _animateToPage(isLastPage ? 0 : currentPage.value + 1);
        _isChangingPage = false;
      });
    });
  }

  void onPageChanged(int index) {
    currentPage.value = index;
    if (!_isPreviewMode) _storage.write(_pageIndexKey, index);
  }

  void goNext() {
    autoProgress.value = 0;
    if (isLastPage) {
      completeOnboarding();
      return;
    }

    _animateToNextPage();
  }

  void _animateToNextPage() {
    _animateToPage(currentPage.value + 1);
  }

  void _animateToPage(int page) {
    if (!pageController.hasClients) return;
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeInOutCubic,
    );
  }

  /// Retained for programmatic navigation and onboarding preview controls.
  /// The first-run UI intentionally does not render a Back button.
  void goBack() {
    if (!pageController.hasClients || currentPage.value == 0) return;
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
    _autoAdvanceTimer?.cancel();
    pageController.dispose();
    super.onClose();
  }
}
