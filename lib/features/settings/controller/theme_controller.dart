import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Controls the app-wide theme mode (light / dark).
///
/// Switching is instant and global: [toggleTheme] calls
/// [Get.changeThemeMode], which rebuilds `GetMaterialApp` with the new theme
/// so every screen, background, and text color updates seamlessly. The choice
/// is persisted so it survives app restarts.
class ThemeController extends GetxController {
  ThemeController({GetStorage? storage}) : _storage = storage ?? GetStorage();

  static const themeKey = 'isDarkMode';

  final GetStorage _storage;

  /// Reactive flag the UI can observe to keep switches in sync.
  final RxBool isDarkMode = false.obs;

  ThemeMode get themeMode =>
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _readStoredMode();
  }

  /// Applies [value] across the whole app and persists the choice.
  void toggleTheme(bool value) {
    isDarkMode.value = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    _storage.write(themeKey, value);
  }

  bool _readStoredMode() {
    try {
      return _storage.read<bool>(themeKey) ?? false;
    } on Exception {
      return false;
    }
  }
}
