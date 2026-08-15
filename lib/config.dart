class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.vitalguard.com',
  );

  static bool get isNgrok => apiBaseUrl.contains('ngrok');

  // OAuth Alexa - Vital ID
  // TODO(backend): Pedir al equipo backend el CLIENT_ID de la skill de Alexa
  static const String alexaClientId = String.fromEnvironment(
    'ALEXA_CLIENT_ID',
    defaultValue: 'TODO_CLIENT_ID_SKILL_ALEXA',
  );

  static const String vitalIdBaseUrl = String.fromEnvironment(
    'VITAL_ID_BASE_URL',
    defaultValue: 'https://id-api.vitalguard.app',
  );

  static const String alexaRedirectUri = 'mivitalguard://oauth/callback';
  static const String alexaScope = 'vitalguard:patient';
}
