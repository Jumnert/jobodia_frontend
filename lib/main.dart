import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/app/bindings/initial_binding.dart';
import 'package:jobodia_frontend/app/routes/app_pages.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/app/theme/app_theme.dart';
import 'package:jobodia_frontend/core/widgets/seasonal_atmosphere.dart';
import 'package:jobodia_frontend/features/onboarding/controllers/onboarding_controller.dart';
import 'package:jobodia_frontend/features/settings/controller/theme_controller.dart';
import 'package:jobodia_frontend/features/splash/view/splash_screen.dart';
import 'package:jobodia_frontend/theme/theme.dart' as forui_theme;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const JobodiaApp());
}

/// App entry widget. GetMaterialApp enables GetX navigation and bindings.
class JobodiaApp extends StatelessWidget {
  const JobodiaApp({super.key, this.initialRoute});

  final String? initialRoute;

  @override
  Widget build(BuildContext context) {
    final preset = ThemeController.readStoredPreset();
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
      theme: AppTheme.forPreset(preset),
      darkTheme: AppTheme.forPreset(preset, brightness: Brightness.dark),
      themeMode: _resolveThemeMode(),
      builder: (context, child) {
        final brightness = Theme.of(context).brightness;
        final media = MediaQuery.of(context);
        final appChild = child ?? const SizedBox.shrink();
        final themeController = Get.find<ThemeController>();
        return Obx(
          () => MediaQuery(
            data: media.copyWith(platformBrightness: brightness),
            child: FTheme(
              data: brightness == Brightness.light
                  ? forui_theme.lightTheme
                  : forui_theme.darkTheme,
              child: FToaster(
                child: FTooltipGroup(
                  child: SplashScreen(
                    child: SeasonalAtmosphere(
                      preset: themeController.preset.value,
                      child: appChild,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  ThemeMode _resolveThemeMode() {
    try {
      final isDark = GetStorage().read<bool>(ThemeController.themeKey);
      // Default to dark mode when no preference has been saved yet.
      return isDark == false ? ThemeMode.light : ThemeMode.dark;
    } on Exception {
      return ThemeMode.dark;
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
