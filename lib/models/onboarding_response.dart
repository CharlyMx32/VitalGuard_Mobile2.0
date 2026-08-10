class OnboardingResponse {
  final String message;
  final int? appProfileId;
  final int? caregiverId;
  final int? patientId;
  final bool isSelfCare;

  const OnboardingResponse({
    required this.message,
    this.appProfileId,
    this.caregiverId,
    this.patientId,
    required this.isSelfCare,
  });

  factory OnboardingResponse.fromJson(Map<String, dynamic> json) {
    return OnboardingResponse(
      message: json['message'] as String,
      appProfileId: json['appProfileId'] as int?,
      caregiverId: json['caregiverId'] as int?,
      patientId: json['patientId'] as int?,
      isSelfCare: json['isSelfCare'] as bool? ?? false,
    );
  }
}
