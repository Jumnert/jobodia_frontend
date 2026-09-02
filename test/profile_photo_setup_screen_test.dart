import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/features/profile_setup/controller/profile_photo_setup_controller.dart';
import 'package:jobodia_frontend/features/profile_setup/view/profile_photo_setup_screen.dart';
import 'package:jobodia_frontend/services/local_profile_photo_store.dart';
import 'package:jobodia_frontend/theme/theme.dart';

Future<void> _setupPathProviderMock() async {
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  final tempDir = await Directory.systemTemp.createTemp(
    'jobodia_profile_photo_test_',
  );
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
    await GetStorage.init('profile_photo_setup_test');
    storage = GetStorage('profile_photo_setup_test');
  });

  setUp(() async {
    Get.testMode = true;
    await storage.erase();
    Get.put(
      ProfilePhotoSetupController(
        store: LocalProfilePhotoStore(storage: storage),
      ),
    );
  });

  tearDown(Get.reset);

  testWidgets('shows the selfie prompt without overflowing a small phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      GetMaterialApp(
        builder: (context, child) =>
            FTheme(data: lightTheme, child: child ?? const SizedBox.shrink()),
        home: const ProfilePhotoSetupScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Put a face to your name'), findsOneWidget);
    expect(find.text('Set up your profile'), findsNothing);
    expect(find.text('2 of 3'), findsNothing);
    expect(find.text('Scan now'), findsOneWidget);
    expect(find.text('Skip for now'), findsOneWidget);
    expect(find.text('Stored only on this device'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('local store persists photo bytes and completion state', () async {
    final store = LocalProfilePhotoStore(storage: storage);
    final bytes = Uint8List.fromList([1, 2, 3, 4]);

    await store.savePhoto(bytes);
    await store.completeSetup();

    expect(store.readPhoto(), bytes);
    expect(store.hasCompletedSetup, isTrue);
  });
}
