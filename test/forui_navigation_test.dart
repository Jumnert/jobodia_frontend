import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/features/auth/controller/auth_controller.dart';
import 'package:jobodia_frontend/features/auth/repository/auth_repository.dart';
import 'package:jobodia_frontend/features/auth/view/login_screen.dart';
import 'package:jobodia_frontend/features/home/controller/main_nav_controller.dart';
import 'package:jobodia_frontend/theme/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MainNavController (bottom nav shell)', () {
    test('exposes four persisted tab sections', () {
      expect(MainNavController.tabCount, 4);
    });

    test('goToTab moves to a valid section', () {
      final nav = MainNavController();
      nav.goToTab(3);
      expect(nav.selectedTab.value, 3);
    });

    test('goToTab ignores out-of-range indices', () {
      final nav = MainNavController();
      nav.goToTab(9);
      expect(nav.selectedTab.value, 0);
      nav.goToTab(-1);
      expect(nav.selectedTab.value, 0);
    });

    test('every section index (0..3) is reachable', () {
      final nav = MainNavController();
      for (var i = 0; i < MainNavController.tabCount; i++) {
        nav.goToTab(i);
        expect(nav.selectedTab.value, i);
      }
    });
  });

  group('AuthController tab switching (FTabs lifted control)', () {
    setUp(() => Get.testMode = true);
    tearDown(Get.reset);

    test('changeAuthTab updates the selected tab and clears the error', () {
      final controller = AuthController(AuthRepository());
      controller.errorMessage.value = 'previous error';

      controller.changeAuthTab(1);

      expect(controller.selectedAuthTab.value, 1);
      expect(controller.errorMessage.value, '');
    });

    test('changeAuthTab is a no-op while loading', () {
      final controller = AuthController(AuthRepository());
      controller.isLoading.value = true;

      controller.changeAuthTab(1);

      expect(controller.selectedAuthTab.value, 0);
    });
  });

  testWidgets('LoginScreen renders forui FTabs and taps drive AuthController', (
    tester,
  ) async {
    Get.testMode = true;
    final controller = AuthController(AuthRepository());
    Get.put<AuthController>(controller);
    addTearDown(Get.reset);

    await tester.pumpWidget(
      GetMaterialApp(
        home: FTheme(data: lightTheme, child: const LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // The auth screen is built on a real forui FTabs, starting on Login.
    expect(find.byType(FTabs), findsOneWidget);
    expect(find.text('Log in'), findsWidgets);
    expect(find.text('Sign up'), findsWidgets);
    expect(controller.selectedAuthTab.value, 0);

    // Tapping the Sign up tab flips the lifted control's index.
    await tester.tap(find.text('Sign up').first);
    await tester.pumpAndSettle();
    expect(controller.selectedAuthTab.value, 1);
  });
}
