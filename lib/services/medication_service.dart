import 'package:dio/dio.dart';
import 'api_client.dart';
import 'storage_service.dart';
import '../utils/json_utils.dart';
import '../models/medication.dart';

class MedicationService {
  final ApiClient _client;
  final StorageService _storage;
  List<Medication>? _cached;

  MedicationService(this._client, this._storage);

  Future<List<Medication>> _loadCache() async {
    if (_cached != null) return _cached!;
    _cached = await _storage.loadMedications();
    return _cached!;
  }

  Future<List<Medication>> getMedications() async {
    try {
      final response = await _client.get('/medications');
      final normalized = normalizeJsonKeys(response.data) as List;
      final data = normalized
          .map((e) => Medication.fromJson(e as Map<String, dynamic>))
          .toList();
      _cached = data;
      await _storage.saveMedications(data);
      return data;
    } on DioException {
      return _loadCache();
    }
  }

  Future<List<Medication>> searchMedications(String query) async {
    final all = await getMedications();
    if (query.trim().isEmpty) return all;
    final q = query.trim().toLowerCase();
    return all
        .where((m) =>
            m.name.toLowerCase().contains(q) ||
            (m.presentation?.toLowerCase().contains(q) ?? false))
        .toList();
  }
}
