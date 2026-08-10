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
