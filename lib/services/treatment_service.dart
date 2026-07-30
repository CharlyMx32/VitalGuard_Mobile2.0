import 'package:dio/dio.dart';
import 'api_client.dart';
import 'storage_service.dart';
import '../utils/json_utils.dart';
import '../models/treatment.dart';
import '../models/medication.dart';
import '../models/enums.dart';

class TreatmentService {
  final ApiClient _client;
  final StorageService _storage;
  List<Treatment>? _cachedTreatments;
  List<Schedule>? _cachedSchedules;
  List<MedicationLog>? _cachedLogs;

  TreatmentService(this._client, this._storage);

  Future<List<Treatment>> _loadTreatmentsCache() async {
    if (_cachedTreatments != null) return _cachedTreatments!;
    _cachedTreatments = await _storage.loadTreatments();
    return _cachedTreatments!;
  }

  Future<List<Schedule>> _loadSchedulesCache() async {
    if (_cachedSchedules != null) return _cachedSchedules!;
    _cachedSchedules = await _storage.loadSchedules();
    return _cachedSchedules!;
  }

  Future<List<MedicationLog>> _loadLogsCache() async {
    if (_cachedLogs != null) return _cachedLogs!;
    _cachedLogs = await _storage.loadLogs();
    return _cachedLogs!;
  }

  Future<List<Treatment>> getTreatments(int patientId) async {
    try {
      final response = await _client.get('/treatments/patient/$patientId');
      final normalized = normalizeJsonKeys(response.data) as List;
      final data = normalized
          .map((e) => Treatment.fromJson(e as Map<String, dynamic>))
          .toList();
      _cachedTreatments = data;
      await _storage.saveTreatments(data);
      return data;
    } on DioException {
      final treatments = await _loadTreatmentsCache();
      return treatments.where((t) => t.patientId == patientId).toList();
    }
  }

  Future<Treatment> getActiveTreatment(int patientId) async {
    try {
      final response = await _client.get('/treatments/active/$patientId');
      final normalized = normalizeJsonKeys(response.data) as Map<String, dynamic>;
      return Treatment.fromJson(normalized);
    } on DioException {
      final treatments = await _loadTreatmentsCache();
      return treatments.firstWhere(
        (t) => t.patientId == patientId && t.status == TreatmentStatus.activo,
      );
    }
  }

  Future<List<Schedule>> getTodaySchedules(int patientId) async {
    try {
      final response = await _client.get('/schedules/today/$patientId');
      final normalized = normalizeJsonKeys(response.data) as List;
      final data = normalized
          .map((e) => Schedule.fromJson(e as Map<String, dynamic>))
          .toList();
      _cachedSchedules = data;
      await _storage.saveSchedules(data);
      return data;
    } on DioException {
      return _loadSchedulesCache();
    }
  }

  Future<List<MedicationLog>> getRecentLogs(int patientId) async {
    try {
      final response = await _client.get('/medication-logs/recent/$patientId');
      final normalized = normalizeJsonKeys(response.data) as List;
      final data = normalized
          .map((e) => MedicationLog.fromJson(e as Map<String, dynamic>))
          .toList();
      _cachedLogs = data;
      await _storage.saveLogs(data);
      return data;
    } on DioException {
      return _loadLogsCache();
    }
  }

  Future<double> getAdherence(int patientId) async {
    try {
      final response =
          await _client.get('/medication-logs/adherence/$patientId');
      final data = response.data as Map<String, dynamic>;
      return (data['adherence'] as num).toDouble();
    } on DioException {
      return 0.0;
    }
  }
}
