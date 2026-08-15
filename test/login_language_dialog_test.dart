import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/app/localization/language_controller.dart';
import 'package:jobodia_frontend/features/auth/controller/auth_controller.dart';
import 'package:jobodia_frontend/features/auth/repository/auth_repository.dart';
import 'package:jobodia_frontend/features/auth/view/login_screen.dart';
import 'package:jobodia_frontend/theme/theme.dart';

Future<void> _setupPathProviderMock() async {
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  final tempDir = await Directory.systemTemp.createTemp(
    'jobodia_language_dialog_',
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

  setUpAll(() async {
    await _setupPathProviderMock();
    await GetStorage.init('language_dialog_test');
  });

  tearDown(Get.reset);

  Future<void> pumpLoginScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Get.testMode = true;
    Get.put<AuthController>(AuthController(AuthRepository()));
    Get.put<LanguageController>(
      LanguageController(storage: GetStorage('language_dialog_test')),
    );

    await tester.pumpWidget(
      GetMaterialApp(
        builder: (context, child) =>
            FTheme(data: lightTheme, child: child ?? const SizedBox.shrink()),
        home: const LoginScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('uses password auth on login and sign-up tabs', (tester) async {
    await pumpLoginScreen(tester);

    expect(find.text('Google'), findsNothing);
    expect(find.text('GitHub'), findsNothing);

    await tester.tap(find.text('Sign up').first);
    await tester.pumpAndSettle();

    expect(find.text('Google'), findsNothing);
    expect(find.text('GitHub'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('UAT confirmation opens a laid-out language chooser', (
    tester,
  ) async {
    await pumpLoginScreen(tester);

    await tester.tap(find.text('Skip login'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Choose your language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('ខ្មែរ'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
