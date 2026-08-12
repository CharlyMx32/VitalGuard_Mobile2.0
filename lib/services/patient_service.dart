import 'package:dio/dio.dart';
import 'api_client.dart';
import 'storage_service.dart';
import '../utils/json_utils.dart';
import '../models/patient.dart';
import '../models/enums.dart';

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
      return patients.firstWhere((p) => p.id == id, orElse: () => throw Exception('Paciente $id no encontrado en caché'));
    }
  }

  Future<Patient> createPatient(Patient patient, {KinshipType? kinship}) async {
    final data = patient.toJson();
    if (kinship != null) data['kinship'] = kinship.apiValue;
    final response = await _client.post('/patients', data: data);
    final normalized = normalizeJsonKeys(response.data) as Map<String, dynamic>;
    final saved = Patient.fromJson(normalized);
    final cached = await _loadCache();
    cached.add(saved);
    await _storage.savePatients(cached);
    _cached = cached;
    return saved;
  }

  Future<Patient> updatePatient(Patient patient) async {
    try {
      await _client.patch('/patients/${patient.id}', data: patient.toJson());
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

  Future<Patient> updatePatientFields(int id, Map<String, dynamic> fields) async {
    try {
      final response = await _client.patch('/patients/$id', data: fields);
      final normalized = normalizeJsonKeys(response.data) as Map<String, dynamic>;
      final updated = Patient.fromJson(normalized);
      final cached = await _loadCache();
      final idx = cached.indexWhere((p) => p.id == id);
      if (idx != -1) cached[idx] = updated;
      await _storage.savePatients(cached);
      _cached = cached;
      return updated;
    } on DioException {
      final cached = await _loadCache();
      return cached.firstWhere((p) => p.id == id, orElse: () => throw Exception('Paciente $id no encontrado en caché'));
    }
  }

  Future<void> deletePatient(int id) async {
    try {
      await _client.delete('/patients/$id');
    } on DioException {
      rethrow;
    }
    final cached = await _loadCache();
    cached.removeWhere((p) => p.id == id);
    await _storage.savePatients(cached);
    _cached = cached;
  }
}
