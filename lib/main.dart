import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/app/bindings/initial_binding.dart';
import 'package:jobodia_frontend/app/routes/app_pages.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/app/theme/app_theme.dart';
import 'package:jobodia_frontend/features/onboarding/controllers/onboarding_controller.dart';
import 'package:jobodia_frontend/features/settings/controller/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _clearLingeringNativeTabBar();
  await GetStorage.init();
  runApp(const JobodiaApp());
}

/// Tears down any native iOS 26 tab bar that an earlier build/session may have
/// installed at the native root view controller.
///
/// `IOS26NativeSearchTabBar.enable()` swaps the app's native root for a
/// `UITabBarController`, and that swap survives a hot restart (only a full
/// process kill or an explicit `disable()` clears it). The package's own
/// `disable()` is gated behind a Dart flag that resets on restart, so we invoke
/// the platform method directly to guarantee a single, Flutter-managed
/// navigation bar. On a fresh launch (or non-iOS) this is a harmless no-op.
Future<void> _clearLingeringNativeTabBar() async {
  try {
    await const MethodChannel(
      'adaptive_platform_ui/native_tab_bar',
    ).invokeMethod<void>('disableNativeTabBar');
  } on Object {
    // No native tab bar installed — nothing to clear.
  }
}

/// App entry widget. GetMaterialApp enables GetX navigation and bindings.
class JobodiaApp extends StatelessWidget {
  const JobodiaApp({super.key, this.initialRoute});

  final String? initialRoute;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Jobodia',
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBinding(),
      initialRoute: initialRoute ?? _resolveInitialRoute(),
      unknownRoute: GetPage(
        name: AppRoutes.unknown,
        page: () => const _UnknownRouteScreen(),
      ),
      getPages: AppPages.pages,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _resolveThemeMode(),
      // Make native adaptive_platform_ui components (glass buttons, popup
      // menus, tab bar) follow the app's theme instead of the device's system
      // appearance. Those widgets read MediaQuery.platformBrightness, so we
      // override it to match the active app theme.
      builder: (context, child) {
        final brightness = Theme.of(context).brightness;
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(platformBrightness: brightness),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }

  ThemeMode _resolveThemeMode() {
    try {
      final isDark = GetStorage().read<bool>(ThemeController.themeKey);
      return isDark == true ? ThemeMode.dark : ThemeMode.light;
    } on Exception {
      return ThemeMode.light;
    }
  }

  String _resolveInitialRoute() {
    try {
      final hasSeenOnboarding = GetStorage().read<bool>(
        OnboardingController.hasSeenOnboardingKey,
      );
      return hasSeenOnboarding == true ? AppRoutes.login : AppRoutes.onboarding;
    } on Exception {
      return AppRoutes.onboarding;
    }
  }
}

/// Simple 404 screen shown when a route doesn't exist.
class _UnknownRouteScreen extends StatelessWidget {
  const _UnknownRouteScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.explore_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'The page you\'re looking for doesn\'t exist.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Get.offAllNamed(AppRoutes.home),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
