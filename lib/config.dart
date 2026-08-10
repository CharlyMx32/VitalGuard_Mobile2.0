class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://af6f-2806-267-1480-126c-cd4d-b9f8-7781-e522.ngrok-free.app',
  );

  static bool get isNgrok => apiBaseUrl.contains('ngrok');
}
