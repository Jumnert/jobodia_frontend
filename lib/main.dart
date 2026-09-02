import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:jobodia_frontend/app/bindings/initial_binding.dart';
import 'package:jobodia_frontend/app/localization/app_translations.dart';
import 'package:jobodia_frontend/app/localization/language_controller.dart';
import 'package:jobodia_frontend/app/routes/app_pages.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/app/theme/app_theme.dart';
import 'package:jobodia_frontend/core/widgets/seasonal_atmosphere.dart';
import 'package:jobodia_frontend/core/config/app_environment.dart';
import 'package:jobodia_frontend/core/config/launch_profile.dart';
import 'package:jobodia_frontend/features/onboarding/controllers/onboarding_controller.dart';
import 'package:jobodia_frontend/features/settings/controller/theme_controller.dart';
import 'package:jobodia_frontend/features/splash/view/splash_screen.dart';
import 'package:jobodia_frontend/firebase_options.dart';
import 'package:jobodia_frontend/theme/theme.dart' as forui_theme;

Future<void> main() => bootstrap(LaunchProfile.active);

Future<void> bootstrap(AppEnvironment environment) async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  AppConfig.configure(environment);
  final supportsFirebase =
      AppConfig.enableFirebase &&
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  if (supportsFirebase) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  await GetStorage.init();
  runApp(
    LiquidGlassWidgets.wrap(
      brightnessResolver: Theme.maybeBrightnessOf,
      adaptiveQuality: true,
      theme: const GlassThemeData(
        light: GlassThemeVariant(
          settings: GlassThemeSettings(thickness: 20, blur: 3),
          quality: GlassQuality.standard,
        ),
        dark: GlassThemeVariant(
          settings: GlassThemeSettings(thickness: 20, blur: 3),
          quality: GlassQuality.standard,
        ),
      ),
      child: const JobodiaApp(),
    ),
  );
}

/// App entry widget. GetMaterialApp enables GetX navigation and bindings.
class JobodiaApp extends StatelessWidget {
  const JobodiaApp({super.key, this.initialRoute});

  final String? initialRoute;

  @override
  Widget build(BuildContext context) {
    final preset = ThemeController.readStoredPreset();
    final initialLanguage = LanguageController.readStoredLanguage();
    return GetMaterialApp(
      title: AppConfig.displayName,
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBinding(),
      initialRoute: initialRoute ?? _resolveInitialRoute(),
      unknownRoute: GetPage(
        name: AppRoutes.unknown,
        page: () => const _UnknownRouteScreen(),
      ),
      getPages: AppPages.pages,
      translations: AppTranslations(),
      locale: initialLanguage.locale,
      fallbackLocale: const Locale('en'),
      theme: AppTheme.forPreset(preset, fontFamily: initialLanguage.fontFamily),
      darkTheme: AppTheme.forPreset(
        preset,
        brightness: Brightness.dark,
        fontFamily: initialLanguage.fontFamily,
      ),
      themeMode: _resolveThemeMode(),
      builder: (context, child) {
        final brightness = Theme.of(context).brightness;
        final media = MediaQuery.of(context);
        final appChild = child ?? const SizedBox.shrink();
        final themeController = Get.find<ThemeController>();
        final languageController = Get.find<LanguageController>();
        return Obx(() {
          final fontFamily = languageController.current.fontFamily;
          final materialTheme = AppTheme.forPreset(
            themeController.preset.value,
            brightness: brightness,
            fontFamily: fontFamily,
          );
          final foruiTheme = brightness == Brightness.light
              ? forui_theme.lightThemeWithFont(fontFamily: fontFamily)
              : forui_theme.darkThemeWithFont(fontFamily: fontFamily);

          return Theme(
            data: materialTheme,
            child: MediaQuery(
              data: media.copyWith(platformBrightness: brightness),
              child: FTheme(
                data: foruiTheme,
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
        });
      },
    );
  }

  ThemeMode _resolveThemeMode() {
    try {
      final isDark = GetStorage().read<bool>(ThemeController.themeKey);
      // New installs start in the bright Jobodia theme. A saved user choice
      // still takes precedence on later launches.
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
      if (hasSeenOnboarding != true) return AppRoutes.onboarding;

      final hasSelectedLanguage = GetStorage().hasData(
        LanguageController.storageKey,
      );
      return hasSelectedLanguage
          ? AppRoutes.login
          : AppRoutes.languageSelection;
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
              const Icon(FLucideIcons.compass, size: 64, color: Colors.grey),
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
