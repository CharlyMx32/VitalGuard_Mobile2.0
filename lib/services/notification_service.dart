import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_client.dart';
import '../models/app_notification.dart';
import '../utils/json_utils.dart';
import 'notification_initializer.dart';

class NotificationService extends ChangeNotifier {
  final ApiClient _client;
  List<AppNotification>? _cached;
  int _unreadCount = 0;
  Timer? _pollTimer;
  final StreamController<AppNotification> _realtimeController =
      StreamController<AppNotification>.broadcast();

  Stream<AppNotification> get onRealtimeNotification => _realtimeController.stream;

  NotificationService(this._client);

  int get unreadCount => _unreadCount;

  Future<List<AppNotification>> getNotifications() async {
    try {
      final response = await _client.get('/notifications');
      final normalized = normalizeJsonKeys(response.data) as List;
      final data = normalized
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
      // Detecta nuevas notificaciones no leídas para mostrar banner aunque WS/FCM fallen
      if (_cached != null) {
        final oldIds = _cached!.map((n) => n.id).toSet();
        for (final n in data) {
          if (!oldIds.contains(n.id) && !n.isRead) {
            debugPrint('[Notif] Nueva notificación detectada vía polling: ${n.id} ${n.title}');
            if (!_realtimeController.isClosed) _realtimeController.add(n);
            // Muestra notificación local como fallback
            try {
              await NotificationInitializer.showLocalNotification(
                title: n.title,
                body: n.message,
                id: n.id,
                data: {'type': n.type.apiValue, 'id': '${n.id}'},
              );
            } catch (_) {}
          }
        }
      } else {
        // Primera carga: si hay no leídas, también notifica la más reciente
        for (final n in data.where((x) => !x.isRead).take(1)) {
          if (!_realtimeController.isClosed) _realtimeController.add(n);
        }
      }
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

  // ── Realtime helpers ──
  void setUnreadCount(int count) {
    if (_unreadCount != count) {
      _unreadCount = count;
      notifyListeners();
    }
  }

  void addRealtimeNotification(AppNotification notif) {
    _cached ??= [];
    // evita duplicados
    if (_cached!.any((n) => n.id == notif.id)) return;
    _cached!.insert(0, notif);
    _updateUnreadCount();
    if (!_realtimeController.isClosed) _realtimeController.add(notif);
  }

  void syncFromRealtime(List<AppNotification> list) {
    _cached = list;
    _updateUnreadCount();
  }

  void markLocalAsRead(int id) {
    if (_cached == null) return;
    final idx = _cached!.indexWhere((n) => n.id == id);
    if (idx != -1 && !_cached![idx].isRead) {
      final old = _cached![idx];
      _cached![idx] = AppNotification(
        id: old.id,
        title: old.title,
        message: old.message,
        type: old.type,
        isRead: true,
        patient: old.patient,
        createdAt: old.createdAt,
        metadata: old.metadata,
      );
      _updateUnreadCount();
    }
  }

  void markLocalAllAsRead() {
    if (_cached == null) {
      _unreadCount = 0;
      notifyListeners();
      return;
    }
    _cached = _cached!.map((n) {
      if (!n.isRead) {
        return AppNotification(
          id: n.id,
          title: n.title,
          message: n.message,
          type: n.type,
          isRead: true,
          patient: n.patient,
          createdAt: n.createdAt,
          metadata: n.metadata,
        );
      }
      return n;
    }).toList();
    _unreadCount = 0;
    notifyListeners();
  }

  /// Refresca lista + contador (llamado tras push FCM)
  Future<void> refresh() async {
    await getNotifications();
    await getUnreadCount();
  }

  Future<void> markAsRead(int id) async {
    // Optimistic local update first for instant UI feedback
    bool patchedLocal = false;
    if (_cached != null) {
      final idx = _cached!.indexWhere((n) => n.id == id);
      if (idx != -1 && !_cached![idx].isRead) {
        final old = _cached![idx];
        _cached![idx] = AppNotification(
          id: old.id,
          title: old.title,
          message: old.message,
          type: old.type,
          isRead: true,
          patient: old.patient,
          createdAt: old.createdAt,
          metadata: old.metadata,
        );
        _updateUnreadCount();
        patchedLocal = true;
      }
    }
    try {
      await _client.patch('/notifications/$id/read');
      // Ensure server state is reflected (re-apply in case local was not patched)
      if (!patchedLocal) {
        await getNotifications();
      }
    } on DioException catch (e) {
      debugPrint('[Notif] markAsRead failed ${e.response?.statusCode}, keeping optimistic local state');
      // keep optimistic change, don't revert
    }
  }

  Future<void> markAllAsRead() async {
    // Optimistic: immediately clear badge
    if (_cached != null) {
      _cached = _cached!.map((n) => AppNotification(
        id: n.id,
        title: n.title,
        message: n.message,
        type: n.type,
        isRead: true,
        patient: n.patient,
        createdAt: n.createdAt,
        metadata: n.metadata,
      )).toList();
      _unreadCount = 0;
      notifyListeners();
    } else {
      _unreadCount = 0;
      notifyListeners();
    }
    try {
      await _client.patch('/notifications/read-all');
      // Re-sync to ensure server state matches
      await getNotifications();
      await getUnreadCount();
    } on DioException catch (e) {
      debugPrint('[Notif] markAllAsRead failed ${e.response?.statusCode}, keeping optimistic 0');
      // keep optimistic 0, don't revert
    }
  }

  void startPolling({Duration interval = const Duration(seconds: 30)}) {
    _pollTimer?.cancel();
    // Primer tick refresca lista + contador para invitaciones por email
    _pollTimer = Timer.periodic(interval, (_) async {
      await getUnreadCount();
      // Cada 2 ticks refresca lista completa (no solo contador) para no perder invitaciones lazy
      await getNotifications();
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _realtimeController.close();
    super.dispose();
  }
}
