import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class AlexaLinkResult {
  final bool success;
  final String? code;
  final String? error;
  final String? state;

  AlexaLinkResult({required this.success, this.code, this.error, this.state});
}

class AlexaService {
  static const String _stateKey = 'alexa_oauth_state';
  static const String _verifierKey = 'alexa_oauth_verifier';
  static const String _linkedKey = 'alexa_linked';

  static String _generateRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
  }

  static String _base64UrlNoPadding(List<int> bytes) {
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  static Future<String> buildAuthorizeUrl({required String accessToken}) async {
    final verifier = _generateRandomString(64);
    final challenge = _base64UrlNoPadding(sha256.convert(utf8.encode(verifier)).bytes);
    final state = _generateRandomString(32);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_stateKey, state);
    await prefs.setString(_verifierKey, verifier);

    final params = {
      'response_type': 'code',
      'client_id': AppConfig.alexaClientId,
      'redirect_uri': AppConfig.alexaRedirectUri,
      'scope': AppConfig.alexaScope,
      'state': state,
      'code_challenge': challenge,
      'code_challenge_method': 'S256',
      'access_token': accessToken,
    };

    final query = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '${AppConfig.vitalIdBaseUrl}/oauth/authorize?$query';
  }

  static Future<AlexaLinkResult> handleCallback(String callbackUrl) async {
    final uri = Uri.parse(callbackUrl);
    final code = uri.queryParameters['code'];
    final error = uri.queryParameters['error'];
    final receivedState = uri.queryParameters['state'];

    final prefs = await SharedPreferences.getInstance();
    final savedState = prefs.getString(_stateKey);

    await prefs.remove(_stateKey);
    await prefs.remove(_verifierKey);

    if (savedState == null || receivedState != savedState) {
      return AlexaLinkResult(
        success: false,
        error: 'state_no_match',
        state: receivedState,
      );
    }

    if (error != null) {
      return AlexaLinkResult(success: false, error: error, state: receivedState);
    }

    if (code != null) {
      await prefs.setBool(_linkedKey, true);
      return AlexaLinkResult(success: true, code: code, state: receivedState);
    }

    return AlexaLinkResult(success: false, error: 'no_code', state: receivedState);
  }

  static Future<bool> isAlexaLinked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_linkedKey) ?? false;
  }

  static Future<void> setAlexaLinked(bool linked) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_linkedKey, linked);
  }

  static Future<AlexaLinkResult> startLinking({required String accessToken}) async {
    try {
      final url = await buildAuthorizeUrl(accessToken: accessToken);

      final result = await FlutterWebAuth2.authenticate(
        url: url,
        callbackUrlScheme: 'mivitalguard',
      );

      return await handleCallback(result);
    } on Exception catch (e) {
      final message = e.toString().toLowerCase();
      if (message.contains('cancel') || message.contains('user_cancelled')) {
        return AlexaLinkResult(success: false, error: 'user_cancelled');
      }
      return AlexaLinkResult(success: false, error: e.toString());
    }
  }
}
