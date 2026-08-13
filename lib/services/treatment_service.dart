import 'package:dio/dio.dart';
import 'api_client.dart';
import 'storage_service.dart';
import '../utils/json_utils.dart';
import '../models/treatment.dart';
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
      List<Treatment> treatments;
      try {
        treatments = await _loadTreatmentsCache();
      } catch (_) {
        treatments = [];
        _cachedTreatments = treatments;
      }
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

  /// Devuelve los horarios programados para el día indicado. Los horarios
  /// son recurrentes (misma hora todos los días del tratamiento), por lo que
  /// se construyen a partir del tratamiento y sus detalles, marcando como
  /// completado si existe un log confirmado para esa fecha.
  Future<List<Schedule>> getSchedulesForDay(int patientId, DateTime day) async {
    final treatments = await getTreatments(patientId);
    final logs = await getRecentLogs(patientId);
    final schedules = <Schedule>[];
    final base = DateTime(day.year, day.month, day.day);

    for (final treatment in treatments) {
      for (final detail in treatment.details ?? []) {
        for (final s in detail.schedules ?? []) {
          final time = s.timeOfDay;
          final scheduledAt =
              DateTime(base.year, base.month, base.day, time.hour, time.minute);
          final dayLogs = logs
              .where((l) =>
                  l.scheduleId == s.id &&
                  _sameDay(l.scheduledDatetime, scheduledAt))
              .toList();
          schedules.add(Schedule(
            id: s.id,
            treatmentDetailId: s.treatmentDetailId,
            timeOfDay: scheduledAt,
            logs: dayLogs,
            medicationName: detail.medication?.name ?? s.medicationName,
            doseInfo: detail.doseInfo ?? s.doseInfo,
          ));
        }
      }
    }
    schedules.sort((a, b) => a.timeOfDay.compareTo(b.timeOfDay));
    return schedules;
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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

  /// Confirma una dosis (marca como tomada). Si el backend no responde,
  /// se guarda el log localmente.
  Future<void> confirmDose(Schedule schedule) async {
    final now = DateTime.now();
    final log = MedicationLog(
      id: DateTime.now().millisecondsSinceEpoch,
      scheduleId: schedule.id,
      scheduledDatetime: schedule.timeOfDay,
      actualTakenDatetime: now,
      status: LogStatus.confirmado,
      createdAt: now,
      updatedAt: now,
    );
    try {
      await _client.post('/medication-logs', data: log.toJson());
    } on DioException {
      // fallback local
    }
    final logs = await _loadLogsCache();
    logs.add(log);
    await _storage.saveLogs(logs);
    _cachedLogs = logs;

    final treatments = _cachedTreatments;
    if (treatments == null) return;
    for (final t in treatments) {
      final details = t.details ?? [];
      for (final d in details) {
        final scheds = d.schedules ?? [];
        for (final s in scheds) {
          if (s.id == schedule.id) {
            final updatedSched = Schedule(
              id: s.id,
              treatmentDetailId: s.treatmentDetailId,
              timeOfDay: s.timeOfDay,
              createdAt: s.createdAt,
              updatedAt: s.updatedAt,
              logs: [...?s.logs, log],
              medicationName: s.medicationName,
              doseInfo: s.doseInfo,
            );
            final updatedDetail = TreatmentDetail(
              id: d.id,
              treatmentId: d.treatmentId,
              medicationId: d.medicationId,
              doseInfo: d.doseInfo,
              frequencyHours: d.frequencyHours,
              firstTakeTime: d.firstTakeTime,
              endDate: d.endDate,
              status: d.status,
              compartmentNumber: d.compartmentNumber,
              isExternal: d.isExternal,
              createdAt: d.createdAt,
              updatedAt: d.updatedAt,
              medication: d.medication,
              schedules: scheds.map((x) => x == s ? updatedSched : x).toList(),
            );
            final updated = Treatment(
              id: t.id,
              patientId: t.patientId,
              appProfileId: t.appProfileId,
              startDate: t.startDate,
              endDate: t.endDate,
              status: t.status,
              createdAt: t.createdAt,
              updatedAt: t.updatedAt,
              patient: t.patient,
              details: details.map((x) => x == d ? updatedDetail : x).toList(),
            );
            treatments[treatments.indexOf(t)] = updated;
            await _storage.saveTreatments(treatments);
            return;
          }
        }
      }
    }
  }

  Future<Treatment> createTreatment(int patientId, DateTime startDate, DateTime? endDate) async {
    final treatment = Treatment(
      id: 0,
      patientId: patientId,
      startDate: startDate,
      endDate: endDate,
      status: TreatmentStatus.activo,
      createdAt: DateTime.now(),
    );
    final response = await _client.post('/treatments', data: treatment.toJson());
    final normalized = normalizeJsonKeys(response.data) as Map<String, dynamic>;
    final saved = Treatment.fromJson(normalized);
    final cached = await _loadTreatmentsCache();
    cached.add(saved);
    await _storage.saveTreatments(cached);
    _cachedTreatments = cached;
    return saved;
  }

  Future<TreatmentDetail> addDetail(int treatmentId, TreatmentDetail detail) async {
    final response = await _client.post('/treatment-details', data: detail.toJson());
    final normalized = normalizeJsonKeys(response.data) as Map<String, dynamic>;
    final saved = TreatmentDetail.fromJson(normalized);
    _attachDetail(treatmentId, saved);
    return saved;
  }

  void _attachDetail(int treatmentId, TreatmentDetail detail) {
    final treatments = _cachedTreatments;
    if (treatments == null) return;
    for (final t in treatments) {
      if (t.id == treatmentId) {
        final details = [...?t.details, detail];
        final updated = Treatment(
          id: t.id,
          patientId: t.patientId,
          appProfileId: t.appProfileId,
          startDate: t.startDate,
          endDate: t.endDate,
          status: t.status,
          createdAt: t.createdAt,
          updatedAt: t.updatedAt,
          patient: t.patient,
          details: details,
        );
        treatments[treatments.indexOf(t)] = updated;
        _storage.saveTreatments(treatments);
        break;
      }
    }
  }

  Future<Schedule> addSchedule(Schedule schedule) async {
    final response = await _client.post('/schedules', data: schedule.toJson());
    final normalized = normalizeJsonKeys(response.data) as Map<String, dynamic>;
    final saved = Schedule.fromJson(normalized);
    _attachSchedule(saved);
    return saved;
  }

  void _attachSchedule(Schedule schedule) {
    final treatments = _cachedTreatments;
    if (treatments == null) return;
    for (final t in treatments) {
      final details = t.details ?? [];
      for (final d in details) {
        if (d.id == schedule.treatmentDetailId) {
          final scheds = [...?d.schedules, schedule];
          final updatedDetail = TreatmentDetail(
            id: d.id,
            treatmentId: d.treatmentId,
            medicationId: d.medicationId,
            doseInfo: d.doseInfo,
            frequencyHours: d.frequencyHours,
            firstTakeTime: d.firstTakeTime,
            endDate: d.endDate,
            status: d.status,
            compartmentNumber: d.compartmentNumber,
            isExternal: d.isExternal,
            createdAt: d.createdAt,
            updatedAt: d.updatedAt,
            medication: d.medication,
            schedules: scheds,
          );
          final updated = Treatment(
            id: t.id,
            patientId: t.patientId,
            appProfileId: t.appProfileId,
            startDate: t.startDate,
            endDate: t.endDate,
            status: t.status,
            createdAt: t.createdAt,
            updatedAt: t.updatedAt,
            patient: t.patient,
            details: details.map((x) => x == d ? updatedDetail : x).toList(),
          );
          treatments[treatments.indexOf(t)] = updated;
          _storage.saveTreatments(treatments);
          return;
        }
      }
    }
  }

  Future<void> updateDetailStatus(int detailId, MedicationStatus status) async {
    try {
      await _client.patch('/treatment-details/$detailId', data: {'status': _medicationStatusToApi(status)});
    } on DioException {
      // silently fail, status was already changed in memory
    }
    // update cache
    final treatments = await _loadTreatmentsCache();
    for (final t in treatments) {
      final details = t.details ?? [];
      for (final d in details) {
        if (d.id == detailId) {
          final idx = details.indexOf(d);
          final updated = TreatmentDetail(
            id: d.id,
            treatmentId: d.treatmentId,
            medicationId: d.medicationId,
            doseInfo: d.doseInfo,
            frequencyHours: d.frequencyHours,
            firstTakeTime: d.firstTakeTime,
            endDate: d.endDate,
            status: status,
            compartmentNumber: d.compartmentNumber,
            isExternal: d.isExternal,
            createdAt: d.createdAt,
            updatedAt: d.updatedAt,
            medication: d.medication,
            schedules: d.schedules,
          );
          details[idx] = updated;
          break;
        }
      }
    }
    await _storage.saveTreatments(treatments);
    _cachedTreatments = treatments;
  }

  Future<void> updateTreatmentDetail(int id, Map<String, dynamic> fields) async {
    try {
      await _client.patch('/treatment-details/$id', data: fields);
    } on DioException {}
    final cached = await _loadTreatmentsCache();
    for (final t in cached) {
      final details = t.details;
      if (details == null) continue;
      final idx = details.indexWhere((d) => d.id == id);
      if (idx != -1) {
        final d = details[idx];
        final updated = TreatmentDetail(
          id: d.id,
          treatmentId: d.treatmentId,
          medicationId: fields['medicationId'] as int? ?? d.medicationId,
          doseInfo: fields['doseInfo'] as String? ?? d.doseInfo,
          frequencyHours: fields['frequencyHours'] as int? ?? d.frequencyHours,
          firstTakeTime: fields['firstTakeTime'] != null
              ? DateTime.parse(fields['firstTakeTime'] as String)
              : d.firstTakeTime,
          endDate: fields['endDate'] != null ? DateTime.parse(fields['endDate'] as String) : d.endDate,
          status: d.status,
          compartmentNumber: fields['compartmentNumber'] as int? ?? d.compartmentNumber,
          isExternal: fields['isExternal'] as bool? ?? d.isExternal,
          createdAt: d.createdAt,
          updatedAt: DateTime.now(),
          medication: d.medication,
          schedules: d.schedules,
        );
        final updatedDetails = List<TreatmentDetail>.from(details);
        updatedDetails[idx] = updated;
        cached[cached.indexOf(t)] = Treatment(
          id: t.id,
          patientId: t.patientId,
          appProfileId: t.appProfileId,
          startDate: t.startDate,
          endDate: t.endDate,
          status: t.status,
          createdAt: t.createdAt,
          updatedAt: DateTime.now(),
          patient: t.patient,
          details: updatedDetails,
        );
        break;
      }
    }
    await _storage.saveTreatments(cached);
    _cachedTreatments = cached;
  }

  Future<void> updateTreatmentFields(int id, Map<String, dynamic> fields) async {
    try {
      await _client.patch('/treatments/$id', data: fields);
    } on DioException {}
    final cached = await _loadTreatmentsCache();
    final idx = cached.indexWhere((t) => t.id == id);
    if (idx != -1) {
      final t = cached[idx];
      final statusStr = fields['status'] as String?;
      final endDateStr = fields['endDate'] as String?;
      cached[idx] = Treatment(
        id: t.id,
        patientId: t.patientId,
        appProfileId: t.appProfileId,
        startDate: t.startDate,
        endDate: endDateStr != null ? DateTime.parse(endDateStr) : t.endDate,
        status: statusStr != null ? _treatmentStatusFromApi(statusStr) : t.status,
        createdAt: t.createdAt,
        updatedAt: DateTime.now(),
        patient: t.patient,
        details: t.details,
      );
      await _storage.saveTreatments(cached);
      _cachedTreatments = cached;
    }
  }

  Future<void> deleteTreatment(int id) async {
    try {
      await _client.delete('/treatments/$id');
    } on DioException {}
    final cached = await _loadTreatmentsCache();
    cached.removeWhere((t) => t.id == id);
    await _storage.saveTreatments(cached);
    _cachedTreatments = cached;
  }

  Future<void> deleteTreatmentDetail(int id) async {
    try {
      await _client.delete('/treatment-details/$id');
    } on DioException {}
    final cached = await _loadTreatmentsCache();
    for (final t in cached) {
      final details = t.details;
      if (details == null) continue;
      final idx = details.indexWhere((d) => d.id == id);
      if (idx != -1) {
        final updated = Treatment(
          id: t.id,
          patientId: t.patientId,
          appProfileId: t.appProfileId,
          startDate: t.startDate,
          endDate: t.endDate,
          status: t.status,
          createdAt: t.createdAt,
          updatedAt: t.updatedAt,
          patient: t.patient,
          details: [...details]..removeAt(idx),
        );
        cached[cached.indexOf(t)] = updated;
        break;
      }
    }
    await _storage.saveTreatments(cached);
    _cachedTreatments = cached;
  }

  Future<void> deleteSchedule(int id) async {
    try {
      await _client.delete('/schedules/$id');
    } on DioException {}
    final cached = await _loadTreatmentsCache();
    for (final t in cached) {
      final details = t.details;
      if (details == null) continue;
      for (final d in details) {
        final schedules = d.schedules;
        if (schedules == null) continue;
        final idx = schedules.indexWhere((s) => s.id == id);
        if (idx != -1) {
          final updatedDetail = TreatmentDetail(
            id: d.id,
            treatmentId: d.treatmentId,
            medicationId: d.medicationId,
            doseInfo: d.doseInfo,
            frequencyHours: d.frequencyHours,
            firstTakeTime: d.firstTakeTime,
            endDate: d.endDate,
            status: d.status,
            compartmentNumber: d.compartmentNumber,
            isExternal: d.isExternal,
            createdAt: d.createdAt,
            updatedAt: d.updatedAt,
            medication: d.medication,
            schedules: [...schedules]..removeAt(idx),
          );
          final updated = Treatment(
            id: t.id,
            patientId: t.patientId,
            appProfileId: t.appProfileId,
            startDate: t.startDate,
            endDate: t.endDate,
            status: t.status,
            createdAt: t.createdAt,
            updatedAt: t.updatedAt,
            patient: t.patient,
            details: details.map((x) => x == d ? updatedDetail : x).toList(),
          );
          cached[cached.indexOf(t)] = updated;
          await _storage.saveTreatments(cached);
          _cachedTreatments = cached;
          return;
        }
      }
    }
  }

  Future<void> updateMedicationLog(int id, Map<String, dynamic> fields) async {
    try {
      await _client.patch('/medication-logs/$id', data: fields);
    } on DioException {}
    final cached = await _loadLogsCache();
    final idx = cached.indexWhere((l) => l.id == id);
    if (idx != -1) {
      final log = cached[idx];
      final statusStr = fields['status'] as String?;
      final actualStr = fields['actualTakenDatetime'] as String?;
      cached[idx] = MedicationLog(
        id: log.id,
        scheduleId: log.scheduleId,
        scheduledDatetime: log.scheduledDatetime,
        actualTakenDatetime: actualStr != null ? DateTime.parse(actualStr) : log.actualTakenDatetime,
        status: statusStr != null ? _logStatusFromApi(statusStr) : log.status,
        voiceConfirmed: fields['voiceConfirmed'] as bool? ?? log.voiceConfirmed,
        createdAt: log.createdAt,
        updatedAt: DateTime.now(),
      );
      await _storage.saveLogs(cached);
      _cachedLogs = cached;
    }
  }

  String _medicationStatusToApi(MedicationStatus status) {
    switch (status) {
      case MedicationStatus.enCurso: return 'En_curso';
      case MedicationStatus.finalizado: return 'Finalizado';
    }
  }

  static TreatmentStatus _treatmentStatusFromApi(String value) {
    switch (value) {
      case 'Activo': return TreatmentStatus.activo;
      case 'Pausado': return TreatmentStatus.pausado;
      case 'Finalizado': return TreatmentStatus.finalizado;
      default: return TreatmentStatus.activo;
    }
  }

  static LogStatus _logStatusFromApi(String value) {
    switch (value) {
      case 'Pendiente': return LogStatus.pendiente;
      case 'Confirmado': return LogStatus.confirmado;
      case 'Retraso': return LogStatus.retraso;
      case 'Omitida': return LogStatus.omitida;
      default: return LogStatus.pendiente;
    }
  }
}
