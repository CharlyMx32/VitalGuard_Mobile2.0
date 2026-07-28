import 'enums.dart';

class SosEvent {
  final int id;
  final int patientId;
  final int? deviceId;
  final SosStatus status;
  final int? resolvingCaregiverId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SosEvent({
    required this.id,
    required this.patientId,
    this.deviceId,
    this.status = SosStatus.activo,
    this.resolvingCaregiverId,
    this.createdAt,
    this.updatedAt,
  });

  factory SosEvent.fromJson(Map<String, dynamic> json) {
    return SosEvent(
      id: json['id'] as int,
      patientId: json['patientId'] as int,
      deviceId: json['deviceId'] as int?,
      status: _sosStatusFromApi(json['status'] as String),
      resolvingCaregiverId: json['resolvingCaregiverId'] as int?,
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
      'patientId': patientId,
      if (deviceId != null) 'deviceId': deviceId,
      'status': _sosStatusToApi(status),
      if (resolvingCaregiverId != null)
        'resolvingCaregiverId': resolvingCaregiverId,
    };
  }

  static SosStatus _sosStatusFromApi(String value) {
    switch (value) {
      case 'Activo': return SosStatus.activo;
      case 'Atendido': return SosStatus.atendido;
      case 'Falsa_Alarma': return SosStatus.falsaAlarma;
      default: return SosStatus.activo;
    }
  }

  static String _sosStatusToApi(SosStatus status) {
    switch (status) {
      case SosStatus.activo: return 'Activo';
      case SosStatus.atendido: return 'Atendido';
      case SosStatus.falsaAlarma: return 'Falsa_Alarma';
    }
  }
}
