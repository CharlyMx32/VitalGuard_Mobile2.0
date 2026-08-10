import 'package:flutter/foundation.dart';
import '../models/patient.dart';

class PatientCurrentService extends ChangeNotifier {
  Patient? _currentPatient;
  List<Patient> _patients = [];

  Patient? get current => _currentPatient;
  List<Patient> get patients => _patients;
  bool get hasMultiple => _patients.length > 1;
  bool get hasPatient => _currentPatient != null;

  void setPatients(List<Patient> patients) {
    _patients = patients;
    if (_currentPatient == null && patients.isNotEmpty) {
      _currentPatient = patients.first;
      notifyListeners();
    } else if (_currentPatient != null) {
      final stillExists = patients.any((p) => p.id == _currentPatient!.id);
      if (!stillExists) {
        _currentPatient = patients.isNotEmpty ? patients.first : null;
        notifyListeners();
      }
    }
  }

  void selectPatient(Patient patient) {
    if (_currentPatient?.id != patient.id) {
      _currentPatient = patient;
      notifyListeners();
    }
  }

  int? get patientId => _currentPatient?.id;

  int? get patientIdOrSelf => _currentPatient?.id;

  void clear() {
    _currentPatient = null;
    _patients = [];
    notifyListeners();
  }
}
