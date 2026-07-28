import 'enums.dart';

class Device {
  final int id;
  final String uniqueCode;
  final int? patientId;
  final int? responsibleCaregiverId;
  final bool? isOnline;
  final DateTime? lastSyncAt;
  final String? firmwareVersion;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<DeviceCompartment>? compartments;

  const Device({
    required this.id,
    required this.uniqueCode,
    this.patientId,
    this.responsibleCaregiverId,
    this.isOnline,
    this.lastSyncAt,
    this.firmwareVersion,
    this.createdAt,
    this.updatedAt,
    this.compartments,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] as int,
      uniqueCode: json['uniqueCode'] as String,
      patientId: json['patientId'] as int?,
      responsibleCaregiverId: json['responsibleCaregiverId'] as int?,
      isOnline: json['isOnline'] as bool?,
      lastSyncAt: json['lastSyncAt'] != null
          ? DateTime.parse(json['lastSyncAt'] as String)
          : null,
      firmwareVersion: json['firmwareVersion'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      compartments: json['compartments'] != null
          ? (json['compartments'] as List)
              .map((e) => DeviceCompartment.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uniqueCode': uniqueCode,
      if (patientId != null) 'patientId': patientId,
      if (responsibleCaregiverId != null) 'responsibleCaregiverId': responsibleCaregiverId,
      if (firmwareVersion != null) 'firmwareVersion': firmwareVersion,
    };
  }
}

class DeviceCompartment {
  final int id;
  final int deviceId;
  final int compartmentNumber;
  final CompartmentStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DeviceCompartment({
    required this.id,
    required this.deviceId,
    required this.compartmentNumber,
    this.status = CompartmentStatus.closed,
    this.createdAt,
    this.updatedAt,
  });

  factory DeviceCompartment.fromJson(Map<String, dynamic> json) {
    return DeviceCompartment(
      id: json['id'] as int,
      deviceId: json['deviceId'] as int,
      compartmentNumber: json['compartmentNumber'] as int,
      status: json['status'] == 'open'
          ? CompartmentStatus.open
          : CompartmentStatus.closed,
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
      'deviceId': deviceId,
      'compartmentNumber': compartmentNumber,
      'status': status == CompartmentStatus.open ? 'open' : 'closed',
    };
  }
}
