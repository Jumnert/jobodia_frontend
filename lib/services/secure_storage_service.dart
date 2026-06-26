// ignore_for_file: deprecated_member_use, avoid_print, curly_braces_in_flow_control_structures, unused_import, unnecessary_underscores, unused_field, unused_local_variable, use_build_context_synchronously, duplicate_ignore
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

/// Secure storage wrapper for sensitive data (tokens, PII, CV data).
///
/// Uses Android Keystore / iOS Keychain under the hood.
/// Access via [SecureStorageService.to] singleton.
class SecureStorageService extends GetxService {
  static SecureStorageService get to => Get.find();

  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: _androidOptions,
    iOptions: _iosOptions,
  );

  /// In-memory read-through cache to avoid repeated Keychain/Keystore reads.
  final Map<String, String?> _cache = {};

  Future<void> writeSecure(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      _cache[key] = value;
    } on Exception catch (e) {
      debugPrint('SecureStorageService.writeSecure error: $e');
    }
  }

  Future<String?> readSecure(String key) async {
    if (_cache.containsKey(key)) return _cache[key];
    try {
      final value = await _storage.read(key: key);
      _cache[key] = value;
      return value;
    } on Exception catch (e) {
      debugPrint('SecureStorageService.readSecure error: $e');
      return null;
    }
  }

  Future<void> deleteSecure(String key) async {
    try {
      await _storage.delete(key: key);
      _cache.remove(key);
    } on Exception catch (e) {
      debugPrint('SecureStorageService.deleteSecure error: $e');
    }
  }

  Future<void> deleteAllSecure() async {
    try {
      await _storage.deleteAll();
      _cache.clear();
    } on Exception catch (e) {
      debugPrint('SecureStorageService.deleteAllSecure error: $e');
    }
  }
}
