import 'enums.dart';

class Caregiver {
  final int id;
  final int appProfileId;
  final int? emergencyCallPriority;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Caregiver({
    required this.id,
    required this.appProfileId,
    this.emergencyCallPriority,
    this.createdAt,
    this.updatedAt,
  });

  factory Caregiver.fromJson(Map<String, dynamic> json) {
    return Caregiver(
      id: json['id'] as int,
      appProfileId: json['appProfileId'] as int,
      emergencyCallPriority: json['emergencyCallPriority'] as int?,
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
      'appProfileId': appProfileId,
      if (emergencyCallPriority != null)
        'emergencyCallPriority': emergencyCallPriority,
    };
  }
}

class CaregiverPatient {
  final int caregiverId;
  final int patientId;
  final KinshipType? kinship;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CaregiverPatient({
    required this.caregiverId,
    required this.patientId,
    this.kinship,
    this.createdAt,
    this.updatedAt,
  });

  factory CaregiverPatient.fromJson(Map<String, dynamic> json) {
    return CaregiverPatient(
      caregiverId: json['caregiverId'] as int,
      patientId: json['patientId'] as int,
      kinship: json['kinship'] != null
          ? KinshipType.fromApi(json['kinship'] as String)
          : null,
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
      'caregiverId': caregiverId,
      'patientId': patientId,
      if (kinship != null) 'kinship': kinship!.apiValue,
    };
  }
}

class Doctor {
  final int id;
  final int appProfileId;
  final String specialty;
  final String medicalLicense;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Doctor({
    required this.id,
    required this.appProfileId,
    required this.specialty,
    required this.medicalLicense,
    this.createdAt,
    this.updatedAt,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] as int,
      appProfileId: json['appProfileId'] as int,
      specialty: json['specialty'] as String,
      medicalLicense: json['medicalLicense'] as String,
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
      'appProfileId': appProfileId,
      'specialty': specialty,
      'medicalLicense': medicalLicense,
    };
  }
}

class DoctorPatient {
  final int doctorId;
  final int patientId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DoctorPatient({
    required this.doctorId,
    required this.patientId,
    this.createdAt,
    this.updatedAt,
  });

  factory DoctorPatient.fromJson(Map<String, dynamic> json) {
    return DoctorPatient(
      doctorId: json['doctorId'] as int,
      patientId: json['patientId'] as int,
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
      'doctorId': doctorId,
      'patientId': patientId,
    };
  }
}
