import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/app/theme/app_theme.dart';

/// Controls the app-wide theme mode (light / dark).
///
/// Switching is instant and global: [toggleTheme] calls
/// [Get.changeThemeMode], which rebuilds `GetMaterialApp` with the new theme
/// so every screen, background, and text color updates seamlessly. The choice
/// is persisted so it survives app restarts.
class ThemeController extends GetxController {
  ThemeController({GetStorage? storage}) : _storage = storage ?? GetStorage();

  static const themeKey = 'isDarkMode';
  static const presetKey = 'visualThemePreset';
  static const profileIconKey = 'profileIconIndex';

  final GetStorage _storage;

  /// Reactive flag the UI can observe to keep switches in sync.
  final RxBool isDarkMode = true.obs;
  final Rx<AppThemePreset> preset = AppThemePreset.defaultTheme.obs;
  final RxInt profileIconIndex = 0.obs;

  ThemeMode get themeMode =>
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _readStoredMode();
    preset.value = readStoredPreset(_storage);
    profileIconIndex.value = _readProfileIcon();
  }

  /// Applies [value] across the whole app and persists the choice.
  void toggleTheme(bool value) {
    isDarkMode.value = value;
    Get.changeTheme(
      AppTheme.forPreset(
        preset.value,
        brightness: value ? Brightness.dark : Brightness.light,
      ),
    );
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    _storage.write(themeKey, value);
  }

  void selectPreset(AppThemePreset value) {
    preset.value = value;
    _storage.write(presetKey, value.storageValue);
    Get.changeTheme(
      AppTheme.forPreset(
        value,
        brightness: isDarkMode.value ? Brightness.dark : Brightness.light,
      ),
    );
  }

  void selectProfileIcon(int index) {
    profileIconIndex.value = index.clamp(0, 9);
    _storage.write(profileIconKey, profileIconIndex.value);
  }

  static AppThemePreset readStoredPreset([GetStorage? storage]) {
    try {
      final stored = (storage ?? GetStorage()).read<String>(presetKey);
      return AppThemePreset.values.firstWhere(
        (preset) => preset.storageValue == stored,
        orElse: () => AppThemePreset.defaultTheme,
      );
    } on Object {
      return AppThemePreset.defaultTheme;
    }
  }

  bool _readStoredMode() {
    try {
      // Default to dark mode when no preference has been saved yet.
      return _storage.read<bool>(themeKey) ?? true;
    } on Exception {
      return true;
    }
  }

  int _readProfileIcon() {
    try {
      return (_storage.read<int>(profileIconKey) ?? 0).clamp(0, 9);
    } on Object {
      return 0;
    }
  }
}
