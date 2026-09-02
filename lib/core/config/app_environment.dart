import 'package:jobodia_frontend/core/config/launch_profile.dart';

export 'package:jobodia_frontend/core/config/launch_profile.dart'
    show AppEnvironment, LocalAiMode;

/// Build-time behavior shared by services and repositories.
abstract final class AppConfig {
  static AppEnvironment environment = LaunchProfile.active;

  static const _apiBaseUrlOverride = String.fromEnvironment(
    'JOBODIA_API_BASE_URL',
    defaultValue: '',
  );
  static String get apiBaseUrl => _apiBaseUrlOverride.isEmpty
      ? LaunchProfile.apiBaseUrl
      : _apiBaseUrlOverride;

  static bool get isProduction => environment == AppEnvironment.production;

  /// Direct AI is deliberately limited to local builds. A Dart define becomes
  /// part of the built app, so never provide this key for UAT or production.
  static const _localDirectAiKey = String.fromEnvironment(
    'JOBODIA_LOCAL_DEEPSEEK_API_KEY',
    defaultValue: '',
  );
  static const _legacyLocalDirectAiKey = String.fromEnvironment(
    'DEEPSEEK_API_KEY',
    defaultValue: '',
  );
  static bool get directAiSelected =>
      environment == AppEnvironment.local &&
      LaunchProfile.localAiMode == LocalAiMode.direct;
  static String get localDirectAiKey => directAiSelected
      ? (_localDirectAiKey.isNotEmpty
            ? _localDirectAiKey
            : _legacyLocalDirectAiKey)
      : '';

  /// Password authentication uses the backend in every app environment by
  /// default so UAT accounts exercise the same signup/login path as production.
  /// Mock auth remains available for isolated demos via --dart-define.
  static const useMockAuth = bool.fromEnvironment(
    'JOBODIA_USE_MOCK_AUTH',
    defaultValue: false,
  );
  static bool get enableFirebase => isProduction;
  static String get displayName => switch (environment) {
    AppEnvironment.production => 'Jobodia',
    AppEnvironment.uat => 'Jobodia UAT',
    AppEnvironment.local => 'Jobodia Local',
  };

  static void configure(AppEnvironment value) {
    environment = value;
  }
}
