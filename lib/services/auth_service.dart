import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  static const String _tokenKey = 'vitalguard_token';
  static const String _refreshTokenKey = 'vitalguard_refresh_token';
  static const String _profileCompleteKey = 'vitalguard_profile_complete';
  static const String _selfCareKey = 'vitalguard_self_care';
  static const String _patientIdKey = 'vitalguard_patient_id';

  String? _token;
  String? _refreshToken;
  bool _isLoading = true;
  bool _isProfileComplete = false;
  bool _isSelfCare = false;
  int _patientId = 1;

  String? get token => _token;
  String? get refreshToken => _refreshToken;
  bool get isLoggedIn => _token != null;
  bool get isLoading => _isLoading;
  bool get isProfileComplete => _isProfileComplete;
  bool get isSelfCare => _isSelfCare;
  int get patientId => _patientId;

  AuthService() {
    _loadTokens();
  }

  Future<void> _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _refreshToken = prefs.getString(_refreshTokenKey);
    _isProfileComplete = prefs.getBool(_profileCompleteKey) ?? false;
    _isSelfCare = prefs.getBool(_selfCareKey) ?? false;
    _patientId = prefs.getInt(_patientIdKey) ?? 1;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String token, {String? refreshToken}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    _token = token;

    if (refreshToken != null) {
      await prefs.setString(_refreshTokenKey, refreshToken);
      _refreshToken = refreshToken;
    }

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
    _token = null;
    _refreshToken = null;
    _isProfileComplete = false;
    _isSelfCare = false;
    _patientId = 1;
    notifyListeners();
  }
}
