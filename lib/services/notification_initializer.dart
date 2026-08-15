import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationInitializer {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    await _createNotificationChannel();
  }

  static Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'vitalguard_high_importance',
      'VitalGuard Notificaciones',
      description: 'Notificaciones importantes de VitalGuard',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      debugPrint('[LocalNotif] Notification tapped: $payload');
    }
  }

  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'vitalguard_high_importance',
        'VitalGuard Notificaciones',
        channelDescription: 'Notificaciones importantes de VitalGuard',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }
}
