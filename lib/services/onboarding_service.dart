import 'api_client.dart';
import '../models/enums.dart';
import '../models/onboarding_response.dart';

class OnboardingService {
  final ApiClient _client;

  OnboardingService(this._client);

  Future<OnboardingResponse> completeOnboardingAsPatient({
    required String firstName,
    required String paternalLastName,
    String? maternalLastName,
    required DateTime birthDate,
    required GenderType gender,
    BloodType? bloodType,
    String? medicalNotes,
    String? kinship,
  }) async {
    final response = await _client.post(
      '/app-profiles/onboarding',
      data: {
        'role': 'PATIENT',
        'patientData': {
          'firstName': firstName,
          'paternalLastName': paternalLastName,
          'maternalLastName': ?maternalLastName,
          'birthDate': birthDate.toIso8601String().split('T')[0],
          'gender': gender == GenderType.m ? 'M' : 'F',
          if (bloodType != null) 'bloodType': bloodType.apiValue,
          'medicalNotes': ?medicalNotes,
        },
        'kinship': ?kinship,
      },
    );
    return OnboardingResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<OnboardingResponse> completeOnboardingAsCaregiver() async {
    final response = await _client.post(
      '/app-profiles/onboarding',
      data: {'role': 'CAREGIVER'},
    );
    return OnboardingResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
