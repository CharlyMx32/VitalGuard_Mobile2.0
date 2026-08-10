/// Validadores de campos basados en los DTOs y schema Prisma del backend.
///
/// Cada método retorna `null` si es válido, o un `String` con el mensaje de error.
class VitalValidator {
  VitalValidator._();

  // ─────────────────────────────────────────────
  //  Pacientes (CreatePatientDto)
  // ─────────────────────────────────────────────

  /// VarChar(50) — requerido
  static String? firstName(String? v) {
    if (v == null || v.trim().isEmpty) return 'El nombre es requerido';
    if (RegExp(r'[0-9]').hasMatch(v.trim())) return 'El nombre no debe contener números';
    if (v.trim().length > 50) return 'Máximo 50 caracteres';
    return null;
  }

  /// VarChar(25) — requerido
  static String? paternalLastName(String? v) {
    if (v == null || v.trim().isEmpty) return 'El apellido paterno es requerido';
    if (RegExp(r'[0-9]').hasMatch(v.trim())) return 'El apellido no debe contener números';
    if (v.trim().length > 25) return 'Máximo 25 caracteres';
    return null;
  }

  /// VarChar(25) — opcional
  static String? maternalLastName(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    if (RegExp(r'[0-9]').hasMatch(v.trim())) return 'El apellido no debe contener números';
    if (v.trim().length > 25) return 'Máximo 25 caracteres';
    return null;
  }

  /// VarChar(10) — opcional, solo dígitos
  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 10) return 'Debe ser exactamente 10 dígitos';
    return null;
  }

  /// VarChar(100) — opcional
  static String? address(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    if (v.trim().length > 100) return 'Máximo 100 caracteres';
    return null;
  }

  /// DateTime @db.Date — requerido, edad >= 16
  static String? birthDate(String? v) {
    if (v == null || v.trim().isEmpty) return 'La fecha de nacimiento es requerida';
    final date = DateTime.tryParse(v.trim());
    if (date == null) return 'Formato inválido (AAAA-MM-DD)';
    final now = DateTime.now();
    int age = now.year - date.year;
    if (now.month < date.month || (now.month == date.month && now.day < date.day)) {
      age--;
    }
    if (age < 16) return 'El paciente debe tener al menos 16 años';
    return null;
  }

  /// enum gender_type: M | F — requerido
  static String? gender(String? v) {
    if (v == null || v.trim().isEmpty) return 'Selecciona un género';
    if (!['M', 'F'].contains(v.trim())) return 'Género inválido';
    return null;
  }

  /// enum blood_type — opcional
  static String? bloodType(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    const valid = [
      'A_POSITIVE', 'A_NEGATIVE', 'B_POSITIVE', 'B_NEGATIVE',
      'AB_POSITIVE', 'AB_NEGATIVE', 'O_POSITIVE', 'O_NEGATIVE',
    ];
    if (!valid.contains(v.trim())) return 'Tipo de sangre inválido';
    return null;
  }

  /// enum kinship_type — opcional
  static String? kinship(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    const valid = ['Madre', 'Padre', 'Hijo/a', 'Abuelo/a', 'Esposo/a', 'Cuidador', 'Otro'];
    if (!valid.contains(v.trim())) return 'Parentesco inválido';
    return null;
  }

  // ─────────────────────────────────────────────
  //  Dispositivos (LinkDeviceDto / RegisterDeviceDto)
  // ─────────────────────────────────────────────

  /// VarChar(7) — requerido, código alfanumérico
  static String? deviceCode(String? v) {
    if (v == null || v.trim().isEmpty) return 'El código es requerido';
    if (v.trim().length > 7) return 'Máximo 7 caracteres';
    if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(v.trim())) return 'Solo letras y números';
    return null;
  }

  /// patientId — requerido, entero positivo
  static String? patientId(String? v) {
    if (v == null || v.trim().isEmpty) return 'Selecciona un paciente';
    final n = int.tryParse(v.trim());
    if (n == null || n <= 0) return 'ID inválido';
    return null;
  }

  // ─────────────────────────────────────────────
  //  Tratamientos (CreateTreatmentDetailDto)
  // ─────────────────────────────────────────────

  /// VarChar(50) — opcional
  static String? doseInfo(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    if (v.trim().length > 50) return 'Máximo 50 caracteres';
    return null;
  }

  /// frequencyHours — SmallInt(1..72), opcional
  static String? frequencyHours(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final n = int.tryParse(v.trim());
    if (n == null || n < 1 || n > 72) return 'Debe ser entre 1 y 72 horas';
    return null;
  }

  /// compartmentNumber — SmallInt(1..5), opcional
  static String? compartmentNumber(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final n = int.tryParse(v.trim());
    if (n == null || n < 1 || n > 5) return 'Compartimento 1 a 5';
    return null;
  }

  /// timeOfDay — formato HH:mm
  static String? timeOfDay(String? v) {
    if (v == null || v.trim().isEmpty) return 'La hora es requerida';
    if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(v.trim())) return 'Formato HH:mm';
    final parts = v.trim().split(':');
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) {
      return 'Hora inválida';
    }
    return null;
  }

  /// startDate / endDate — ISO date string
  static String? dateString(String? v, {bool required = false}) {
    if (v == null || v.trim().isEmpty) {
      return required ? 'La fecha es requerida' : null;
    }
    if (DateTime.tryParse(v.trim()) == null) return 'Formato inválido (AAAA-MM-DD)';
    return null;
  }

  // ─────────────────────────────────────────────
  //  Genéricos
  // ─────────────────────────────────────────────

  /// Campo de texto requerido con longitud máxima opcional
  static String? required(String? v, String label, {int? maxLength}) {
    if (v == null || v.trim().isEmpty) return '$label es requerido';
    if (maxLength != null && v.trim().length > maxLength) return 'Máximo $maxLength caracteres';
    return null;
  }

  /// Solo números enteros positivos
  static String? positiveInt(String? v, {String? label}) {
    if (v == null || v.trim().isEmpty) return '${label ?? 'Valor'} es requerido';
    final n = int.tryParse(v.trim());
    if (n == null || n <= 0) return '${label ?? 'Valor'} inválido';
    return null;
  }

  /// Número decimal positivo
  static String? positiveDouble(String? v, {String? label}) {
    if (v == null || v.trim().isEmpty) return '${label ?? 'Valor'} es requerido';
    final n = double.tryParse(v.trim());
    if (n == null || n <= 0) return '${label ?? 'Valor'} inválido';
    return null;
  }

  /// Sin caracteres numéricos
  static String? noNumbers(String? v, String label) {
    if (v == null || v.trim().isEmpty) return null;
    if (RegExp(r'[0-9]').hasMatch(v.trim())) return '$label no debe contener números';
    return null;
  }

  /// Cadena de solo dígitos
  static String? digitsOnly(String? v, String label, {int? exactLength}) {
    if (v == null || v.trim().isEmpty) return '$label es requerido';
    if (!RegExp(r'^\d+$').hasMatch(v.trim())) return 'Solo números';
    if (exactLength != null && v.trim().length != exactLength) {
      return 'Debe ser exactamente $exactLength dígitos';
    }
    return null;
  }
}
