import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';
import 'storage_service.dart';
import '../models/treatment.dart';
import '../models/medication.dart';
import '../models/enums.dart';

class TreatmentService extends ChangeNotifier {
  final ApiClient _client;
  final StorageService _storage;
  List<Treatment>? _cachedTreatments;
  List<Schedule>? _cachedSchedules;
  List<MedicationLog>? _cachedLogs;

  TreatmentService(this._client, this._storage);

  dynamic _normalizeKeys(dynamic value) {
    if (value is Map<String, dynamic>) {
      final result = <String, dynamic>{};
      value.forEach((key, val) {
        String camelKey = key.replaceAllMapped(
          RegExp(r'_([a-z])'),
          (match) => match.group(1)!.toUpperCase(),
        );
        if (camelKey == 'treatmentDetails') camelKey = 'details';
        if (camelKey == 'medicationLogs') camelKey = 'logs';
        result[camelKey] = _normalizeKeys(val);
      });
      return result;
    } else if (value is List) {
      return value.map((e) => _normalizeKeys(e)).toList();
    }
    return value;
  }

  Future<List<Treatment>> _loadTreatmentsCache() async {
    if (_cachedTreatments != null) return _cachedTreatments!;
    final stored = await _storage.loadTreatments();
    if (stored.isNotEmpty) {
      _cachedTreatments = stored;
    } else {
      _cachedTreatments = _defaultTreatments;
      await _storage.saveTreatments(_cachedTreatments!);
    }
    return _cachedTreatments!;
  }

  Future<List<Schedule>> _loadSchedulesCache() async {
    if (_cachedSchedules != null) return _cachedSchedules!;
    final stored = await _storage.loadSchedules();
    if (stored.isNotEmpty) {
      _cachedSchedules = stored;
    } else {
      _cachedSchedules = _defaultSchedules;
      await _storage.saveSchedules(_cachedSchedules!);
    }
    return _cachedSchedules!;
  }

  Future<List<MedicationLog>> _loadLogsCache() async {
    if (_cachedLogs != null) return _cachedLogs!;
    final stored = await _storage.loadLogs();
    if (stored.isNotEmpty) {
      _cachedLogs = stored;
    } else {
      _cachedLogs = _defaultLogs;
      await _storage.saveLogs(_cachedLogs!);
    }
    return _cachedLogs!;
  }

  Future<List<Treatment>> getTreatments(int patientId) async {
    try {
      final response = await _client.get('/treatments/patient/$patientId');
      final normalized = _normalizeKeys(response.data) as List;
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
      final normalized = _normalizeKeys(response.data) as Map<String, dynamic>;
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
      final normalized = _normalizeKeys(response.data) as List;
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
      final normalized = _normalizeKeys(response.data) as List;
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
      return 0.87;
    }
  }

  static final List<Treatment> _defaultTreatments = [
    Treatment(
      id: 1,
      patientId: 1,
      startDate: DateTime(2026, 1, 15),
      endDate: DateTime(2026, 12, 31),
      status: TreatmentStatus.activo,
      details: [
        TreatmentDetail(
          id: 1,
          treatmentId: 1,
          medicationId: 1,
          doseInfo: '1 tableta',
          frequencyHours: 8,
          firstTakeTime: DateTime(2026, 1, 15, 8, 0),
          status: MedicationStatus.enCurso,
          compartmentNumber: 1,
          medication: Medication(id: 1, name: 'Losartán', presentation: 'Tabletas 50mg'),
        ),
        TreatmentDetail(
          id: 2,
          treatmentId: 1,
          medicationId: 2,
          doseInfo: '1 tableta',
          frequencyHours: 24,
          firstTakeTime: DateTime(2026, 1, 15, 22, 0),
          status: MedicationStatus.enCurso,
          compartmentNumber: 2,
          medication: Medication(id: 2, name: 'Metformina', presentation: 'Tabletas 850mg'),
        ),
      ],
    ),
    Treatment(
      id: 2,
      patientId: 2,
      startDate: DateTime(2026, 2, 1),
      endDate: DateTime(2026, 8, 1),
      status: TreatmentStatus.activo,
      details: [
        TreatmentDetail(
          id: 3,
          treatmentId: 2,
          medicationId: 3,
          doseInfo: '1 cápsula',
          frequencyHours: 12,
          firstTakeTime: DateTime(2026, 2, 1, 9, 0),
          status: MedicationStatus.enCurso,
          compartmentNumber: 1,
          medication: Medication(id: 3, name: 'Omeprazol', presentation: 'Cápsulas 20mg'),
        ),
      ],
    ),
  ];

  static final List<Schedule> _defaultSchedules = [
    Schedule(id: 1, treatmentDetailId: 1, timeOfDay: DateTime(2026, 7, 28, 8, 0)),
    Schedule(id: 2, treatmentDetailId: 1, timeOfDay: DateTime(2026, 7, 28, 16, 0)),
    Schedule(id: 3, treatmentDetailId: 1, timeOfDay: DateTime(2026, 7, 28, 22, 0)),
    Schedule(id: 4, treatmentDetailId: 2, timeOfDay: DateTime(2026, 7, 28, 22, 0)),
  ];

  static final List<MedicationLog> _defaultLogs = [
    MedicationLog(id: 1, scheduleId: 1, scheduledDatetime: DateTime(2026, 7, 28, 8, 0), actualTakenDatetime: DateTime(2026, 7, 28, 8, 5), status: LogStatus.confirmado),
    MedicationLog(id: 2, scheduleId: 2, scheduledDatetime: DateTime(2026, 7, 28, 16, 0), status: LogStatus.pendiente),
    MedicationLog(id: 3, scheduleId: 3, scheduledDatetime: DateTime(2026, 7, 28, 22, 0), status: LogStatus.pendiente),
  ];
}
