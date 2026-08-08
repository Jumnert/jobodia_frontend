import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/features/onboarding/controllers/onboarding_controller.dart';
import 'package:jobodia_frontend/features/onboarding/views/onboarding_view.dart';

Future<void> _setupPathProviderMock() async {
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  final tempDir = await Directory.systemTemp.createTemp(
    'jobodia_onboarding_test_',
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
    Get.testMode = true;
    await _setupPathProviderMock();
    await GetStorage.init('onboarding_widget_test');
    storage = GetStorage('onboarding_widget_test');
  });

  setUp(() async {
    await storage.erase();
    Get.reset();
    Get.put(OnboardingController(storage: storage));
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('renders and navigates all pages at iPhone 6s size', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const GetMaterialApp(home: OnboardingView(previewMode: true)),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Find Work That\nFits Your Life'), findsOneWidget);
    expect(tester.takeException(), isNull);

    Get.find<OnboardingController>().goNext();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Build A CV That\nGets You Noticed'), findsOneWidget);
    expect(find.byIcon(FLucideIcons.chevronLeft), findsNothing);
    expect(tester.takeException(), isNull);

    Get.find<OnboardingController>().goBack();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));
    expect(find.text('Find Work That\nFits Your Life'), findsOneWidget);
    expect(tester.takeException(), isNull);

    Get.find<OnboardingController>().goNext();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    Get.find<OnboardingController>().goNext();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Your Career Coach,\nAlways With You'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
