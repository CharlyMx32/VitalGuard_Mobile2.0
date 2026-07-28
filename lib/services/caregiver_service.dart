import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';
import 'storage_service.dart';
import '../models/caregiver.dart';

class CaregiverService extends ChangeNotifier {
  final ApiClient _client;
  final StorageService _storage;
  List<Caregiver>? _cached;

  CaregiverService(this._client, this._storage);

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

  Future<List<Caregiver>> _loadCache() async {
    if (_cached != null) return _cached!;
    final stored = await _storage.loadCaregivers();
    if (stored.isNotEmpty) {
      _cached = stored;
    } else {
      _cached = _defaults;
      await _storage.saveCaregivers(_cached!);
    }
    return _cached!;
  }

  Future<List<Caregiver>> getCaregivers(int patientId) async {
    try {
      final response = await _client.get('/caregivers/patient/$patientId');
      final normalized = _normalizeKeys(response.data) as List;
      final data = normalized
          .map((e) => Caregiver.fromJson(e as Map<String, dynamic>))
          .toList();
      _cached = data;
      await _storage.saveCaregivers(data);
      return data;
    } on DioException {
      return _loadCache();
    }
  }

  static final List<Caregiver> _defaults = [
    Caregiver(id: 1, appProfileId: 1, emergencyCallPriority: 1),
  ];
}
