import 'package:dio/dio.dart';
import 'api_client.dart';
import 'storage_service.dart';
import '../utils/json_utils.dart';
import '../models/caregiver.dart';

class CaregiverService {
  final ApiClient _client;
  final StorageService _storage;
  List<Caregiver>? _cached;

  CaregiverService(this._client, this._storage);

  Future<List<Caregiver>> _loadCache() async {
    if (_cached != null) return _cached!;
    _cached = await _storage.loadCaregivers();
    return _cached!;
  }

  Future<List<Caregiver>> getCaregivers(int patientId) async {
    try {
      final response = await _client.get('/caregivers/patient/$patientId');
      final normalized = normalizeJsonKeys(response.data) as List;
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
}
