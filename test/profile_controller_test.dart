import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/features/profile/controller/profile_controller.dart';
import 'package:jobodia_frontend/services/secure_storage_service.dart';
import 'package:jobodia_frontend/services/local_profile_photo_store.dart';

/// Mock path_provider so GetStorage can initialize in tests.
Future<void> _setupPathProviderMock() async {
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  final tempDir = await Directory.systemTemp.createTemp('gs_profile_test_');

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall call) async {
        if (call.method == 'getApplicationDocumentsDirectory') {
          return tempDir.path;
        }
        return null;
      });
}

/// Mock flutter_secure_storage to avoid platform channel errors.
void _setupSecureStorageMock() {
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall call) async {
        if (call.method == 'write') return null;
        if (call.method == 'read') return null;
        if (call.method == 'delete') return null;
        if (call.method == 'deleteAll') return null;
        if (call.method == 'readAll') return <String, String>{};
        return null;
      });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GetStorage storage;

  setUpAll(() async {
    await _setupPathProviderMock();
    _setupSecureStorageMock();
    await GetStorage.init();
    storage = GetStorage();
    Get.put(SecureStorageService());
  });

  setUp(() async {
    await storage.erase();
    // Clear the singleton secure-storage cache so tests don't leak state.
    await SecureStorageService.to.deleteAllSecure();
  });

  late ProfileController ctrl;

  setUp(() async {
    ctrl = ProfileController(storage: storage);
    ctrl.onInit();
    await ctrl.ready;
  });

  tearDown(() {
    ctrl.dispose();
  });

  group('profile loads mock data when storage is empty', () {
    test('profile name defaults to Jumnert', () {
      expect(ctrl.profile.name, 'Jumnert');
    });

    test('profile role defaults to Cse Student', () {
      expect(ctrl.profile.role, 'Cse Student');
    });

    test('profile has default skills', () {
      expect(ctrl.profile.skills, contains('Flutter'));
      expect(ctrl.profile.skills, contains('Dart'));
    });

    test('profile has default experiences', () {
      expect(ctrl.profile.experiences.length, 6);
    });
  });

  group('updateProfile', () {
    test('changes profile data', () {
      final updated = ctrl.profile.copyWith(
        name: 'NewName',
        role: 'Senior Dev',
      );

      ctrl.updateProfile(updated);

      expect(ctrl.profile.name, 'NewName');
      expect(ctrl.profile.role, 'Senior Dev');
    });

    test('persists to secure storage, not plaintext', () async {
      final updated = ctrl.profile.copyWith(name: 'Persisted');

      ctrl.updateProfile(updated);

      // PII must land in secure storage...
      final raw = await SecureStorageService.to.readSecure('profile');
      expect(raw, isNotNull);
      expect((jsonDecode(raw!) as Map<String, dynamic>)['name'], 'Persisted');
      // ...and must NOT linger in plaintext GetStorage (the #3 fix).
      expect(storage.read<Map>('profile'), isNull);
    });

    test('clears saveError on success', () {
      ctrl.saveError.value = 'Old error';

      ctrl.updateProfile(ctrl.profile.copyWith(name: 'OK'));

      expect(ctrl.saveError.value, isNull);
    });
  });

  group('toggleAbout', () {
    test('toggles isAboutExpanded', () {
      expect(ctrl.isAboutExpanded.value, isFalse);

      ctrl.toggleAbout();
      expect(ctrl.isAboutExpanded.value, isTrue);

      ctrl.toggleAbout();
      expect(ctrl.isAboutExpanded.value, isFalse);
    });
  });

  group('toggleSaved', () {
    test('toggles isSaved', () {
      expect(ctrl.isSaved.value, isFalse);

      ctrl.toggleSaved();
      expect(ctrl.isSaved.value, isTrue);

      ctrl.toggleSaved();
      expect(ctrl.isSaved.value, isFalse);
    });
  });

  group('clearSaveError', () {
    test('clears saveError', () {
      ctrl.saveError.value = 'Some error';

      ctrl.clearSaveError();

      expect(ctrl.saveError.value, isNull);
    });
  });

  group('persistence', () {
    test('uses the locally captured onboarding selfie as avatar', () async {
      final bytes = Uint8List.fromList([9, 8, 7, 6]);
      await LocalProfilePhotoStore(storage: storage).savePhoto(bytes);

      final ctrl2 = ProfileController(storage: storage);
      ctrl2.onInit();
      await ctrl2.ready;

      expect(ctrl2.profile.avatarBytes, bytes);
      ctrl2.dispose();
    });

    test('loading from stored profile works', () async {
      // Seed secure storage (the source of truth).
      final updated = ctrl.profile.copyWith(name: 'Stored User');
      await SecureStorageService.to.writeSecure(
        'profile',
        jsonEncode(updated.toJson()),
      );

      // Create a new controller that reads from secure storage.
      final ctrl2 = ProfileController(storage: storage);
      ctrl2.onInit();
      await ctrl2.ready;

      expect(ctrl2.profile.name, 'Stored User');
      ctrl2.dispose();
    });

    test('experiences round-trip through persistence', () async {
      final original = ctrl.profile;
      await SecureStorageService.to.writeSecure(
        'profile',
        jsonEncode(original.toJson()),
      );

      final ctrl2 = ProfileController(storage: storage);
      ctrl2.onInit();
      await ctrl2.ready;

      expect(ctrl2.profile.experiences.length, original.experiences.length);
      ctrl2.dispose();
    });

    test('skills round-trip through persistence', () async {
      final original = ctrl.profile;
      await SecureStorageService.to.writeSecure(
        'profile',
        jsonEncode(original.toJson()),
      );

      final ctrl2 = ProfileController(storage: storage);
      ctrl2.onInit();
      await ctrl2.ready;

      expect(ctrl2.profile.skills, original.skills);
      ctrl2.dispose();
    });

    test('legacy plaintext profile is migrated to secure storage', () async {
      // Simulate an older build that wrote PII to plaintext GetStorage.
      final legacy = ctrl.profile.copyWith(name: 'Legacy User');
      storage.writeInMemory('profile', legacy.toJson());

      final ctrl2 = ProfileController(storage: storage);
      ctrl2.onInit();
      await ctrl2.ready;

      // Loaded from the legacy copy...
      expect(ctrl2.profile.name, 'Legacy User');
      // ...migrated into secure storage...
      final raw = await SecureStorageService.to.readSecure('profile');
      expect(raw, isNotNull);
      // ...and the plaintext copy purged.
      expect(storage.read<Map>('profile'), isNull);
      ctrl2.dispose();
    });
  });
}
