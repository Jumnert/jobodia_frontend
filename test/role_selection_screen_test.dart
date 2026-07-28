import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/features/role/controller/role_controller.dart';
import 'package:jobodia_frontend/features/role/view/role_selection_screen.dart';
import 'package:jobodia_frontend/theme/theme.dart';

Future<void> _setupPathProviderMock() async {
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  final tempDir = await Directory.systemTemp.createTemp('jobodia_role_view_');
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

  setUpAll(() async {
    Get.testMode = true;
    await _setupPathProviderMock();
    await GetStorage.init('role_view_test');
    Get.put(RoleController(storage: GetStorage('role_view_test'))..onInit());
  });

  tearDownAll(Get.reset);

  testWidgets('role screen has no overflow on a short screen (preview)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      GetMaterialApp(
        home: FTheme(
          data: lightTheme,
          child: const RoleSelectionScreen(preview: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Select Your Role'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
