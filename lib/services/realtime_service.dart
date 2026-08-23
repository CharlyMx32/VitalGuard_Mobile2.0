import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config.dart';
import '../models/app_notification.dart';
import '../models/enums.dart';
import 'auth_service.dart';
import 'notification_service.dart';
import 'notification_initializer.dart';

class RealtimeService extends ChangeNotifier {
  final AuthService _auth;
  final NotificationService _notifications;
  io.Socket? _socket;
  bool _connected = false;
  Timer? _reconnectTimer;
  String? _lastToken;
  final StreamController<Map<String, dynamic>> _invitationController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onInvitation => _invitationController.stream;

  bool get isConnected => _connected;

  RealtimeService(this._auth, this._notifications) {
    _auth.addListener(_onAuthChanged);
    if (_auth.isLoggedIn) _connect();
  }

  void _onAuthChanged() {
    final token = _auth.token;
    if (token == null || token.isEmpty) {
      disconnect();
      return;
    }
    if (token != _lastToken) {
      _reconnect();
    }
  }

  void _reconnect() {
    disconnect();
    _connect();
  }

  void _connect() {
    final token = _auth.token;
    if (token == null || token.isEmpty) {
      debugPrint('[Realtime] No token, skip connect');
      return;
    }
    _lastToken = token;

    final apiUrl = AppConfig.apiBaseUrl;
    final socketUrl = apiUrl.endsWith('/') ? apiUrl.substring(0, apiUrl.length - 1) : apiUrl;

    debugPrint('[Realtime] Connecting to $socketUrl/realtime token=${token.substring(0, 10)}... apiUrl=$apiUrl');

    _connectWithUrl('$socketUrl/realtime', token);
  }

  void _connectWithUrl(String url, String token) {
    try {
      _socket?.dispose();
      // Fallback: si es emulador Android y api es https, permite http local
      _socket = io.io(
        url,
        io.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableForceNew()
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(10)
            .setReconnectionDelay(2000)
            .setReconnectionDelayMax(10000)
            .setTimeout(20000)
            .setAuth({'token': token})
            .setQuery({'token': token})
            .build(),
      );

      _socket!.onConnect((_) {
        _connected = true;
        debugPrint('[Realtime] ✓ Connected id=${_socket!.id}');
        notifyListeners();
      });

      _socket!.onDisconnect((_) {
        _connected = false;
        debugPrint('[Realtime] ✕ Disconnected');
        notifyListeners();
      });

      _socket!.onConnectError((err) {
        debugPrint('[Realtime] Connect error: $err url=$url');
        // No fallback a IP directa (puerto 3001 bloqueado, solo 443 vía Nginx). Reintenta con polling/FCM.
        final errStr = err.toString();
        if (errStr.contains('timeout')) {
          debugPrint('[Realtime] Timeout, reintentará automáticamente + polling cada 30s');
        }
        if (errStr.contains('Failed host lookup')) {
          debugPrint('[Realtime] DNS fail para $url, verifica que api.vitalguard.app resuelva y Nginx proxyee /socket.io/');
        }
      });

      _socket!.onError((err) {
        debugPrint('[Realtime] Error: $err url=$url');
      });

      // --- Eventos del backend (src/modules/realtime/realtime.gateway.ts) ---
      _socket!.on('connected', (data) {
        debugPrint('[Realtime] Server ack: $data');
      });

      _socket!.on('notification:new', (data) {
        debugPrint('[Realtime] notification:new $data');
        _handleNewNotification(data);
      });

      _socket!.on('notification:sync', (data) {
        debugPrint('[Realtime] notification:sync ${data is List ? data.length : data}');
        if (data is List) _handleSync(data);
      });

      _socket!.on('notification:unread-count', (data) {
        final count = data is Map ? (data['count'] as int? ?? 0) : 0;
        debugPrint('[Realtime] unread-count $count');
        _notifications.setUnreadCount(count);
      });

      _socket!.on('notification:read', (data) {
        final id = data is Map ? (data['id'] as int? ?? int.tryParse('${data['id']}')) : null;
        if (id != null) _notifications.markLocalAsRead(id);
      });

      _socket!.on('notification:read-all', (_) {
        _notifications.markLocalAllAsRead();
      });

      // Invitaciones por email: el backend emite a la sala email:<correo>
      _socket!.on('invitation:new', (data) async {
        debugPrint('[Realtime] invitation:new $data');
        if (data is Map) {
          final map = Map<String, dynamic>.from(data);
          if (!_invitationController.isClosed) _invitationController.add(map);
        }
        // No mostramos notificación local aquí para evitar duplicado con notification:new
        // Solo refresca para que el backend cree la fila y el siguiente poll/WS muestre la detallada
        try {
          await _notifications.refresh();
        } catch (e) {
          debugPrint('[Realtime] invitation:new handler error: $e');
        }
      });

      _socket!.connect();
    } catch (e) {
      debugPrint('[Realtime] Failed to create socket: $e');
    }
  }

  Future<void> _handleNewNotification(dynamic raw) async {
    try {
      Map<String, dynamic> json;
      if (raw is Map) {
        json = Map<String, dynamic>.from(raw);
      } else {
        return;
      }
      final notif = AppNotification.fromJson(json);
      _notifications.addRealtimeNotification(notif);

      // Usa invitation_id como ID/tag para colapsar duplicados (invitation:new + notification:new)
      final meta = json['metadata'] as Map<String, dynamic>?;
      final invId = meta?['invitation_id']?.toString() ?? json['invitation_id']?.toString();
      final effectiveId = invId != null ? (int.tryParse(invId) ?? notif.id) % 100000 : notif.id;
      final tag = notif.type == NotificationType.invitacionCuidador && invId != null ? 'invitation_$invId' : null;

      await NotificationInitializer.showLocalNotification(
        title: notif.title,
        body: notif.message,
        payload: jsonEncode(json),
        id: effectiveId,
        tag: tag,
        data: {
          'type': json['type']?.toString() ?? '',
          'id': '${notif.id}',
          'invitationId': invId ?? '',
          'invitation_id': invId ?? '',
        },
      );
    } catch (e) {
      debugPrint('[Realtime] parse error: $e raw=$raw');
      _notifications.refresh();
    }
  }

  void _handleSync(List data) {
    try {
      final list = data
          .whereType<Map>()
          .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      _notifications.syncFromRealtime(list);
    } catch (e) {
      debugPrint('[Realtime] sync parse error: $e');
    }
  }

  /// Solicita re-sync manual al servidor
  void requestSync() {
    _socket?.emit('notification:sync', {});
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _socket?.off('connected');
    _socket?.off('notification:new');
    _socket?.off('notification:sync');
    _socket?.off('notification:unread-count');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _connected = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    _invitationController.close();
    disconnect();
    super.dispose();
  }
}
