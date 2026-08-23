import 'enums.dart';
import 'patient.dart';

enum InvitationStatus {
  pendiente,
  aceptada,
  rechazada,
  cancelada,
  expirada;

  static InvitationStatus fromApi(String value) {
    switch (value) {
      case 'ACEPTADA': return InvitationStatus.aceptada;
      case 'RECHAZADA': return InvitationStatus.rechazada;
      case 'CANCELADA': return InvitationStatus.cancelada;
      case 'EXPIRADA': return InvitationStatus.expirada;
      default: return InvitationStatus.pendiente;
    }
  }

  String get displayValue {
    switch (this) {
      case InvitationStatus.pendiente: return 'Pendiente';
      case InvitationStatus.aceptada: return 'Aceptada';
      case InvitationStatus.rechazada: return 'Rechazada';
      case InvitationStatus.cancelada: return 'Cancelada';
      case InvitationStatus.expirada: return 'Expirada';
    }
  }
}

enum InvitationRole {
  caregiver,
  doctor;

  static InvitationRole fromApi(String value) {
    return value == 'DOCTOR' ? InvitationRole.doctor : InvitationRole.caregiver;
  }

  String get displayValue {
    switch (this) {
      case InvitationRole.caregiver: return 'Cuidador';
      case InvitationRole.doctor: return 'Médico';
    }
  }
}

class Invitation {
  final int id;
  final int? patientId;
  final Patient? patient;
  final String? inviteeVitalId;
  final String? inviteeEmail;
  final InvitationRole role;
  final KinshipType? kinship;
  final InvitationStatus status;
  final String? token;
  final String? message;
  final DateTime? expiresAt;
  final DateTime? respondedAt;
  final DateTime? createdAt;

  const Invitation({
    required this.id,
    this.patientId,
    this.patient,
    this.inviteeVitalId,
    this.inviteeEmail,
    required this.role,
    this.kinship,
    required this.status,
    this.token,
    this.message,
    this.expiresAt,
    this.respondedAt,
    this.createdAt,
  });

  String? get patientName => patient?.fullName;

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'] as int? ?? 0,
      patientId: json['patientId'] as int?,
      patient: json['patients'] != null
          ? Patient.fromJson(json['patients'] as Map<String, dynamic>)
          : null,
      inviteeVitalId: json['inviteeVitalId'] as String?,
      inviteeEmail: json['inviteeEmail'] as String?,
      role: json['inviteeRole'] != null
          ? InvitationRole.fromApi(json['inviteeRole'] as String)
          : InvitationRole.caregiver,
      kinship: json['kinship'] != null
          ? KinshipType.fromApi(json['kinship'] as String)
          : null,
      status: json['status'] != null
          ? InvitationStatus.fromApi(json['status'] as String)
          : InvitationStatus.pendiente,
      token: json['token'] as String?,
      message: json['message'] as String?,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String)
          : null,
      respondedAt: json['respondedAt'] != null
          ? DateTime.tryParse(json['respondedAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}
