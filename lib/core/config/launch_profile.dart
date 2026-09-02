enum AppEnvironment { local, uat, production }

/// AI routing available only while the [AppEnvironment.local] profile is active.
enum LocalAiMode { backend, direct }

/// One place to select the app target for normal `flutter run` and builds.
///
/// Keep exactly one [active] line uncommented. `local` uses Android emulator's
/// special host address; for a physical phone, replace it with your computer's
/// LAN IP address (for example, `http://192.168.1.10:8080`).
abstract final class LaunchProfile {
  static const active = AppEnvironment.local;
  // static const active = AppEnvironment.uat;
  // static const active = AppEnvironment.production;

  static const localApiBaseUrl = 'http://10.0.2.2:8080';
  static const uatApiBaseUrl = 'https://v1.jobodia.com';
  static const productionApiBaseUrl = 'https://v1.jobodia.com';

  // static const localAiMode = LocalAiMode.backend;
  static const localAiMode = LocalAiMode.direct;

  static String get apiBaseUrl => switch (active) {
    AppEnvironment.local => localApiBaseUrl,
    AppEnvironment.uat => uatApiBaseUrl,
    AppEnvironment.production => productionApiBaseUrl,
  };
}
