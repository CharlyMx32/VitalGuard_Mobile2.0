import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
import 'notification_service.dart';

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
    await _requestPermission();
    await _getToken();
    _setupForegroundListener();
    _setupOpenedAppListener();
    await _processPendingNotifications();
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
    _fcmToken = await messaging.getToken();
    debugPrint('[FCM] Token: $_fcmToken');
    if (_fcmToken != null) {
      await _registerToken(_fcmToken!);
    }
    messaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
      _registerToken(token);
    });
  }

  Future<void> _registerToken(String token) async {
    try {
      await _apiClient.post('/notifications/token', data: {'token': token});
      debugPrint('[FCM] Token registered with backend');
    } catch (e) {
      debugPrint('[FCM] Failed to register token: $e');
    }
  }

  void _setupForegroundListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FCM] Foreground message: ${message.notification?.title}');
      _messageController.add(message);
      _processNotificationData(message.data);
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

  void _processNotificationData(Map<String, dynamic> data) {
    final route = data['route'];
    if (route != null) {
      debugPrint('[FCM] Navigate to: $route');
    }
    _notificationService.getUnreadCount();
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
