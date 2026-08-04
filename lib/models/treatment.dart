import 'enums.dart';
import 'patient.dart';
import 'medication.dart';

class Treatment {
  final int id;
  final int patientId;
  final int? appProfileId;
  final DateTime startDate;
  final DateTime? endDate;
  final TreatmentStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Patient? patient;
  final List<TreatmentDetail>? details;

  const Treatment({
    required this.id,
    required this.patientId,
    this.appProfileId,
    required this.startDate,
    this.endDate,
    this.status = TreatmentStatus.activo,
    this.createdAt,
    this.updatedAt,
    this.patient,
    this.details,
  });

  int get totalDays {
    final end = endDate ?? DateTime.now();
    return end.difference(startDate).inDays.clamp(0, 9999);
  }

  int get elapsedDays {
    return DateTime.now().difference(startDate).inDays.clamp(0, totalDays);
  }

  double get progress => totalDays > 0 ? elapsedDays / totalDays : 0.0;

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      id: json['id'] as int,
      patientId: json['patientId'] as int,
      appProfileId: json['appProfileId'] as int?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      status: _treatmentStatusFromApi(json['status'] as String),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      patient: json['patient'] != null
          ? Patient.fromJson(json['patient'] as Map<String, dynamic>)
          : null,
      details: json['details'] != null
          ? (json['details'] as List)
              .map((e) => TreatmentDetail.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'startDate': startDate.toIso8601String().split('T')[0],
      if (endDate != null) 'endDate': endDate!.toIso8601String().split('T')[0],
      'status': _treatmentStatusToApi(status),
    };
  }

  static TreatmentStatus _treatmentStatusFromApi(String value) {
    switch (value) {
      case 'Activo': return TreatmentStatus.activo;
      case 'Pausado': return TreatmentStatus.pausado;
      case 'Finalizado': return TreatmentStatus.finalizado;
      default: return TreatmentStatus.activo;
    }
  }

  static String _treatmentStatusToApi(TreatmentStatus status) {
    switch (status) {
      case TreatmentStatus.activo: return 'Activo';
      case TreatmentStatus.pausado: return 'Pausado';
      case TreatmentStatus.finalizado: return 'Finalizado';
    }
  }
}

class TreatmentDetail {
  final int id;
  final int treatmentId;
  final int medicationId;
  final String? doseInfo;
  final int? frequencyHours;
  final DateTime firstTakeTime;
  final DateTime? endDate;
  final MedicationStatus status;
  final int? compartmentNumber;
  final bool? isExternal;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Medication? medication;
  final List<Schedule>? schedules;

  const TreatmentDetail({
    required this.id,
    required this.treatmentId,
    required this.medicationId,
    this.doseInfo,
    this.frequencyHours,
    required this.firstTakeTime,
    this.endDate,
    this.status = MedicationStatus.enCurso,
    this.compartmentNumber,
    this.isExternal,
    this.createdAt,
    this.updatedAt,
    this.medication,
    this.schedules,
  });

