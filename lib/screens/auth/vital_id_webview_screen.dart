import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../services/auth_service.dart';
import '../../services/api_client.dart';
import '../../services/fcm_service.dart';
import '../../config.dart';
import '../../theme/app_colors.dart';
import '../../routes/app_routes.dart';
import '../../widgets/vital_shimmer.dart';

class VitalIdWebViewScreen extends StatefulWidget {
  const VitalIdWebViewScreen({super.key, this.path = '#login'});

  final String path;

  @override
  State<VitalIdWebViewScreen> createState() => _VitalIdWebViewScreenState();
}

class _VitalIdWebViewScreenState extends State<VitalIdWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;
  bool _routeHashApplied = false;
  bool _loginHandled = false;

  static const String _callbackScheme = 'vitalguard://callback';

  String get _baseUrl => AppConfig.vitalIdBaseUrl;

  String get _initialUrl => '$_baseUrl${widget.path}';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'VitalLogin',
        onMessageReceived: (message) {
          _onLoginMessage(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
            _clearWebStorage();
            _injectFetchHook();
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _error = null;
              });
            }
            _applyRouteHash();
            if (!_loginHandled) _tryCaptureTokenFromWeb();
          },
          onNavigationRequest: (request) {
            final url = request.url;
            if (url.startsWith(_callbackScheme)) {
              _handleCallback(url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame != true || !mounted) return;
            setState(() => _error = 'Error de conexión. Intenta de nuevo.');
          },
        ),
      )
      ..loadRequest(
        Uri.parse(_initialUrl),
        headers: const {'ngrok-skip-browser-warning': '1'},
      );
  }

  void _applyRouteHash() {
    final path = widget.path;
    if (_routeHashApplied || !path.startsWith('#')) return;
    _routeHashApplied = true;
    final fragment = path.substring(1);
    final script = 'if (window.location.hash !== "#$fragment") {'
        'window.location.hash = "#$fragment";'
        ' window.location.reload();'
        '}';
    _controller.runJavaScript(script);
  }

    void _clearWebStorage() {
    _controller.runJavaScript('''
      (function () {
        try { window.localStorage.clear(); } catch (e) {}
        try { window.sessionStorage.clear(); } catch (e) {}
      })();
    ''');
  }

  void _injectFetchHook() {
    const script = '''
      (function () {
        if (window.__vgHookInstalled) return;
        window.__vgHookInstalled = true;
        function send(payload) {
          try { VitalLogin.postMessage(JSON.stringify(payload)); } catch (e) {}
        }
        function extractToken(json) {
          try {
            var d = typeof json === 'string' ? JSON.parse(json) : json;
            if (d && d.data && d.data.access_token) return d.data;
            if (d && d.access_token) return d;
            return null;
          } catch (e) { return null; }
        }
        var origFetch = window.fetch;
        if (origFetch) {
          window.fetch = function () {
            var args = arguments;
            return origFetch.apply(this, args).then(function (res) {
              try {
                var url = typeof args[0] === 'string' ? args[0] : (args[0] && args[0].url) || '';
                if (url.indexOf('/auth/login') >= 0) {
                  res.clone().text().then(function (body) {
                    var data = extractToken(body);
                    if (data) send(data);
                  }).catch(function () {});
                }
              } catch (e) {}
              return res;
            });
          };
        }
        var origXhrOpen = XMLHttpRequest.prototype.open;
        XMLHttpRequest.prototype.open = function (method, url) {
          this.__vgUrl = url;
          return origXhrOpen.apply(this, arguments);
        };
        var origXhrSend = XMLHttpRequest.prototype.send;
        XMLHttpRequest.prototype.send = function () {
          var xhr = this;
          xhr.addEventListener('load', function () {
            try {
              if (xhr.__vgUrl && xhr.__vgUrl.indexOf('/auth/login') >= 0) {
                var data = extractToken(xhr.responseText);
                if (data) send(data);
              }
            } catch (e) {}
          });
          return origXhrSend.apply(this, arguments);
        };
      })();
    ''';
    _controller.runJavaScript(script);
  }

  void _onLoginMessage(String raw) {
    debugPrint('[VitalID] login message: $raw');
    try {
      final decoded = Uri.decodeComponent(raw);
      final map = jsonDecode(decoded) as Map<String, dynamic>;
      final token = map['access_token'] as String?;
      if (token == null || token.isEmpty) return;
      final refreshToken = map['refresh_token'] as String?;
      Map<String, dynamic>? user;
      if (map['user'] is Map) {
        user = Map<String, dynamic>.from(map['user'] as Map);
      }
      _completeLogin(token, refreshToken: refreshToken, user: user);
    } catch (e) {
      debugPrint('[VitalID] parse login message error: $e');
    }
  }

  Future<void> _handleCallback(String url) async {
    debugPrint('[VitalID] callback: $url');
    final uri = Uri.parse(url);
    final params = uri.queryParameters;
    final token = params['access_token'] ?? params['token'];
    final refreshToken = params['refresh_token'];

    Map<String, dynamic>? user;
    final fromPayload = token == null
        ? _extractTokenFromPayload(params['data'] ?? params['payload'] ?? url)
        : null;
    if (fromPayload != null) {
      final payload = fromPayload.payload;
      user = payload?['user'] is Map
          ? Map<String, dynamic>.from(payload!['user'] as Map)
          : null;
    } else if (token != null) {
      final userRaw = params['user'];
      if (userRaw != null) {
        try {
          final u = jsonDecode(Uri.decodeComponent(userRaw));
          if (u is Map) user = Map<String, dynamic>.from(u);
        } catch (_) {}
      }
    }

    final finalToken = token ?? fromPayload?.token;
    final finalRefresh = refreshToken ?? (fromPayload?.payload?['refresh_token'] as String?);

    if (finalToken != null) {
      await _completeLogin(finalToken, refreshToken: finalRefresh, user: user);
    }
  }

  /// Intenta leer el token del login directamente desde el almacenamiento del
  /// WebView (localStorage/sessionStorage), por si la web no redirige al
  /// callback del app tras el login exitoso.
  Future<void> _tryCaptureTokenFromWeb() async {
    if (_loginHandled || !mounted) return;
    const script = '''
      (function () {
        var token = null;
        var refresh = null;
        var stores = [window.localStorage, window.sessionStorage];
        for (var s = 0; s < stores.length; s++) {
          try {
            var store = stores[s];
            for (var i = 0; i < store.length; i++) {
              var key = store.key(i);
              var value = store.getItem(key);
              if (!value || typeof value !== 'string') continue;
              var lower = key.toLowerCase();
              var parsed = null;
              var hit = null;
              try { parsed = JSON.parse(value); } catch (e) {}
              if (parsed && parsed.access_token) {
                hit = parsed;
              } else if (parsed && parsed.data && parsed.data.access_token) {
                hit = parsed.data;
              } else if (value.indexOf('eyJ') === 0) {
                if (lower.indexOf('refresh') >= 0) { if (!refresh) refresh = value; }
                else { if (!token) token = value; }
              }
              if (hit) {
                if (!token) token = hit.access_token;
                if (!refresh) refresh = hit.refresh_token;
              }
              if (lower.indexOf('token') >= 0) {
                if (lower.indexOf('refresh') >= 0) { if (!refresh) refresh = value; }
                else { if (!token) token = value; }
              }
            }
          } catch (e) {}
        }
        return JSON.stringify({token: token, refresh: refresh});
      })()
    ''';
    try {
      final result = await _controller.runJavaScriptReturningResult(script);
      debugPrint('[VitalID] storage result: $result');
      if (result == 'null') return;
      final map = jsonDecode('$result') as Map<String, dynamic>;
      final token = map['token'] as String?;
      if (token == null || token.isEmpty) return;
      debugPrint('[VitalID] token capturado de storage: ${token.length} chars');
      if (mounted) await _completeLogin(token, refreshToken: map['refresh'] as String?);
    } catch (_) {}
  }

  Future<void> _completeLogin(
    String token, {
    String? refreshToken,
    Map<String, dynamic>? user,
  }) async {
    if (_loginHandled) return;
    _loginHandled = true;
    debugPrint('[VitalID] _completeLogin: token ${token.length} chars');
    debugPrint('[VitalID] _completeLogin: user data: $user');

    final auth = context.read<AuthService>();
    await auth.login(token, refreshToken: refreshToken);
    debugPrint('[VitalID] _completeLogin: token saved to SharedPreferences');

    if (user != null) {
      await auth.setUser(user);
      debugPrint('[VitalID] _completeLogin: user saved - firstName=${user['first_name'] ?? user['firstName']}, email=${user['email']}');
    } else {
      debugPrint('[VitalID] _completeLogin: NO user data received from login');
    }

    debugPrint('[VitalID] _completeLogin: auth.firstName=${auth.firstName}, auth.email=${auth.email}');

    // Sincroniza token FCM inmediatamente tras login (evita race con invitaciones)
    FcmService? fcm;
    try {
      fcm = context.read<FcmService>();
    } catch (_) {}
    if (fcm != null) {
      try {
        // Pequeño delay para asegurar que SharedPreferences ya tenga el usuario
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
        await fcm.ensureTokenRegistered();
        debugPrint('[VitalID] _completeLogin: FCM token sync triggered');
      } catch (e) {
        debugPrint('[VitalID] _completeLogin: FCM sync failed: $e');
      }
    }

    if (!mounted) return;

    // Check account status and profile
    final apiClient = context.read<ApiClient>();
    var hasProfile = auth.isProfileComplete; // fallback to local state
    try {
      debugPrint('[VitalID] _completeLogin: calling GET /auth/check-status...');
      final res = await apiClient.get('/auth/check-status');
      debugPrint('[VitalID] check-status: ${res.statusCode} ${res.data}');
      if (res.statusCode == 200 && res.data is Map) {
        final data = res.data as Map;
        hasProfile = data['hasProfile'] == true;
        debugPrint('[VitalID] check-status: hasProfile=$hasProfile, vitalId=${data['vitalId']}, message=${data['message']}');
        // Sync local state with backend
        if (hasProfile && !auth.isProfileComplete) {
          await auth.completeProfile(isSelfCare: auth.isSelfCare);
        }
      }
    } catch (e) {
      debugPrint('[VitalID] check-status error: $e');
      debugPrint('[VitalID] check-status failed, using local isProfileComplete=${auth.isProfileComplete}');
    }

    if (!mounted) return;

    // Navigate based on hasProfile
    if (hasProfile) {
      debugPrint('[VitalID] _completeLogin: user HAS profile → navigating to dashboard');
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    } else {
      debugPrint('[VitalID] _completeLogin: user has NO profile → navigating to selectRole');
      Navigator.pushReplacementNamed(context, AppRoutes.selectRole);
    }
  }

  ({String? token, Map<String, dynamic>? payload})? _extractTokenFromPayload(
      String raw) {
    if (!raw.contains('access_token')) return null;
    try {
      final decoded = Uri.decodeComponent(raw);
      final start = decoded.indexOf('{');
      if (start < 0) return null;
      final end = decoded.lastIndexOf('}');
      final json = decoded.substring(start, end + 1);
      final map = jsonDecode(json);
      Map<String, dynamic> root;
      if (map is Map && map['data'] is Map) {
        root = Map<String, dynamic>.from(map['data'] as Map);
      } else if (map is Map) {
        root = Map<String, dynamic>.from(map);
      } else {
        return null;
      }
      return (
        token: root['access_token'] as String?,
        payload: root,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, size: 20, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Vital ID',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SkeletonCircle(size: 56),
                    SizedBox(height: 20),
                    SkeletonLine(width: 180, height: 16),
                    SizedBox(height: 12),
                    SkeletonLine(width: 140, height: 12),
                    SizedBox(height: 24),
                    SkeletonBlock(height: 100),
                    SizedBox(height: 16),
                    SkeletonLine(width: 200, height: 14),
                    SizedBox(height: 8),
                    SkeletonLine(width: 160, height: 12),
                  ],
                ),
              ),
            ),
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.alertCircle,
                      size: 48,
                      color: AppColors.dangerDark,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _error = null;
                            _isLoading = true;
                          });
                          _controller.loadRequest(Uri.parse(_initialUrl));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Reintentar',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
