class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.vitalguard.app',
  );

  static bool get isNgrok => apiBaseUrl.contains('ngrok');

  // OAuth Alexa - Vital ID
  static const String alexaClientId = String.fromEnvironment(
    'ALEXA_CLIENT_ID',
    defaultValue: 'amzn1.application-oa2-client.4e8b1c8852714354a8fae178ef486672',
  );

  static const String vitalIdBaseUrl = String.fromEnvironment(
    'VITAL_ID_BASE_URL',
    defaultValue: 'https://id.vitalguard.app',
  );

  static const String vitalIdApiBaseUrl = String.fromEnvironment(
    'VITAL_ID_API_BASE_URL',
    defaultValue: 'https://id-api.vitalguard.app',
  );

  static const String alexaRedirectUri = 'mivitalguard://oauth/callback';
  static const String alexaScope = 'vitalguard:patient';

  static const String alexaAppUrl = String.fromEnvironment(
    'ALEXA_APP_URL',
    defaultValue: 'https://alexa.amazon.com',
  );
}
