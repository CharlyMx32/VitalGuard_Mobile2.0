import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config.dart';

class AuthService extends ChangeNotifier {
  static const String _tokenKey = 'vitalguard_token';
  static const String _refreshTokenKey = 'vitalguard_refresh_token';
  static const String _profileCompleteKey = 'vitalguard_profile_complete';
  static const String _selfCareKey = 'vitalguard_self_care';
  static const String _patientIdKey = 'vitalguard_patient_id';
  static const String _roleKey = 'vitalguard_role';
  static const String _userKey = 'vitalguard_user';

  String? _token;
  String? _refreshToken;
  bool _isLoading = true;
  bool _isProfileComplete = false;
  bool _isSelfCare = false;
  int? _patientId;
  String? _role;
  Map<String, dynamic>? _user;

  String? get token => _token;
  String? get refreshToken => _refreshToken;
  bool get isLoggedIn => _token != null;
  bool get isLoading => _isLoading;
  bool get isProfileComplete => _isProfileComplete;
  bool get isSelfCare => _isSelfCare;
  int? get patientId => _patientId;
  String? get role => _role;
  Map<String, dynamic>? get user => _user;

  String? get firstName => _user?['first_name'] ?? _user?['firstName'];
  String? get paternalLastName =>
      _user?['paternal_last_name'] ?? _user?['paternalLastName'];
  String? get maternalLastName =>
      _user?['maternal_last_name'] ?? _user?['maternalLastName'];
  String? get email => _user?['email'];
  String? get phone => _user?['phone'];
  String? get birthDate => _user?['birth_date'] ?? _user?['birthDate'];
  String? get gender => _user?['gender'];

  AuthService() {
    _loadTokens();
  }

  Future<void> _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _refreshToken = prefs.getString(_refreshTokenKey);
    _isProfileComplete = prefs.getBool(_profileCompleteKey) ?? false;
    _isSelfCare = prefs.getBool(_selfCareKey) ?? false;
    _patientId = prefs.getInt(_patientIdKey);
    _role = prefs.getString(_roleKey);
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      try {
        _user = jsonDecode(userJson) as Map<String, dynamic>;
      } catch (_) {
        _user = null;
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setTokens(String token, {String? refreshToken}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    _token = token;
    if (refreshToken != null) {
      await prefs.setString(_refreshTokenKey, refreshToken);
      _refreshToken = refreshToken;
    }
    notifyListeners();
  }

  Future<void> login(String token, {String? refreshToken}) async {
    await setTokens(token, refreshToken: refreshToken);
  }

  /// Renueva el access token SSO usando el refresh token guardado
  /// (POST /auth/refresh en Vital ID). Actualiza y persiste ambos tokens.
  /// Devuelve el nuevo access token o null si no se pudo refrescar.
  Future<String?> refreshAccessToken() async {
    final refresh = _refreshToken;
    if (refresh == null || refresh.isEmpty) return null;
    try {
      final dio = Dio(BaseOptions(
        baseUrl: AppConfig.vitalIdApiBaseUrl,
        headers: {'Content-Type': 'application/json'},
      ));
      final res = await dio.post('/auth/refresh', data: {
        'refresh_token': refresh,
      });
      final data = res.data as Map<String, dynamic>;
      final newToken = data['access_token'] as String?;
      final newRefresh = data['refresh_token'] as String?;
      if (newToken == null || newToken.isEmpty) return null;
      await setTokens(newToken, refreshToken: newRefresh);
      return newToken;
    } on Exception {
      return null;
    }
  }

  Future<void> setUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
    _user = user;
    notifyListeners();
  }

  Future<void> completeProfile({bool isSelfCare = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_profileCompleteKey, true);
    await prefs.setBool(_selfCareKey, isSelfCare);
    _isProfileComplete = true;
    _isSelfCare = isSelfCare;
    notifyListeners();
  }

  Future<void> setRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
    _role = role;
    final isSelfCare = role == 'PATIENT';
    await prefs.setBool(_selfCareKey, isSelfCare);
    _isSelfCare = isSelfCare;
    notifyListeners();
  }

  Future<void> setPatientId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_patientIdKey, id);
    _patientId = id;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_profileCompleteKey);
    await prefs.remove(_selfCareKey);
    await prefs.remove(_patientIdKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_userKey);
    _token = null;
    _refreshToken = null;
    _isProfileComplete = false;
    _isSelfCare = false;
    _patientId = null;
    _role = null;
    _user = null;
    try {
      final cookies = WebViewCookieManager();
      await cookies.clearCookies();
    } catch (_) {}
    notifyListeners();
  }
}
