enum AppEnvironment { production, uat }

/// Build-time behavior shared by services and repositories.
abstract final class AppConfig {
  static AppEnvironment environment = AppEnvironment.uat;

  static const apiBaseUrl = String.fromEnvironment(
    'JOBODIA_API_BASE_URL',
    defaultValue: 'https://v1.jobodia.com',
  );

  static bool get isProduction => environment == AppEnvironment.production;

  /// Password authentication uses the backend in every app environment by
  /// default so UAT accounts exercise the same signup/login path as production.
  /// Mock auth remains available for isolated demos via --dart-define.
  static const useMockAuth = bool.fromEnvironment(
    'JOBODIA_USE_MOCK_AUTH',
    defaultValue: false,
  );
  static bool get enableFirebase => isProduction;
  static String get displayName => isProduction ? 'Jobodia' : 'Jobodia UAT';

  static void configure(AppEnvironment value) {
    environment = value;
  }
}
