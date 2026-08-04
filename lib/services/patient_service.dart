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

  Future<Patient> createPatient(Patient patient) async {
    try {
      final response = await _client.post('/patients', data: patient.toJson());
      final normalized = normalizeJsonKeys(response.data) as Map<String, dynamic>;
      final saved = Patient.fromJson(normalized);
      final cached = await _loadCache();
      cached.add(saved);
      await _storage.savePatients(cached);
      _cached = cached;
      return saved;
    } on DioException {
      final cached = await _loadCache();
      cached.add(patient);
      await _storage.savePatients(cached);
      _cached = cached;
      return patient;
    }
  }

  Future<Patient> updatePatient(Patient patient) async {
    try {
      await _client.put('/patients/${patient.id}', data: patient.toJson());
    } on DioException {
      // persistir localmente si el backend no esta disponible
    }
    final cached = await _loadCache();
    final idx = cached.indexWhere((p) => p.id == patient.id);
    if (idx != -1) {
      cached[idx] = patient;
    } else {
      cached.add(patient);
    }
    await _storage.savePatients(cached);
    _cached = cached;
    return patient;
  }
}
