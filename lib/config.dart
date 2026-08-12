class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://d40f-187-190-56-49.ngrok-free.app',
  );

  static bool get isNgrok => apiBaseUrl.contains('ngrok');

  // OAuth Alexa - Vital ID
  // TODO(backend): Pedir al equipo backend estos valores para producción
  static const String alexaClientId = String.fromEnvironment(
    'ALEXA_CLIENT_ID',
    defaultValue: 'TODO_CLIENT_ID_SKILL_ALEXA',
  );

  static const String vitalIdBaseUrl = String.fromEnvironment(
    'VITAL_ID_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  static const String alexaRedirectUri = 'mivitalguard://oauth/callback';
  static const String alexaScope = 'vitalguard:patient';
}
