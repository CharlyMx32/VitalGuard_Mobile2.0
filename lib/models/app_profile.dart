import 'enums.dart';
import 'caregiver.dart';

class AppProfile {
  final int id;
  final String vitalId;
  final int roleId;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Role? role;
  final Caregiver? caregiver;
  final Doctor? doctor;

  const AppProfile({
    required this.id,
    required this.vitalId,
    required this.roleId,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.role,
    this.caregiver,
    this.doctor,
  });

  factory AppProfile.fromJson(Map<String, dynamic> json) {
    return AppProfile(
      id: json['id'] as int,
      vitalId: json['vitalId'] as String,
      roleId: json['roleId'] as int,
      isActive: json['isActive'] as bool?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      role: json['role'] != null
          ? Role.fromJson(json['role'] as Map<String, dynamic>)
          : null,
      caregiver: json['caregiver'] != null
          ? Caregiver.fromJson(json['caregiver'] as Map<String, dynamic>)
          : null,
      doctor: json['doctor'] != null
          ? Doctor.fromJson(json['doctor'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vitalId': vitalId,
      'roleId': roleId,
      if (isActive != null) 'isActive': isActive,
    };
  }
}

class Role {
  final int id;
  final String name;
  final AppName appName;
  final bool? isSystem;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Role({
    required this.id,
    required this.name,
    required this.appName,
    this.isSystem,
    this.createdAt,
    this.updatedAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] as int,
      name: json['name'] as String,
      appName: _appNameFromApi(json['appName'] as String),
      isSystem: json['isSystem'] as bool?,
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
      'name': name,
      'appName': _appNameToApi(appName),
      if (isSystem != null) 'isSystem': isSystem,
    };
  }

  static AppName _appNameFromApi(String value) {
    switch (value) {
      case 'MOBILE': return AppName.mobile;
      case 'WEB': return AppName.web;
      case 'IOT': return AppName.iot;
      default: return AppName.mobile;
    }
  }

  static String _appNameToApi(AppName name) {
    switch (name) {
      case AppName.mobile: return 'MOBILE';
      case AppName.web: return 'WEB';
      case AppName.iot: return 'IOT';
    }
  }
}
