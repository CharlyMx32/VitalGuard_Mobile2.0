class Medication {
  final int id;
  final String name;
  final String? presentation;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Medication({
    required this.id,
    required this.name,
    this.presentation,
    this.createdAt,
    this.updatedAt,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as int,
      name: json['name'] as String,
      presentation: json['presentation'] as String?,
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
      if (presentation != null) 'presentation': presentation,
    };
  }
}
