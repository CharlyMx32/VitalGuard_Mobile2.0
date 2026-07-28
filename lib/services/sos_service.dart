import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/sos_event.dart';
import '../models/enums.dart';

class SosService extends ChangeNotifier {
  final ApiClient _client;

  SosService(this._client);

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

  Future<List<SosEvent>> getActiveSosEvents(int patientId) async {
    try {
      final response = await _client.get('/sos-events/active/$patientId');
      final normalized = _normalizeKeys(response.data) as List;
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
      final normalized = _normalizeKeys(response.data) as Map<String, dynamic>;
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
