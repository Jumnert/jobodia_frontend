import 'dart:convert';
import 'dart:typed_data';

import 'package:get_storage/get_storage.dart';

/// Local-only persistence for the optional onboarding selfie.
class LocalProfilePhotoStore {
  LocalProfilePhotoStore({GetStorage? storage})
    : _storage = storage ?? GetStorage();

  static const photoKey = 'onboardingProfilePhoto';
  static const completedKey = 'hasCompletedProfilePhotoSetup';

  final GetStorage _storage;

  bool get hasCompletedSetup => _storage.read<bool>(completedKey) == true;

  Uint8List? readPhoto() {
    try {
      final encoded = _storage.read<String>(photoKey);
      if (encoded == null || encoded.isEmpty) return null;
      return base64Decode(encoded);
    } on FormatException {
      return null;
    }
  }

  Future<void> savePhoto(Uint8List bytes) async {
    await _storage.write(photoKey, base64Encode(bytes));
  }

  Future<void> completeSetup() => _storage.write(completedKey, true);
}
