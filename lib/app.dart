import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'routes/app_routes.dart';
import 'services/auth_service.dart';
import 'services/api_client.dart';
import 'services/theme_provider.dart';
import 'services/notification_service.dart';
import 'services/fcm_service.dart';
import 'models/app_notification.dart';
import 'models/enums.dart';
import 'widgets/vital_notification_banner.dart';
import 'screens/main_shell.dart';
import 'screens/onboarding/splash_screen.dart';
import 'widgets/vital_shimmer.dart';

bool _splashShownThisRun = false;

class VitalGuardApp extends StatefulWidget {
  const VitalGuardApp({super.key});

  @override
  State<VitalGuardApp> createState() => _VitalGuardAppState();
}

class _VitalGuardAppState extends State<VitalGuardApp> {
  StreamSubscription<void>? _authSubscription;
  StreamSubscription? _fcmSubscription;
  NotificationService? _notificationService;
  FcmService? _fcmService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupAuthListener();
      _setupFcmListener();
    });
  }

  void _setupAuthListener() {
    final apiClient = context.read<ApiClient>();
    _authSubscription = apiClient.onUnauthorized.listen((_) {
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      }
    });
  }

  void _setupFcmListener() {
    try {
      _fcmService = context.read<FcmService>();
      _notificationService = context.read<NotificationService>();
      _fcmService!.setup();
      _notificationService!.startPolling();
      _fcmSubscription = _fcmService!.onMessage.listen(_handleFcmMessage);
    } catch (_) {}
  }

  void _handleFcmMessage(dynamic message) {
    if (!mounted) return;
    final data = message.data as Map<String, dynamic>?;
    if (data == null) return;

    final notification = AppNotification(
      id: int.tryParse(data['id'] ?? '0') ?? 0,
      title: data['title'] ?? 'Notificación',
      message: data['body'] ?? '',
      type: _parseNotificationType(data['type']),
    );

    if (!_shouldShowNotification(notification)) return;

    VitalNotificationBanner.show(
      context,
      notification: notification,
      onTap: () {
        final route = data['route'];
        if (route != null) {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }

  NotificationType _parseNotificationType(String? type) {
    switch (type) {
      case 'sos_alerta':
        return NotificationType.sosAlerta;
      case 'dosis_recordatorio':
        return NotificationType.dosisRecordatorio;
      case 'medicamento_solicitud':
        return NotificationType.medicamentoSolicitud;
      default:
        return NotificationType.sistema;
    }
  }

  bool _shouldShowNotification(AppNotification notification) {
    if (notification.type == NotificationType.sosAlerta) return true;
    return true;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _fcmSubscription?.cancel();
    _notificationService?.stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, _) {
        return MaterialApp(
          title: 'VitalGuard',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: theme.mode,
          home: Consumer<AuthService>(
            builder: (context, auth, _) {
              if (auth.isLoading) {
                return _buildSplashSkeleton();
              }

              if (!_splashShownThisRun) {
                _splashShownThisRun = true;
                return const SplashScreen();
              }

              if (auth.isLoggedIn) {
                if (!auth.isProfileComplete) {
                  return const _ProfileRedirect();
                }
                return const MainShell();
              }

              return const LoginRedirect();
            },
          ),
          onGenerateRoute: AppRoutes.onGenerateRoute,
        );
      },
    );
  }

  Widget _buildSplashSkeleton() {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SkeletonCircle(size: 72),
            const SizedBox(height: 20),
            const SkeletonLine(width: 180, height: 16),
            const SizedBox(height: 8),
            const SkeletonLine(width: 120, height: 12),
          ],
        ),
      ),
    );
  }
}

class LoginRedirect extends StatefulWidget {
  const LoginRedirect({super.key});

  @override
  State<LoginRedirect> createState() => _LoginRedirectState();
}

class _LoginRedirectState extends State<LoginRedirect> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('onboarding_seen') ?? false;
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        seen ? AppRoutes.login : AppRoutes.splash,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SkeletonLine(width: 180, height: 16),
      ),
    );
  }
}

class _ProfileRedirect extends StatelessWidget {
  const _ProfileRedirect();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, AppRoutes.completeProfile);
    });
    return const Scaffold(
      body: Center(
        child: SkeletonLine(width: 180, height: 16),
      ),
    );
  }
}
