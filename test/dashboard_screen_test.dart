import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vitalguard_mobile/services/api_client.dart';
import 'package:vitalguard_mobile/services/storage_service.dart';
import 'package:vitalguard_mobile/services/auth_service.dart';
import 'package:vitalguard_mobile/services/avatar_service.dart';
import 'package:vitalguard_mobile/services/notification_service.dart';
import 'package:vitalguard_mobile/services/patient_service.dart';
import 'package:vitalguard_mobile/services/patient_current_service.dart';
import 'package:vitalguard_mobile/services/treatment_service.dart';
import 'package:vitalguard_mobile/models/patient.dart';
import 'package:vitalguard_mobile/models/treatment.dart';
import 'package:vitalguard_mobile/models/medication.dart';
import 'package:vitalguard_mobile/models/enums.dart';
import 'package:vitalguard_mobile/screens/dashboard/dashboard_screen.dart';

class FakePatientService extends PatientService {
  final List<Patient> fakePatients;
  FakePatientService(this.fakePatients, ApiClient c, StorageService s)
      : super(c, s);

  @override
  Future<List<Patient>> getPatients() async => fakePatients;
}

class FakeTreatmentService extends TreatmentService {
  final List<Treatment> fakeTreatments;
  final double fakeAdherence;
  FakeTreatmentService(this.fakeTreatments, this.fakeAdherence, ApiClient c,
      StorageService s)
      : super(c, s);

  @override
  Future<List<Treatment>> getTreatments(int patientId) async => fakeTreatments;

  @override
  Future<double> getAdherence(int patientId) async => fakeAdherence;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildDashboard({
    required List<Patient> patients,
    required List<Treatment> treatments,
    double adherence = 0.0,
  }) {
    final auth = AuthService();
    final apiClient = ApiClient(auth);
    final storage = StorageService();
    final currentService = PatientCurrentService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: currentService),
        Provider<PatientService>.value(
            value: FakePatientService(patients, apiClient, storage)),
        Provider<TreatmentService>.value(
            value: FakeTreatmentService(treatments, adherence, apiClient, storage)),
        ChangeNotifierProvider.value(value: AvatarService()),
        ChangeNotifierProvider.value(value: NotificationService(apiClient)),
      ],
      child: const MaterialApp(
        home: Scaffold(body: DashboardContent()),
      ),
    );
  }

  Patient patient(int id, String first, String last) => Patient(
        id: id,
        firstName: first,
        paternalLastName: last,
        birthDate: DateTime(1990),
        gender: GenderType.f,
      );

  Treatment activeTreatment(DateTime now) {
    final next = now.add(const Duration(hours: 4));
    final schedule = Schedule(
      id: 1,
      treatmentDetailId: 1,
      timeOfDay: next,
      doseInfo: '50 mg',
    );
    final detail = TreatmentDetail(
      id: 1,
      treatmentId: 10,
      medicationId: 1,
      firstTakeTime: now,
      medication: const Medication(id: 1, name: 'Losartán'),
      schedules: [schedule],
    );
    return Treatment(
      id: 10,
      patientId: 1,
      startDate: now.subtract(const Duration(days: 5)),
      endDate: now.add(const Duration(days: 5)),
      status: TreatmentStatus.activo,
      details: [detail],
    );
  }

  testWidgets('cuenta pacientes vinculados (creados + invitados)', (tester) async {
    final now = DateTime.now();
    await tester.pumpWidget(buildDashboard(
      patients: [patient(1, 'Abuela', 'Pérez'), patient(2, 'Tío', 'López')],
      treatments: [activeTreatment(now)],
      adherence: 0.7,
    ));
    await tester.pumpAndSettle();

    expect(find.text('Pacientes'), findsOneWidget);
    expect(find.text('2'), findsWidgets);
    expect(find.text('70%'), findsOneWidget);
    expect(find.text('1'), findsWidgets); // dosis hoy
  });

  testWidgets('no muestra botón SOS en el dashboard', (tester) async {
    final now = DateTime.now();
    await tester.pumpWidget(buildDashboard(
      patients: [patient(1, 'Abuela', 'Pérez')],
      treatments: [activeTreatment(now)],
      adherence: 0.5,
    ));
    await tester.pumpAndSettle();

    expect(find.text('SOS'), findsNothing);
    expect(find.text('Emergencia'), findsNothing);
    expect(find.textContaining('Emergencia'), findsNothing);
  });

  testWidgets('muestra panel de tratamiento con medicamentos y pausar',
      (tester) async {
    final now = DateTime.now();
    await tester.pumpWidget(buildDashboard(
      patients: [patient(1, 'Abuela', 'Pérez')],
      treatments: [activeTreatment(now)],
      adherence: 0.5,
    ));
    await tester.pumpAndSettle();

    expect(find.text('Tratamiento de Abuela Pérez'), findsOneWidget);
    expect(find.text('Losartán'), findsWidgets);
    expect(find.text('Pausar tratamiento'), findsOneWidget);
  });

  testWidgets('muestra próximas dosis y tarjeta de próxima dosis',
      (tester) async {
    final now = DateTime.now();
    await tester.pumpWidget(buildDashboard(
      patients: [patient(1, 'Abuela', 'Pérez')],
      treatments: [activeTreatment(now)],
      adherence: 0.5,
    ));
    await tester.pumpAndSettle();

    expect(find.text('Próxima dosis'), findsWidgets);
    expect(find.text('Próximas Dosis'), findsOneWidget);
  });
}