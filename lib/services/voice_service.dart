import 'package:dio/dio.dart';
import 'api_client.dart';
import 'storage_service.dart';
import '../utils/json_utils.dart';
import '../models/voice_message.dart';

class VoiceService {
  final ApiClient _client;
  final StorageService _storage;
  List<VoiceMessage>? _cached;

  VoiceService(this._client, this._storage);

  Future<List<VoiceMessage>> _loadCache() async {
    if (_cached != null) return _cached!;
    _cached = await _storage.loadVoiceMessages();
    return _cached!;
  }

  Future<List<VoiceMessage>> getVoiceMessages(int patientId) async {
    try {
      final response = await _client.get('/voice-messages/patient/$patientId');
      final normalized = normalizeJsonKeys(response.data) as List;
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
}
