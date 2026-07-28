import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/features/role/controller/role_controller.dart';

Future<void> _setupPathProviderMock() async {
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  final tempDir = await Directory.systemTemp.createTemp('jobodia_role_test_');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'getApplicationDocumentsDirectory') {
          return tempDir.path;
        }
        return null;
      });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GetStorage storage;

  setUpAll(() async {
    await _setupPathProviderMock();
    await GetStorage.init('role_test');
    storage = GetStorage('role_test');
  });

  setUp(() async => storage.erase());

  test('defaults to no role', () {
    final c = RoleController(storage: storage)..onInit();
    expect(c.hasRole, isFalse);
    expect(c.role.value, isNull);
  });

  test('selectRole sets and persists the role', () {
    final c = RoleController(storage: storage)..onInit();
    c.selectRole(UserRole.employer);
    expect(c.role.value, UserRole.employer);
    expect(c.hasRole, isTrue);
    expect(storage.read<String>(RoleController.storageKey), 'employer');
  });

  test('restores the stored role on init', () {
    storage.write(RoleController.storageKey, 'jobSeeker');
    final c = RoleController(storage: storage)..onInit();
    expect(c.role.value, UserRole.jobSeeker);
    expect(c.hasRole, isTrue);
  });

  test('role labels are human readable', () {
    expect(UserRole.jobSeeker.label, 'Job Seeker');
    expect(UserRole.employer.label, 'Employer');
  });
}
