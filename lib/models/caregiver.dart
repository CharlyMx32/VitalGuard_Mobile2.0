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

  /// Nombre para mostrar: prioriza el nombre real del backend; si no vino,
  /// usa el parentesco (evita mostrar "Cuidador" repetido para cada persona);
  /// si tampoco hay parentesco, cae a "Cuidador #id". El caller puede pasar
  /// isCurrent para mostrar "Tú".
  String label({bool isCurrent = false}) {
    final kin = kinshipDisplay ?? kinship;
    final hasName = displayName != null && displayName!.trim().isNotEmpty;
    final hasKin = kin != null && kin.isNotEmpty;
    final String base;
    final String kinPart;
    if (hasName) {
      base = displayName!;
      kinPart = hasKin ? ' ($kin)' : '';
    } else if (hasKin) {
      base = kin;
      kinPart = '';
    } else {
      base = 'Cuidador #$id';
      kinPart = '';
    }
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
      displayName: _extractName(json),
    );
  }

  /// El backend a veces manda el nombre directo (displayName/fullName/name) y a veces
  /// solo manda el perfil relacionado (appProfile) con firstName/paternalLastName/
  /// maternalLastName. Probamos varias formas antes de rendirnos y dejar el nombre en null
  /// (en ese caso la UI cae a un fallback genérico, ver [label]).
  static String? _extractName(Map<String, dynamic> json) {
    String? fromFlat(Map<String, dynamic> src) {
      for (final key in ['displayName', 'fullName', 'name']) {
        final v = src[key];
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
      final composed = [src['firstName'], src['paternalLastName'], src['maternalLastName']]
          .whereType<String>()
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .join(' ');
      return composed.isNotEmpty ? composed : null;
    }

    final direct = fromFlat(json);
    if (direct != null) return direct;

    final nested = json['appProfile'] ?? json['profile'] ?? json['user'];
    if (nested is Map<String, dynamic>) return fromFlat(nested);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'appProfileId': appProfileId,
      if (emergencyCallPriority != null)
        'emergencyCallPriority': emergencyCallPriority,
    };
  }
}
