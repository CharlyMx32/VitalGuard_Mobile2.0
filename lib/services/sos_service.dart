import 'package:dio/dio.dart';
import 'api_client.dart';
import '../utils/json_utils.dart';
import '../models/sos_event.dart';
import '../models/enums.dart';

class SosService {
  final ApiClient _client;

  SosService(this._client);

  Future<List<SosEvent>> getActiveSosEvents(int patientId) async {
    try {
      final response = await _client.get('/sos-events/active/$patientId');
      final normalized = normalizeJsonKeys(response.data) as List;
      return normalized
          .map((e) => SosEvent.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException {
      return [];
    }
  }

  Future<SosEvent> createSosEvent(int patientId) async {
    try {
      final response =
          await _client.post('/sos-events', data: {'patientId': patientId});
      final normalized = normalizeJsonKeys(response.data) as Map<String, dynamic>;
      return SosEvent.fromJson(normalized);
    } on DioException {
      return SosEvent(
        id: DateTime.now().millisecondsSinceEpoch,
        patientId: patientId,
        status: SosStatus.activo,
        createdAt: DateTime.now(),
      );
    }
  }
}
