import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';
import 'storage_service.dart';
import '../models/voice_message.dart';

class VoiceService extends ChangeNotifier {
  final ApiClient _client;
  final StorageService _storage;
  List<VoiceMessage>? _cached;

  VoiceService(this._client, this._storage);

  dynamic _normalizeKeys(dynamic value) {
    if (value is Map<String, dynamic>) {
      final result = <String, dynamic>{};
      value.forEach((key, val) {
        String camelKey = key.replaceAllMapped(
          RegExp(r'_([a-z])'),
          (match) => match.group(1)!.toUpperCase(),
        );
        result[camelKey] = _normalizeKeys(val);
      });
      return result;
    } else if (value is List) {
      return value.map((e) => _normalizeKeys(e)).toList();
    }
    return value;
  }

  Future<List<VoiceMessage>> _loadCache() async {
    if (_cached != null) return _cached!;
    final stored = await _storage.loadVoiceMessages();
    if (stored.isNotEmpty) {
      _cached = stored;
    } else {
      _cached = _defaults;
      await _storage.saveVoiceMessages(_cached!);
    }
    return _cached!;
  }

  Future<List<VoiceMessage>> getVoiceMessages(int patientId) async {
    try {
      final response = await _client.get('/voice-messages/patient/$patientId');
      final normalized = _normalizeKeys(response.data) as List;
      final data = normalized
          .map((e) => VoiceMessage.fromJson(e as Map<String, dynamic>))
          .toList();
      _cached = data;
      await _storage.saveVoiceMessages(data);
      return data;
    } on DioException {
      return _loadCache();
    }
  }

  static final List<VoiceMessage> _defaults = [
    VoiceMessage(
      id: 1,
      senderCaregiverId: 1,
      patientId: 1,
      audioFilePath: '/audio/msg_001.mp3',
      isPlayed: false,
      createdAt: null,
    ),
  ];
}
