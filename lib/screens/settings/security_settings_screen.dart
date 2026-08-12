import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../theme/app_colors.dart';
import '../../widgets/vital_shimmer.dart';
import '../../widgets/vital_header.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;

  static const String _securityUrl = 'https://id.vitalguard.app/security';

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
          onWebResourceError: (error) {
            if (mounted) {
              setState(() => _error = 'Error de conexión. Intenta de nuevo.');
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(_securityUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          VitalHeader.white(title: 'Seguridad'),
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SkeletonLine(width: 200, height: 18),
                          SizedBox(height: 12),
                          SkeletonLine(width: 160, height: 14),
                          SizedBox(height: 24),
                          SkeletonBlock(height: 120),
                          SizedBox(height: 16),
                          SkeletonLine(width: 140, height: 14),
                          SizedBox(height: 8),
                          SkeletonLine(width: 180, height: 12),
                          SizedBox(height: 8),
                          SkeletonLine(width: 120, height: 12),
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
                                _controller.loadRequest(Uri.parse(_securityUrl));
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
          ),
        ],
      ),
    );
  }

}
