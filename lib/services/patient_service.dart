import 'package:dio/dio.dart';
import 'api_client.dart';
import 'storage_service.dart';
import '../utils/json_utils.dart';
import '../models/patient.dart';

class PatientService {
  final ApiClient _client;
  final StorageService _storage;
  List<Patient>? _cached;

  PatientService(this._client, this._storage);

  Future<List<Patient>> _loadCache() async {
    if (_cached != null) return _cached!;
    _cached = await _storage.loadPatients();
    return _cached!;
  }

  Future<List<Patient>> getPatients() async {
    try {
      final response = await _client.get('/patients');
      final normalized = normalizeJsonKeys(response.data) as List;
      final data = normalized
          .map((e) => Patient.fromJson(e as Map<String, dynamic>))
          .toList();
      _cached = data;
      await _storage.savePatients(data);
      return data;
    } on DioException {
      return _loadCache();
    }
  }

  Future<Patient> getPatient(int id) async {
    try {
      final response = await _client.get('/patients/$id');
      final normalized = normalizeJsonKeys(response.data) as Map<String, dynamic>;
      return Patient.fromJson(normalized);
    } on DioException {
      final patients = await _loadCache();
      return patients.firstWhere((p) => p.id == id);
    }
  }
}
