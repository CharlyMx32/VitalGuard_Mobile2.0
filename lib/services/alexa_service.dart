import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
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

class AlexaLinkStatus {
  final bool linked;
  final String? vitalId;
  final String? clientName;
  final String? scope;
  final DateTime? linkedAt;

  const AlexaLinkStatus({
    required this.linked,
    this.vitalId,
    this.clientName,
    this.scope,
    this.linkedAt,
  });
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

  /// Consulta el estado real de vinculación en el backend de Vital ID
  /// usando el access_token SSO del usuario (JwtAuthGuard).
  ///
  /// [onRefresh] permite renovar el access token si expiró (401): debe devolver
  /// el nuevo access token (y persistirlo) o null si no se pudo refrescar.
  static Future<AlexaLinkStatus> fetchLinkStatus({
    required String accessToken,
    Future<String?> Function()? onRefresh,
  }) async {
    var token = accessToken;
    var triedRefresh = false;

    while (true) {
      final dio = Dio(BaseOptions(
        baseUrl: AppConfig.vitalIdApiBaseUrl,
        headers: {'Authorization': 'Bearer $token'},
      ));
      try {
        final res = await dio.get('/oauth/link-status');
        final body = res.data as Map<String, dynamic>;
        final data = (body['data'] ?? body) as Map<String, dynamic>;
        return AlexaLinkStatus(
          linked: data['linked'] == true,
          vitalId: data['vital_id'] as String?,
          clientName: data['client_name'] as String?,
          scope: data['scope'] as String?,
          linkedAt: data['linked_at'] != null
              ? DateTime.tryParse(data['linked_at'] as String)
              : null,
        );
      } on DioException catch (e) {
        final is401 = e.response?.statusCode == 401;
        if (is401 && !triedRefresh && onRefresh != null) {
          final newToken = await onRefresh();
          if (newToken != null && newToken.isNotEmpty) {
            token = newToken;
            triedRefresh = true;
            continue;
          }
        }
        rethrow;
      }
    }
  }

  /// Desvincula de verdad: revoca los tokens OAuth del usuario en Vital ID
  /// (DELETE /oauth/links) y además limpia la bandera local.
  static Future<bool> unlink({
    required String accessToken,
    Future<String?> Function()? onRefresh,
  }) async {
    var token = accessToken;
    var triedRefresh = false;

    while (true) {
      final dio = Dio(BaseOptions(
        baseUrl: AppConfig.vitalIdApiBaseUrl,
        headers: {'Authorization': 'Bearer $token'},
      ));
      try {
        await dio.delete('/oauth/links');
        await setAlexaLinked(false);
        return true;
      } on DioException catch (e) {
        final is401 = e.response?.statusCode == 401;
        if (is401 && !triedRefresh && onRefresh != null) {
          final newToken = await onRefresh();
          if (newToken != null && newToken.isNotEmpty) {
            token = newToken;
            triedRefresh = true;
            continue;
          }
        }
        await setAlexaLinked(false);
        return false;
      }
    }
  }
}
