import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/app/localization/app_translations.dart';
import 'package:jobodia_frontend/app/localization/language_controller.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/features/onboarding/views/language_selection_screen.dart';
import 'package:jobodia_frontend/theme/theme.dart';

Future<void> _setupPathProviderMock() async {
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  final tempDir = await Directory.systemTemp.createTemp(
    'jobodia_language_selection_',
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
    await GetStorage.init('language_selection_test');
    storage = GetStorage('language_selection_test');
  });

  setUp(() async {
    Get.testMode = true;
    await storage.erase();
    Get.reset();
    Get.put<LanguageController>(LanguageController(storage: storage));
  });

  tearDown(Get.reset);

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en'),
        getPages: [
          GetPage(
            name: AppRoutes.login,
            page: () => const Scaffold(body: Text('Login destination')),
          ),
        ],
        builder: (context, child) =>
            FTheme(data: lightTheme, child: child ?? const SizedBox.shrink()),
        home: const LanguageSelectionScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows a dedicated language screen after onboarding', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(find.text('Choose your language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('ខ្មែរ'), findsOneWidget);
    expect(find.text('Continue to sign in'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('saves the choice and continues to login', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(Get.find<LanguageController>().current, AppLanguage.english);
    expect(storage.read<String>(LanguageController.storageKey), 'en');
    await tester.tap(find.text('Continue to sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Login destination'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
