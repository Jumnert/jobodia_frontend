enum AppEnvironment { production, uat }

/// Build-time behavior shared by services and repositories.
abstract final class AppConfig {
  static AppEnvironment environment = AppEnvironment.uat;

  static const apiBaseUrl = String.fromEnvironment(
    'JOBODIA_API_BASE_URL',
    defaultValue: 'https://v1.jobodia.com',
  );

  static bool get isProduction => environment == AppEnvironment.production;
  static bool get useMockAuth => !isProduction;
  static bool get enableFirebase => isProduction;
  static String get displayName => isProduction ? 'Jobodia' : 'Jobodia UAT';

  static void configure(AppEnvironment value) {
    environment = value;
  }
}
