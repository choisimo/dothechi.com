/// Environment configuration for the application.
///
/// This class provides centralized configuration management for different
/// environments (development, staging, production).
///
/// Usage:
/// ```dart
/// // In main.dart
/// void main() {
///   AppConfig.initialize(Environment.development);
///   runApp(const MyApp());
/// }
///
/// // Anywhere in the app
/// final baseUrl = AppConfig.instance.authBaseUrl;
/// ```
library;

enum Environment { development, staging, production }

class AppConfig {
  static AppConfig? _instance;

  final Environment environment;
  final String authBaseUrl;
  final String communityBaseUrl;
  final String chatBaseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final bool enableLogging;

  AppConfig._({
    required this.environment,
    required this.authBaseUrl,
    required this.communityBaseUrl,
    required this.chatBaseUrl,
    required this.connectTimeout,
    required this.receiveTimeout,
    required this.enableLogging,
  });

  /// Initialize the app configuration.
  /// Must be called before accessing [instance].
  static void initialize(Environment env) {
    _instance = _createConfig(env);
  }

  /// Get the current app configuration instance.
  /// Throws if [initialize] hasn't been called.
  static AppConfig get instance {
    if (_instance == null) {
      throw StateError(
        'AppConfig not initialized. Call AppConfig.initialize() in main.dart',
      );
    }
    return _instance!;
  }

  /// Check if the configuration has been initialized.
  static bool get isInitialized => _instance != null;

  static AppConfig _createConfig(Environment env) {
    switch (env) {
      case Environment.development:
        return AppConfig._(
          environment: env,
          authBaseUrl: 'http://localhost:18080',
          communityBaseUrl: 'http://localhost:18081',
          chatBaseUrl: 'http://localhost:8080',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          enableLogging: true,
        );

      case Environment.staging:
        return AppConfig._(
          environment: env,
          authBaseUrl: 'https://staging-auth.nodove.com',
          communityBaseUrl: 'https://staging-api.nodove.com',
          chatBaseUrl: 'https://staging-chat.nodove.com',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          enableLogging: true,
        );

      case Environment.production:
        return AppConfig._(
          environment: env,
          authBaseUrl: 'https://auth.nodove.com',
          communityBaseUrl: 'https://community-backend.nodove.com',
          chatBaseUrl: 'https://chat.nodove.com',
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          enableLogging: false,
        );
    }
  }

  /// Whether the app is running in development mode.
  bool get isDevelopment => environment == Environment.development;

  /// Whether the app is running in staging mode.
  bool get isStaging => environment == Environment.staging;

  /// Whether the app is running in production mode.
  bool get isProduction => environment == Environment.production;

  @override
  String toString() {
    return 'AppConfig('
        'environment: $environment, '
        'authBaseUrl: $authBaseUrl, '
        'communityBaseUrl: $communityBaseUrl, '
        'chatBaseUrl: $chatBaseUrl'
        ')';
  }
}
