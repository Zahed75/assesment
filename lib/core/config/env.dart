// lib/core/config/env.dart

/// Clean env config for Shwapno Survey.
/// - Picks defaults by ENV (prod/dev)
/// - Allows optional --dart-define override per base URL.
///   e.g. --dart-define=SURVEY_BASE_URL=http://10.0.2.2:8000 (Android emulator)
class Env {
  /// "prod" | "dev"
  static const env = String.fromEnvironment('ENV', defaultValue: 'prod');

  // ===== Defaults by ENV =====
  static const _centralAuthByEnv = {
    'prod': 'https://api.shwapno.app',
    'dev': 'https://dev.shwapno.app',
  };

  static const _surveyByEnv = {
    'prod': 'https://survey-backend.shwapno.app',
    'dev': 'https://survey-development.shwapno.app', // ← your dev backend
  };

  // ===== Optional explicit overrides (take precedence) =====
  static const _centralAuthOverride = String.fromEnvironment(
    'CENTRAL_AUTH_BASE_URL',
    defaultValue: '',
  );
  static const _surveyOverride = String.fromEnvironment(
    'SURVEY_BASE_URL',
    defaultValue: '',
  );

  /// Logging toggle (default: true on dev, false on prod)
  static const _logNetworkOverride = String.fromEnvironment(
    'LOG_NETWORK',
    defaultValue: '',
  );
  static bool get logNetwork => _logNetworkOverride.isNotEmpty
      ? (_logNetworkOverride.toLowerCase() == 'true')
      : env.toLowerCase() != 'prod';

  static bool get isProd => env.toLowerCase() == 'prod';

  // ===== Resolved base URLs =====
  static String get centralAuthBaseUrl => _centralAuthOverride.isNotEmpty
      ? _centralAuthOverride
      : (_centralAuthByEnv[env.toLowerCase()] ?? _centralAuthByEnv['prod']!);

  static String get surveyBaseUrl => _surveyOverride.isNotEmpty
      ? _surveyOverride
      : (_surveyByEnv[env.toLowerCase()] ?? _surveyByEnv['prod']!);

  // ===== Example endpoints =====
  static String get loginUrl => '$centralAuthBaseUrl/api/user/login';
  static String get registerUrl => '$centralAuthBaseUrl/api/user/register';
  static String get verifyOtpUrl => '$centralAuthBaseUrl/api/verify-otp';
}
