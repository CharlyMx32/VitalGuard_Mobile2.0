import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  static const String _tokenKey = 'vitalguard_token';
  static const String _refreshTokenKey = 'vitalguard_refresh_token';

  String? _token;
  String? _refreshToken;
  bool _isLoading = true;

  String? get token => _token;
  String? get refreshToken => _refreshToken;
  bool get isLoggedIn => _token != null;
  bool get isLoading => _isLoading;

  AuthService() {
    _loadTokens();
  }

  Future<void> _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _refreshToken = prefs.getString(_refreshTokenKey);
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

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    _token = null;
    _refreshToken = null;
    notifyListeners();
  }
}
