import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../routes/app_routes.dart';
import '../../widgets/vital_shimmer.dart';

class VitalIdWebViewScreen extends StatefulWidget {
  const VitalIdWebViewScreen({super.key});

  @override
  State<VitalIdWebViewScreen> createState() => _VitalIdWebViewScreenState();
}

class _VitalIdWebViewScreenState extends State<VitalIdWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;

  static const String _baseUrl = 'https://id.vitalguard.app/login';
  static const String _callbackScheme = 'vitalguard://callback';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
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
            if (mounted) {
              setState(() => _error = 'Error de conexión. Intenta de nuevo.');
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(_baseUrl));
  }

  void _handleCallback(String url) {
    final uri = Uri.parse(url);
    final token = uri.queryParameters['token'];
    final refreshToken = uri.queryParameters['refresh_token'];

    if (token != null && mounted) {
      context.read<AuthService>().login(token, refreshToken: refreshToken);
      // New users go to complete profile, existing users go to dashboard
      Navigator.pushReplacementNamed(context, AppRoutes.completeProfile);
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
                          _controller.loadRequest(Uri.parse(_baseUrl));
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
