class Caregiver {
  final int id;
  final int appProfileId;
  final int? emergencyCallPriority;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? kinship;
  final String? kinshipDisplay;
  final String? vitalId;
  final String? displayName;

  const Caregiver({
    required this.id,
    required this.appProfileId,
    this.emergencyCallPriority,
    this.createdAt,
    this.updatedAt,
    this.kinship,
    this.kinshipDisplay,
    this.vitalId,
    this.displayName,
  });

  /// Nombre para mostrar: prioriza displayName del backend (paciente autocuidado),
  /// si no, usa kinship + id; el caller puede pasar isCurrent para mostrar "Tú"
  String label({bool isCurrent = false}) {
    final kin = kinshipDisplay ?? kinship;
    final base = displayName?.trim().isNotEmpty == true
        ? displayName!
        : 'Cuidador';
    final kinPart = kin != null && kin.isNotEmpty ? ' ($kin)' : '';
    final prefix = isCurrent ? 'Tú · ' : '';
    return '$prefix$base$kinPart';
  }

  String get initials {
    final src = displayName ?? 'C';
    final parts = src.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return (parts[0][0] + parts[1][0]).toUpperCase();
    return src.trim().isNotEmpty ? src.trim()[0].toUpperCase() : 'C';
  }

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
      kinship: json['kinship'] as String?,
      kinshipDisplay: json['kinshipDisplay'] as String?,
      vitalId: json['vitalId'] as String?,
      displayName: json['displayName'] as String?,
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
