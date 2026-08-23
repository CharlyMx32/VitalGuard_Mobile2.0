import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vitalguard_mobile/services/api_client.dart';
import 'package:vitalguard_mobile/services/storage_service.dart';
import 'package:vitalguard_mobile/services/auth_service.dart';
import 'package:vitalguard_mobile/services/treatment_service.dart';
import 'package:vitalguard_mobile/services/patient_current_service.dart';
import 'package:vitalguard_mobile/models/patient.dart';
import 'package:vitalguard_mobile/models/treatment.dart';
import 'package:vitalguard_mobile/models/enums.dart';
import 'package:vitalguard_mobile/screens/treatments/schedule_screen.dart';

class ScheduleFakeTreatmentService extends TreatmentService {
  ScheduleFakeTreatmentService(ApiClient c, StorageService s) : super(c, s);

  @override
  Future<List<Schedule>> getSchedulesForDay(int patientId, DateTime day) async {
    return [
      Schedule(
        id: patientId * 100,
        treatmentDetailId: patientId,
        timeOfDay: day.add(const Duration(hours: 9)),
        medicationName: 'Medicamento $patientId',
        doseInfo: '50 mg',
      ),
    ];
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Patient patient(int id, String first) => Patient(
        id: id,
        firstName: first,
        paternalLastName: 'Pérez',
        birthDate: DateTime(1990),
        gender: GenderType.f,
      );

  Widget buildSchedule(PatientCurrentService current) {
    final auth = AuthService();
    final apiClient = ApiClient(auth);
    final storage = StorageService();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: current),
        Provider<TreatmentService>.value(
          value: ScheduleFakeTreatmentService(apiClient, storage),
        ),
      ],
      child: const MaterialApp(home: Scaffold(body: ScheduleContent())),
    );
  }

  testWidgets('recarga el horario al cambiar de paciente', (tester) async {
    final current = PatientCurrentService()
      ..setPatients([patient(1, 'Abuela'), patient(2, 'Tío')]);

    await tester.pumpWidget(buildSchedule(current));
    await tester.pumpAndSettle();

    // Corre inicialmente al paciente 1 (seleccionado por defecto)
    expect(find.text('Medicamento 1'), findsOneWidget);
    expect(find.text('Medicamento 2'), findsNothing);

    // Cambiar a paciente 2 debe recargar su horario sin refresh manual
    current.selectPatient(patient(2, 'Tío'));
    await tester.pumpAndSettle();

    expect(find.text('Medicamento 2'), findsOneWidget);
    expect(find.text('Medicamento 1'), findsNothing);
  });
}