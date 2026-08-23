import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import '../utils/navigator_key.dart';

class NotificationInitializer {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@drawable/ic_notification');
    const initSettings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    await _createNotificationChannel();
    // Registra acciones para invitaciones (Accept/Reject)
    await _createInvitationActions();
  }

  static Future<void> _createInvitationActions() async {
    // No necesario crear canal separado, las acciones se definen por notificación
  }

  @pragma('vm:entry-point')
  static void notificationTapBackground(NotificationResponse response) {
    _onNotificationResponse(response);
  }

  static Future<void> _createNotificationChannel() async {
    const channels = [
      AndroidNotificationChannel(
        'vitalguard_high_importance',
        'VitalGuard Notificaciones',
        description: 'Notificaciones generales de VitalGuard',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'vitalguard_sos',
        'VitalGuard SOS',
        description: 'Alertas críticas SOS - sonido y vibración máxima',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'vitalguard_invitations',
        'VitalGuard Invitaciones',
        description: 'Invitaciones para cuidar pacientes',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
        enableLights: true,
        ledColor: Color(0xFF4A90E2),
      ),
      AndroidNotificationChannel(
        'vitalguard_medication',
        'VitalGuard Medicación',
        description: 'Recordatorios de medicación',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      ),
    ];

    final plugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    for (final c in channels) {
      await plugin?.createNotificationChannel(c);
    }
  }

  static String _channelForData(Map<String, dynamic> data) {
    switch (data['type']) {
      case 'SOS_ALERTA':
        return 'vitalguard_sos';
      case 'INVITACION_CUIDADOR':
        return 'vitalguard_invitations';
      case 'DOSIS_RECORDATORIO':
        return 'vitalguard_medication';
      default:
        return 'vitalguard_high_importance';
    }
  }

  static void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    final actionId = response.actionId;
    debugPrint('[LocalNotif] tapped action=$actionId payload=$payload');
    if (payload == null) return;
    try {
      Map<String, dynamic> data;
      try {
        data = jsonDecode(payload) as Map<String, dynamic>;
      } catch (_) {
        data = {'raw': payload};
        // Intenta extraer JSON anidado si payload es toString de Map
        if (payload.contains('invitation_id')) {
          final match = RegExp(r'invitation_id:\s*(\d+)').firstMatch(payload);
          if (match != null) data['invitation_id'] = match.group(1);
        }
      }
      // Deep link via navigatorKey (funciona incluso con app cerrada)
      final navigator = appNavigatorKey.currentState;
      if (navigator == null) {
        debugPrint('[LocalNotif] navigator not ready');
        return;
      }
      final type = data['type']?.toString() ?? '';
      final route = data['route']?.toString() ?? '';
      final isInvite = type == 'INVITACION_CUIDADOR' || route == 'invitations' || data.containsKey('invitation_id');

      if (actionId == 'accept_invitation' || actionId == 'reject_invitation') {
        // Abre directamente Pendientes; el usuario confirma allí (evita HTTP en isolate)
        navigator.pushNamed('/invitations');
        return;
      }

      if (isInvite) {
        navigator.pushNamed('/invitations');
      } else if (type == 'SOS_ALERTA') {
        navigator.pushNamed('/sos-emergency');
      } else if (type == 'DOSIS_RECORDATORIO') {
        navigator.pushNamed('/schedule');
      } else if (route.isNotEmpty) {
        navigator.pushNamed('/$route');
      }
    } catch (e) {
      debugPrint('[LocalNotif] parse error $e');
    }
  }

  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    Map<String, dynamic>? data,
    int? id,
    String? tag,
  }) async {
    final channelId = data != null ? _channelForData(data) : 'vitalguard_high_importance';
    final isSos = data?['type'] == 'SOS_ALERTA';
    final isInvite = data?['type'] == 'INVITACION_CUIDADOR';
    // Tag para colapsar duplicados (invitación se actualiza en lugar de apilar)
    final notifTag = tag ??
        (isInvite && data?['invitationId'] != null
            ? 'invitation_${data!['invitationId']}'
            : isInvite && data?['id'] != null
                ? 'invitation_${data!['id']}'
                : null);

    // Acciones rápidas solo para invitaciones
    List<AndroidNotificationAction>? actions;
    if (isInvite) {
      actions = const [
        AndroidNotificationAction('accept_invitation', 'Aceptar',
            icon: DrawableResourceAndroidBitmap('@drawable/ic_notification'), showsUserInterface: true),
        AndroidNotificationAction('reject_invitation', 'Rechazar',
            icon: DrawableResourceAndroidBitmap('@drawable/ic_notification'), showsUserInterface: true, cancelNotification: true),
      ];
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelId == 'vitalguard_sos'
            ? 'VitalGuard SOS'
            : channelId == 'vitalguard_invitations'
                ? 'VitalGuard Invitaciones'
                : channelId == 'vitalguard_medication'
                    ? 'VitalGuard Medicación'
                    : 'VitalGuard Notificaciones',
        channelDescription: isSos ? 'Alerta crítica SOS' : 'Notificaciones importantes de VitalGuard',
        importance: isInvite || isSos ? Importance.max : Importance.high,
        priority: isInvite || isSos ? Priority.max : Priority.high,
        icon: '@drawable/ic_notification',
        color: const Color(0xFF4A90E2),
        enableVibration: true,
        playSound: true,
        styleInformation: BigTextStyleInformation(body),
        tag: notifTag,
        actions: actions,
        category: isInvite ? AndroidNotificationCategory.social : null,
        visibility: NotificationVisibility.public,
      ),
    );

    final notifId = id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
    // Si hay tag, usa mismo id para colapsar (Android tag+id colapsa)
    final effectiveId = isInvite && notifTag != null ? (int.tryParse(notifTag.replaceAll(RegExp(r'[^0-9]'), '')) ?? notifId) % 100000 : notifId;
    await _localNotifications.show(
      effectiveId,
      title,
      body,
      details,
      payload: payload,
    );
  }
}
