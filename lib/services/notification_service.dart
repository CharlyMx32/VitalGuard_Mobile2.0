import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_client.dart';
import '../models/app_notification.dart';
import '../utils/json_utils.dart';

class NotificationService extends ChangeNotifier {
  final ApiClient _client;
  List<AppNotification>? _cached;
  int _unreadCount = 0;
  Timer? _pollTimer;

  NotificationService(this._client);

  int get unreadCount => _unreadCount;

  Future<List<AppNotification>> getNotifications() async {
    try {
      final response = await _client.get('/notifications');
      final normalized = normalizeJsonKeys(response.data) as List;
      final data = normalized
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
      _cached = data;
      _updateUnreadCount();
      return data;
    } on DioException {
      return _cached ?? [];
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _client.get('/notifications/unread-count');
      final data = response.data as Map<String, dynamic>;
      _unreadCount = data['count'] as int? ?? 0;
      notifyListeners();
      return _unreadCount;
    } on DioException {
      return _unreadCount;
    }
  }

  void _updateUnreadCount() {
    if (_cached != null) {
      _unreadCount = _cached!.where((n) => !n.isRead).length;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _client.patch('/notifications/$id/read');
      if (_cached != null) {
        final idx = _cached!.indexWhere((n) => n.id == id);
        if (idx != -1) {
          final old = _cached![idx];
          _cached![idx] = AppNotification(
            id: old.id,
            title: old.title,
            message: old.message,
            type: old.type,
            isRead: true,
            patient: old.patient,
            createdAt: old.createdAt,
          );
          _updateUnreadCount();
        }
      }
    } on DioException {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _client.patch('/notifications/read-all');
      if (_cached != null) {
        _cached = _cached!.map((n) => AppNotification(
          id: n.id,
          title: n.title,
          message: n.message,
          type: n.type,
          isRead: true,
          patient: n.patient,
          createdAt: n.createdAt,
        )).toList();
        _updateUnreadCount();
      }
    } on DioException {}
  }

  void startPolling({Duration interval = const Duration(seconds: 30)}) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(interval, (_) => getUnreadCount());
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
