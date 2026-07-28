enum AppName { mobile, web, iot }

enum BloodType {
  aPositive,
  aNegative,
  bPositive,
  bNegative,
  abPositive,
  abNegative,
  oPositive,
  oNegative;

  String get apiValue {
    switch (this) {
      case BloodType.aPositive: return 'A_POSITIVE';
      case BloodType.aNegative: return 'A_NEGATIVE';
      case BloodType.bPositive: return 'B_POSITIVE';
      case BloodType.bNegative: return 'B_NEGATIVE';
      case BloodType.abPositive: return 'AB_POSITIVE';
      case BloodType.abNegative: return 'AB_NEGATIVE';
      case BloodType.oPositive: return 'O_POSITIVE';
      case BloodType.oNegative: return 'O_NEGATIVE';
    }
  }

  String get displayValue {
    switch (this) {
      case BloodType.aPositive: return 'A+';
      case BloodType.aNegative: return 'A-';
      case BloodType.bPositive: return 'B+';
      case BloodType.bNegative: return 'B-';
      case BloodType.abPositive: return 'AB+';
      case BloodType.abNegative: return 'AB-';
      case BloodType.oPositive: return 'O+';
      case BloodType.oNegative: return 'O-';
    }
  }

  static BloodType fromApi(String value) {
    switch (value) {
      case 'A_POSITIVE': return BloodType.aPositive;
      case 'A_NEGATIVE': return BloodType.aNegative;
      case 'B_POSITIVE': return BloodType.bPositive;
      case 'B_NEGATIVE': return BloodType.bNegative;
      case 'AB_POSITIVE': return BloodType.abPositive;
      case 'AB_NEGATIVE': return BloodType.abNegative;
      case 'O_POSITIVE': return BloodType.oPositive;
      case 'O_NEGATIVE': return BloodType.oNegative;
      default: return BloodType.aPositive;
    }
  }
}

enum CompartmentStatus { closed, open }

enum GenderType { m, f }

enum KinshipType {
  madre,
  padre,
  hijoA,
  abueloA,
  esposoA,
  cuidador,
  otro;

  String get apiValue {
    switch (this) {
      case KinshipType.madre: return 'Madre';
      case KinshipType.padre: return 'Padre';
      case KinshipType.hijoA: return 'Hijo_a';
      case KinshipType.abueloA: return 'Abuelo_a';
      case KinshipType.esposoA: return 'Esposo_a';
      case KinshipType.cuidador: return 'Cuidador';
      case KinshipType.otro: return 'Otro';
    }
  }

  static KinshipType fromApi(String value) {
    switch (value) {
      case 'Madre': return KinshipType.madre;
      case 'Padre': return KinshipType.padre;
      case 'Hijo_a': return KinshipType.hijoA;
      case 'Abuelo_a': return KinshipType.abueloA;
      case 'Esposo_a': return KinshipType.esposoA;
      case 'Cuidador': return KinshipType.cuidador;
      default: return KinshipType.otro;
    }
  }
}

enum LogStatus { pendiente, confirmado, retraso, omitida }

enum MedicationStatus { enCurso, finalizado }

enum SosStatus { activo, atendido, falsaAlarma }

enum TreatmentStatus { activo, pausado, finalizado }
