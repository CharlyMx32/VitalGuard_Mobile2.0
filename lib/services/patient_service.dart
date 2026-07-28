import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';
import 'storage_service.dart';
import '../models/patient.dart';
import '../models/enums.dart';

class PatientService extends ChangeNotifier {
  final ApiClient _client;
  final StorageService _storage;
  List<Patient>? _cached;

  PatientService(this._client, this._storage);

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

  Future<List<Patient>> _loadCache() async {
    if (_cached != null) return _cached!;
    final stored = await _storage.loadPatients();
    if (stored.isNotEmpty) {
      _cached = stored;
    } else {
      _cached = _defaults;
      await _storage.savePatients(_cached!);
    }
    return _cached!;
  }

  Future<List<Patient>> getPatients() async {
    try {
      final response = await _client.get('/patients');
      final normalized = _normalizeKeys(response.data) as List;
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
      final normalized = _normalizeKeys(response.data) as Map<String, dynamic>;
      return Patient.fromJson(normalized);
    } on DioException {
      final patients = await _loadCache();
      return patients.firstWhere((p) => p.id == id);
    }
  }

  static final List<Patient> _defaults = [
    Patient(
      id: 1,
      firstName: 'María',
      paternalLastName: 'García',
      maternalLastName: 'López',
      birthDate: DateTime(1945, 3, 15),
      gender: GenderType.f,
      phone: '5551234567',
      address: 'Av. Siempre Viva 123, CDMX',
      bloodType: BloodType.oPositive,
      medicalNotes: 'Hipertensión controlada. Alergia a penicilina.',
    ),
    Patient(
      id: 2,
      firstName: 'José',
      paternalLastName: 'Martínez',
      maternalLastName: 'Hernández',
      birthDate: DateTime(1952, 7, 22),
      gender: GenderType.m,
      phone: '5559876543',
      bloodType: BloodType.aPositive,
      medicalNotes: 'Diabetes tipo 2. Artritis reumatoide.',
    ),
    Patient(
      id: 3,
      firstName: 'Ana',
      paternalLastName: 'Rodríguez',
      birthDate: DateTime(1960, 11, 8),
      gender: GenderType.f,
      phone: '5554567890',
      bloodType: BloodType.bPositive,
    ),
  ];
}
