import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'routes/app_routes.dart';
import 'services/auth_service.dart';
import 'services/api_client.dart';
import 'services/notification_service.dart';
import 'services/fcm_service.dart';
import 'services/realtime_service.dart';
import 'services/invitation_service.dart';
import 'models/app_notification.dart';
import 'utils/navigator_key.dart';
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
  StreamSubscription<AppNotification>? _realtimeSub;
  StreamSubscription<Map<String, dynamic>>? _invitationSub;
  NotificationService? _notificationService;
  FcmService? _fcmService;
  final Set<int> _shownIds = {};

  BuildContext get _overlayContext => appNavigatorKey.currentContext ?? context;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupAuthListener();
      _setupFcmListener();
      _setupRealtimeListener();
    });
  }

  void _setupAuthListener() {
    final apiClient = context.read<ApiClient>();
    final auth = context.read<AuthService>();
    _authSubscription = apiClient.onUnauthorized.listen((_) async {
      await auth.logout();
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
      final auth = context.read<AuthService>();
      // Setup inicial (intenta registrar token aunque aún no esté logueado, reintentará tras login)
      _fcmService!.setup();
      _notificationService!.startPolling();
      _fcmSubscription = _fcmService!.onMessage.listen(_handleFcmMessage);
      // Re-registra token tras login (fix race: invitación llega antes que token)
      // Escucha cambios de AuthService para asegurar POST /notifications/token con email
      auth.addListener(() async {
        if (auth.isLoggedIn) {
          // Pequeño delay para que SharedPreferences ya tenga vitalguard_user con email
          await Future.delayed(const Duration(milliseconds: 500));
          try {
            await _fcmService!.ensureTokenRegistered();
          } catch (_) {
            await _fcmService!.setup();
          }
          _notificationService!.refresh();
        }
      });
      // Si ya está logueado en el primer frame, fuerza registro inmediato
      if (auth.isLoggedIn) {
        Future.delayed(const Duration(seconds: 1), () => _fcmService!.ensureTokenRegistered());
      }
    } catch (e) {
      debugPrint('[App] _setupFcmListener error: $e');
    }
  }

  void _setupRealtimeListener() {
    try {
      // RealtimeService se inicializa automáticamente con el token; aquí solo escuchamos banners
      final notif = context.read<NotificationService>();
      _realtimeSub = notif.onRealtimeNotification.listen((n) async {
        // dedup: FCM + WS pueden emitir mismo id
        if (n.id != 0 && _shownIds.contains(n.id)) return;
        if (n.id != 0) {
          _shownIds.add(n.id);
          // evita crecimiento infinito
          if (_shownIds.length > 200) _shownIds.clear();
        }
        if (!await _shouldShowNotification(n)) return;
        if (!mounted) return;
        final ctx = _overlayContext;
        if (ctx.mounted) {
          VitalNotificationBanner.show(
            ctx,
            notification: n,
            onTap: () {
              final target = _routeFor(n.type);
              if (target != null) Navigator.pushNamed(ctx, target);
            },
          );
        }
      });
      // Invitaciones por email vía WS: fuerza GET /invitations/pending?email= para que el backend cree la fila notifications
      final realtime = context.read<RealtimeService>();
      final invitationService = context.read<InvitationService>();
      _invitationSub = realtime.onInvitation.listen((data) async {
        try {
          // Este GET dispara la creación lazy de notifications en el backend (findPending)
          await invitationService.getPending();
          await notif.refresh();
        } catch (_) {}
        if (!mounted) return;
        final patientName = data['patient_name']?.toString() ?? 'un paciente';
        final n = AppNotification(
          id: (data['invitation_id'] as int?) ?? 0,
          title: 'Nueva invitación',
          message: 'Has sido invitado a cuidar a $patientName',
          type: NotificationType.invitacionCuidador,
        );
        if (!await _shouldShowNotification(n)) return;
        if (!mounted) return;
        final ctx = _overlayContext;
        if (ctx.mounted) {
          VitalNotificationBanner.show(
            ctx,
            notification: n,
            onTap: () => Navigator.pushNamed(ctx, AppRoutes.pendingInvitations),
          );
        }
      });
      // También asegura que RealtimeService esté instanciado (lazy)
      context.read<RealtimeService>();
    } catch (_) {}
  }

  Future<void> _handleFcmMessage(dynamic message) async {
    if (!mounted) return;
    final data = message.data as Map<String, dynamic>?;
    if (data == null) return;

    final notification = AppNotification(
      id: int.tryParse(data['id'] ?? '0') ?? 0,
      title: data['title'] ?? 'Notificación',
      message: data['body'] ?? '',
      type: _parseNotificationType(data['type']),
    );
    if (notification.id != 0 && _shownIds.contains(notification.id)) return;
    if (notification.id != 0) _shownIds.add(notification.id);

    if (!await _shouldShowNotification(notification)) return;
    if (!mounted) return;

    final ctx = _overlayContext;
    if (!ctx.mounted) return;
    VitalNotificationBanner.show(
      ctx,
      notification: notification,
      onTap: () {
        final target = _routeFor(notification.type);
        if (target != null) {
          Navigator.pushNamed(ctx, target);
        }
      },
    );
  }

  String? _routeFor(NotificationType type) {
    switch (type) {
      case NotificationType.invitacionCuidador:
        return AppRoutes.pendingInvitations;
      case NotificationType.dosisRecordatorio:
        return AppRoutes.schedule;
      case NotificationType.sosAlerta:
        return AppRoutes.sosEmergency;
      case NotificationType.medicamentoSolicitud:
      case NotificationType.sistema:
        return null;
    }
  }

  NotificationType _parseNotificationType(String? type) {
    switch (type) {
      case 'sos_alerta':
        return NotificationType.sosAlerta;
      case 'dosis_recordatorio':
        return NotificationType.dosisRecordatorio;
      case 'medicamento_solicitud':
        return NotificationType.medicamentoSolicitud;
      case 'INVITACION_CUIDADOR':
        return NotificationType.invitacionCuidador;
      case 'DOSIS_RECORDATORIO':
        return NotificationType.dosisRecordatorio;
      case 'SOS_ALERTA':
        return NotificationType.sosAlerta;
      case 'MEDICAMENTO_SOLICITUD':
        return NotificationType.medicamentoSolicitud;
      case 'SISTEMA':
        return NotificationType.sistema;
      default:
        return NotificationType.fromApi(type ?? '');
    }
  }

  Future<bool> _shouldShowNotification(AppNotification notification) async {
    final prefs = await SharedPreferences.getInstance();

    // SOS tiene lógica propia: respeta notif_emergency pero ignora DND y notif_general
    if (notification.type == NotificationType.sosAlerta) {
      return prefs.getBool('notif_emergency') ?? true;
    }

    // Master switch: si generales off, nada (excepto SOS ya retornado)
    final general = prefs.getBool('notif_general') ?? true;
    if (!general) return false;

    // No molestar 22:00-07:00 (no afecta SOS que ya retornó)
    final dnd = prefs.getBool('notif_dnd') ?? false;
    if (dnd) {
      final hour = DateTime.now().hour;
      if (hour >= 22 || hour < 7) return false;
    }

    switch (notification.type) {
      case NotificationType.dosisRecordatorio:
        return prefs.getBool('notif_doses') ?? true;
      case NotificationType.medicamentoSolicitud:
        // Solicitud de medicamento la tratamos como recordatorio
        return prefs.getBool('notif_reminders') ?? false ? true : (prefs.getBool('notif_general') ?? true);
      case NotificationType.invitacionCuidador:
        return prefs.getBool('notif_general') ?? true;
      case NotificationType.sistema:
        return prefs.getBool('notif_reminders') ?? true;
      case NotificationType.sosAlerta:
        return prefs.getBool('notif_emergency') ?? true;
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _fcmSubscription?.cancel();
    _realtimeSub?.cancel();
    _invitationSub?.cancel();
    _notificationService?.stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: 'VitalGuard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
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
