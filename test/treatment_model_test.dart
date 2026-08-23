import 'package:flutter_test/flutter_test.dart';
import 'package:vitalguard_mobile/models/treatment.dart';

void main() {
  group('TreatmentDetail.fromJson (clave medications del backend)', () {
    test('parsea medications como objeto (relación to-one)', () {
      final detail = TreatmentDetail.fromJson({
        'id': 1,
        'treatmentId': 10,
        'medicationId': 5,
        'doseInfo': '50 mg',
        'firstTakeTime': '2026-01-01T08:00:00.000',
        'status': 'En_curso',
        'medications': {
          'id': 5,
          'name': 'Losartán',
          'presentation': 'Tableta',
        },
        'schedules': [],
      });

      expect(detail.medication, isNotNull);
      expect(detail.medication!.name, 'Losartán');
      expect(detail.doseInfo, '50 mg');
    });

    test('parsea medications cuando viene como lista', () {
      final detail = TreatmentDetail.fromJson({
        'id': 1,
        'treatmentId': 10,
        'medicationId': 5,
        'firstTakeTime': '2026-01-01T08:00:00.000',
        'status': 'En_curso',
        'medications': [
          {'id': 5, 'name': 'Amlodipino'},
        ],
        'schedules': [],
      });

      expect(detail.medication!.name, 'Amlodipino');
    });

    test('sigue soportando la clave singular medication', () {
      final detail = TreatmentDetail.fromJson({
        'id': 1,
        'treatmentId': 10,
        'medicationId': 5,
        'firstTakeTime': '2026-01-01T08:00:00.000',
        'status': 'En_curso',
        'medication': {'id': 5, 'name': 'Metformina'},
        'schedules': [],
      });

      expect(detail.medication!.name, 'Metformina');
    });

    test('no falla si no hay medicamento', () {
      final detail = TreatmentDetail.fromJson({
        'id': 1,
        'treatmentId': 10,
        'medicationId': 5,
        'firstTakeTime': '2026-01-01T08:00:00.000',
        'status': 'En_curso',
        'schedules': [],
      });

      expect(detail.medication, isNull);
    });
  });
}