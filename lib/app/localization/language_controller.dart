import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

enum AppLanguage { english, khmer }

extension AppLanguageX on AppLanguage {
  String get storageValue => switch (this) {
    AppLanguage.english => 'en',
    AppLanguage.khmer => 'km',
  };

  String get label => switch (this) {
    AppLanguage.english => 'English',
    AppLanguage.khmer => 'ខ្មែរ',
  };

  String get fontFamily => switch (this) {
    AppLanguage.english => 'GoogleSansFlex',
    AppLanguage.khmer => 'KantumruyPro',
  };

  Locale get locale => Locale(storageValue);
}

class LanguageController extends GetxController {
  LanguageController({GetStorage? storage})
    : _storage = storage ?? GetStorage();

  static const storageKey = 'appLanguage';

  final GetStorage _storage;
  final Rx<AppLanguage> language = readStoredLanguage().obs;

  AppLanguage get current => language.value;

  void selectLanguage(AppLanguage value) {
    _storage.write(storageKey, value.storageValue);
    if (language.value != value) {
      language.value = value;
    }
    Get.updateLocale(value.locale);
  }

  static AppLanguage readStoredLanguage([GetStorage? storage]) {
    try {
      final code = (storage ?? GetStorage()).read<String>(storageKey);
      return code == AppLanguage.khmer.storageValue
          ? AppLanguage.khmer
          : AppLanguage.english;
    } on Object {
      return AppLanguage.english;
    }
  }
}
