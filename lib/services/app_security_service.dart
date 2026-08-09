import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:jobodia_frontend/services/secure_storage_service.dart';

class AppSecurityService extends GetxService {
  AppSecurityService({LocalAuthentication? localAuthentication})
    : _localAuthentication = localAuthentication ?? LocalAuthentication();

  static AppSecurityService get to => Get.find<AppSecurityService>();

  static const pinKey = 'appPin';
  static const biometricEnabledKey = 'biometricEnabled';
  static const _legacyBiometricKey = 'mockFaceIdEnabled';

  final LocalAuthentication _localAuthentication;
  final GetStorage _preferences = GetStorage();

  final hasPin = false.obs;
  final biometricEnabled = false.obs;
  late final Future<void> ready;
  bool _authenticating = false;

  @override
  void onInit() {
    super.onInit();
    ready = _load();
  }

  Future<void> _load() async {
    var pin = await SecureStorageService.to.readSecure(pinKey);
    final legacyPin = _preferences.read<String>(pinKey);
    if ((pin == null || pin.isEmpty) && legacyPin != null) {
      pin = legacyPin;
      await SecureStorageService.to.writeSecure(pinKey, legacyPin);
      _preferences.remove(pinKey);
    }
    hasPin.value = pin?.length == 4;

    final savedBiometric =
        _preferences.read<bool>(biometricEnabledKey) ??
        _preferences.read<bool>(_legacyBiometricKey) ??
        false;
    biometricEnabled.value = savedBiometric && hasPin.value;
    _preferences
      ..write(biometricEnabledKey, biometricEnabled.value)
      ..remove(_legacyBiometricKey);
  }

  Future<void> setPin(String pin) async {
    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      throw const FormatException('A passcode must contain four digits.');
    }
    await SecureStorageService.to.writeSecure(pinKey, pin);
    _preferences.remove(pinKey);
    hasPin.value = true;
  }

  Future<bool> verifyPin(String pin) async {
    await ready;
    final saved = await SecureStorageService.to.readSecure(pinKey);
    return saved != null && saved == pin;
  }

  Future<void> clearPasscode() async {
    await SecureStorageService.to.deleteSecure(pinKey);
    _preferences
      ..remove(pinKey)
      ..write(biometricEnabledKey, false);
    hasPin.value = false;
    biometricEnabled.value = false;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    biometricEnabled.value = enabled && hasPin.value;
    await _preferences.write(biometricEnabledKey, biometricEnabled.value);
  }

  Future<bool> canUseBiometrics() async {
    try {
      final supported = await _localAuthentication.isDeviceSupported();
      if (!supported || !await _localAuthentication.canCheckBiometrics) {
        return false;
      }
      return (await _localAuthentication.getAvailableBiometrics()).isNotEmpty;
    } on Object catch (error) {
      debugPrint('Biometric availability check failed: $error');
      return false;
    }
  }

  Future<bool> authenticateBiometrically(String reason) async {
    if (_authenticating || !biometricEnabled.value) return false;
    _authenticating = true;
    try {
      if (!await canUseBiometrics()) return false;
      return await _localAuthentication.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        sensitiveTransaction: true,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException catch (error) {
      debugPrint('Biometric authentication failed: ${error.code}');
      return false;
    } on Object catch (error) {
      debugPrint('Biometric authentication failed: $error');
      return false;
    } finally {
      _authenticating = false;
    }
  }
}