  factory TreatmentDetail.fromJson(Map<String, dynamic> json) {
    return TreatmentDetail(
      id: json['id'] as int,
      treatmentId: json['treatmentId'] as int,
      medicationId: json['medicationId'] as int,
      doseInfo: json['doseInfo'] as String?,
      frequencyHours: json['frequencyHours'] as int?,
      firstTakeTime: DateTime.parse(json['firstTakeTime'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      status: _medicationStatusFromApi(json['status'] as String),
      compartmentNumber: json['compartmentNumber'] as int?,
      isExternal: json['isExternal'] as bool?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      medication: json['medication'] != null
          ? Medication.fromJson(json['medication'] as Map<String, dynamic>)
          : null,
      schedules: json['schedules'] != null
          ? (json['schedules'] as List)
              .map((e) => Schedule.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'treatmentId': treatmentId,
      'medicationId': medicationId,
      if (doseInfo != null) 'doseInfo': doseInfo,
      if (frequencyHours != null) 'frequencyHours': frequencyHours,
      'firstTakeTime':
          '${firstTakeTime.hour.toString().padLeft(2, '0')}:${firstTakeTime.minute.toString().padLeft(2, '0')}',
      if (endDate != null) 'endDate': endDate!.toIso8601String().split('T')[0],
      'status': _medicationStatusToApi(status),
      if (compartmentNumber != null) 'compartmentNumber': compartmentNumber,
      if (isExternal != null) 'isExternal': isExternal,
    };
  }

  static MedicationStatus _medicationStatusFromApi(String value) {
    switch (value) {
      case 'En_curso': return MedicationStatus.enCurso;
      case 'Finalizado': return MedicationStatus.finalizado;
      default: return MedicationStatus.enCurso;
    }
  }

  static String _medicationStatusToApi(MedicationStatus status) {
    switch (status) {
      case MedicationStatus.enCurso: return 'En_curso';
      case MedicationStatus.finalizado: return 'Finalizado';
    }
  }
}

class Schedule {
  final int id;
  final int treatmentDetailId;
  final DateTime timeOfDay;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<MedicationLog>? logs;
  final String? medicationName;
  final String? doseInfo;

  const Schedule({
    required this.id,
    required this.treatmentDetailId,
    required this.timeOfDay,
    this.createdAt,
    this.updatedAt,
    this.logs,
    this.medicationName,
    this.doseInfo,
  });

  String get timeDisplay {
    final hour = timeOfDay.hour;
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$hour12:$minute $amPm';
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    final details = json['treatmentDetails'] ?? json['treatment_details'];
    final medication =
        details is Map<String, dynamic> ? details['medications'] : null;
    return Schedule(
      id: json['id'] as int,
      treatmentDetailId: json['treatmentDetailId'] as int,
      timeOfDay: _parseTime(json['timeOfDay'] as String),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      logs: json['logs'] != null
          ? (json['logs'] as List)
              .map((e) => MedicationLog.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      medicationName:
          medication is Map<String, dynamic> ? medication['name'] as String? : null,
      doseInfo:
          details is Map<String, dynamic> ? details['doseInfo'] as String? : null,
    );
  }

  static DateTime _parseTime(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return parsed;
    final parts = value.split(':');
    if (parts.length >= 2) {
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, minute);
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'treatmentDetailId': treatmentDetailId,
      'timeOfDay': _timeToApi(timeOfDay),
      if (medicationName != null) 'medicationName': medicationName,
      if (doseInfo != null) 'doseInfo': doseInfo,
    };
  }

  static String _timeToApi(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class MedicationLog {
  final int id;
  final int scheduleId;
  final DateTime scheduledDatetime;
  final DateTime? actualTakenDatetime;
  final LogStatus status;
  final bool? voiceConfirmed;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MedicationLog({
    required this.id,
    required this.scheduleId,
    required this.scheduledDatetime,
    this.actualTakenDatetime,
    this.status = LogStatus.pendiente,
    this.voiceConfirmed,
    this.createdAt,
    this.updatedAt,
  });

  factory MedicationLog.fromJson(Map<String, dynamic> json) {
    return MedicationLog(
      id: json['id'] as int,
      scheduleId: json['scheduleId'] as int,
      scheduledDatetime: DateTime.parse(json['scheduledDatetime'] as String),
      actualTakenDatetime: json['actualTakenDatetime'] != null
          ? DateTime.parse(json['actualTakenDatetime'] as String)
          : null,
      status: _logStatusFromApi(json['status'] as String),
      voiceConfirmed: json['voiceConfirmed'] as bool?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scheduleId': scheduleId,
      'scheduledDatetime': scheduledDatetime.toIso8601String(),
      if (actualTakenDatetime != null)
        'actualTakenDatetime': actualTakenDatetime!.toIso8601String(),
      'status': _logStatusToApi(status),
      if (voiceConfirmed != null) 'voiceConfirmed': voiceConfirmed,
    };
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

  static String _logStatusToApi(LogStatus status) {
    switch (status) {
      case LogStatus.pendiente: return 'Pendiente';
      case LogStatus.confirmado: return 'Confirmado';
      case LogStatus.retraso: return 'Retraso';
      case LogStatus.omitida: return 'Omitida';
    }
  }
}
