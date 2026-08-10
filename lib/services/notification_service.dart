import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/app_notification.dart';
import '../utils/json_utils.dart';

class NotificationService {
  final ApiClient _client;
  List<AppNotification>? _cached;

  NotificationService(this._client);

  Future<List<AppNotification>> getNotifications() async {
    try {
      final response = await _client.get('/notifications');
      final normalized = normalizeJsonKeys(response.data) as List;
      final data = normalized
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
      _cached = data;
      return data;
    } on DioException {
      return _cached ?? [];
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
      }
    } on DioException {}
  }
}
