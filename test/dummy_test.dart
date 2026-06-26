import 'package:flutter_test/flutter_test.dart';
import 'package:jobodia_frontend/main.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/features/preferences/controller/preferences_controller.dart';

class _TestPreferencesController extends PreferencesController {
  @override
  bool get hasCompletedPreferences => true;
}

void main() {
  testWidgets('print tree', (tester) async {
    Get.testMode = true;
    Get.reset();
    Get.put<PreferencesController>(_TestPreferencesController(), permanent: true);

    await tester.pumpWidget(const JobodiaApp(initialRoute: AppRoutes.login));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'test@gmail.com');
    await tester.enterText(fields.at(1), '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    debugDumpApp();
  });
}
