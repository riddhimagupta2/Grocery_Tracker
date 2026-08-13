class AppConfig {
  /// Default base URL pointing to the live, deployed Render backend.
  /// Overridden at build/run time by passing `--dart-define=API_BASE_URL=...`.
  static const String defaultBaseUrl =
      'https://grocery-tracker-backend-rcwl.onrender.com/api/v1';

  /// Environment-driven API base URL. Reads from `--dart-define=API_BASE_URL=...`
  /// with fallback to [defaultBaseUrl].
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: defaultBaseUrl,
  );
}
