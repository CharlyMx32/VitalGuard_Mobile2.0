import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config.dart';
import 'auth_service.dart';

class ApiClient {
  late final Dio _dio;
  final AuthService _authService;
  final StreamController<void> _onUnauthorized = StreamController<void>.broadcast();

  // Evita disparar varios refresh en paralelo si varias peticiones reciben
  // 401 al mismo tiempo: solo la primera refresca, el resto espera el resultado.
  bool _isRefreshing = false;
  final List<Completer<bool>> _refreshWaiters = [];

  Stream<void> get onUnauthorized => _onUnauthorized.stream;

  ApiClient(this._authService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _authService.token;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          // Zona horaria del dispositivo para que el backend interprete horarios y fechas en America/Monterrey
          options.headers['X-Timezone'] = 'America/Monterrey';
          debugPrint('[API] ${options.method} ${options.path}');
          handler.next(options);
        },
        onError: (error, handler) async {
          debugPrint('[API] Error ${error.response?.statusCode}: ${error.message}');
          debugPrint('[API] Response body: ${error.response?.data}');

          final isUnauthorized = error.response?.statusCode == 401;
          final alreadyRetried = error.requestOptions.extra['retriedAfterRefresh'] == true;

          if (isUnauthorized && !alreadyRetried && _authService.refreshToken != null) {
            final refreshed = await _refreshTokenOnce();
            if (refreshed) {
              try {
                final retryOptions = error.requestOptions;
                retryOptions.extra['retriedAfterRefresh'] = true;
                retryOptions.headers['Authorization'] = 'Bearer ${_authService.token}';
                final response = await _dio.fetch(retryOptions);
                return handler.resolve(response);
              } catch (_) {
                // Cae al manejo normal de error abajo
              }
            }
          }

          if (isUnauthorized && !_onUnauthorized.isClosed) {
            _onUnauthorized.add(null);
          }
          handler.next(error);
        },
      ),
    );
  }

  /// Refresca el access token una sola vez aunque varias peticiones 401 al
  /// mismo tiempo lo disparen: la primera hace el refresh real, el resto
  /// espera el mismo resultado.
  Future<bool> _refreshTokenOnce() async {
    if (_isRefreshing) {
      final completer = Completer<bool>();
      _refreshWaiters.add(completer);
      return completer.future;
    }
    _isRefreshing = true;
    try {
      final newToken = await _authService.refreshAccessToken();
      final success = newToken != null;
      for (final waiter in _refreshWaiters) {
        if (!waiter.isCompleted) waiter.complete(success);
      }
      return success;
    } finally {
      _isRefreshing = false;
      _refreshWaiters.clear();
    }
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.post<T>(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.put<T>(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.patch<T>(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.delete<T>(path, queryParameters: queryParameters);
  }
}
