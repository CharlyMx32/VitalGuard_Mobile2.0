import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
import 'notification_service.dart';
import 'notification_initializer.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await _savePendingNotification(message);
}

Future<void> _savePendingNotification(RemoteMessage message) async {
  final prefs = await SharedPreferences.getInstance();
  final pending = prefs.getStringList('pending_notifications') ?? [];
  pending.add(jsonEncode(message.data));
  await prefs.setStringList('pending_notifications', pending);
}

class FcmService extends ChangeNotifier {
  final ApiClient _apiClient;
  final NotificationService _notificationService;
  String? _fcmToken;
  final StreamController<RemoteMessage> _messageController =
      StreamController<RemoteMessage>.broadcast();

  Stream<RemoteMessage> get onMessage => _messageController.stream;
  String? get fcmToken => _fcmToken;

  FcmService(this._apiClient, this._notificationService);

  static Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> setup() async {
    debugPrint('[FCM] setup() start isLoggedIn check');
    try {
      await _requestPermission();
    } catch (e) {
      debugPrint('[FCM] requestPermission error: $e');
    }
    try {
      await _getToken();
    } catch (e) {
      debugPrint('[FCM] _getToken error: $e');
    }
    _setupForegroundListener();
    _setupOpenedAppListener();
    await _setupInitialMessage();
    await _processPendingNotifications();
    debugPrint('[FCM] setup() done token=${_fcmToken?.substring(0, 10) ?? 'null'}');
  }

  Future<void> ensureTokenRegistered() async {
    if (_fcmToken != null) {
      await _registerToken(_fcmToken!);
    } else {
      await _getToken();
    }
  }

  Future<void> _setupInitialMessage() async {
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      debugPrint('[FCM] Initial message (killed): ${initial.notification?.title}');
      _messageController.add(initial);
      _processNotificationData(initial.data);
    }
  }

  Future<void> _requestPermission() async {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: true,
    );
    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');
  }

  Future<void> _getToken() async {
    final messaging = FirebaseMessaging.instance;
    try {
      _fcmToken = await messaging.getToken().timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('[FCM] getToken timeout/error: $e');
      // retry once after 2s
      await Future.delayed(const Duration(seconds: 2));
      try {
        _fcmToken = await messaging.getToken().timeout(const Duration(seconds: 10));
      } catch (e2) {
        debugPrint('[FCM] getToken retry failed: $e2');
      }
    }
    debugPrint('[FCM] Token: ${_fcmToken != null ? '${_fcmToken!.substring(0, 20)}...' : 'null'}');
    if (_fcmToken != null) {
      await _registerToken(_fcmToken!);
    } else {
      debugPrint('[FCM] No token available, will retry on next setup()');
    }
    messaging.onTokenRefresh.listen((token) {
      debugPrint('[FCM] onTokenRefresh: ${token.substring(0, 20)}...');
      _fcmToken = token;
      _registerToken(token);
    });
  }

  Future<String?> _getStoredEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('vitalguard_user');
      if (userJson != null) {
        final map = jsonDecode(userJson) as Map<String, dynamic>;
        final email = map['email'] as String?;
        if (email != null && email.trim().isNotEmpty) return email.trim();
      }
    } catch (_) {}
    return null;
  }

  Future<void> _registerToken(String token) async {
    try {
      final email = await _getStoredEmail();
      await _apiClient.post('/notifications/token', data: {
        'token': token,
        'platform': Platform.isAndroid ? 'android' : Platform.isIOS ? 'ios' : 'unknown',
        if (email != null) 'email': email,
      });
      debugPrint('[FCM] Token registered with backend email=${email ?? '-'}');
    } catch (e) {
      debugPrint('[FCM] Failed to register token: $e');
    }
  }

  void _setupForegroundListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final title = message.notification?.title ?? message.data['title'] ?? 'VitalGuard';
      final body = message.notification?.body ?? message.data['body'] ?? '';
      debugPrint('[FCM] Foreground message: $title');

      // Muestra banner local incluso con app abierta (UX crítica para SOS/invitaciones)
      final notifId = int.tryParse(message.data['id']?.toString() ?? '');
      await NotificationInitializer.showLocalNotification(
        title: title,
        body: body.isNotEmpty ? body : 'Tienes una nueva notificación',
        payload: jsonEncode(message.data),
        id: notifId,
        data: message.data,
      );

      _messageController.add(message);
      await _processNotificationData(message.data);
    });
  }

  void _setupOpenedAppListener() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM] App opened from notification: ${message.notification?.title}');
      _processNotificationData(message.data);
    });
  }

  Future<void> _processPendingNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final pending = prefs.getStringList('pending_notifications') ?? [];
    if (pending.isNotEmpty) {
      for (final item in pending) {
        final data = jsonDecode(item) as Map<String, dynamic>;
        _messageController.add(RemoteMessage(data: data));
      }
      await prefs.setStringList('pending_notifications', []);
    }
  }

  Future<void> _processNotificationData(Map<String, dynamic> data) async {
    final route = data['route']?.toString();
    final type = data['type']?.toString();
    if (route != null && route.isNotEmpty) {
      debugPrint('[FCM] Navigate to: $route type=$type patientId=${data['patientId']} invitationId=${data['invitationId']}');
    }
    // Refresca contador y lista para mostrar badge y card al instante
    try {
      await _notificationService.refresh();
    } catch (_) {
      await _notificationService.getUnreadCount();
    }
    if (type == 'INVITACION_CUIDADOR') {
      debugPrint('[FCM] Nueva invitación recibida - refrescando');
    }
  }

  Future<void> deleteToken() async {
    await FirebaseMessaging.instance.deleteToken();
    _fcmToken = null;
  }

  @override
  void dispose() {
    _messageController.close();
    super.dispose();
  }
}
