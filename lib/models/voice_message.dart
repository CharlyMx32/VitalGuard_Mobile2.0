class VoiceMessage {
  final int id;
  final int senderCaregiverId;
  final int patientId;
  final String audioFilePath;
  final bool? isPlayed;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const VoiceMessage({
    required this.id,
    required this.senderCaregiverId,
    required this.patientId,
    required this.audioFilePath,
    this.isPlayed,
    this.createdAt,
    this.updatedAt,
  });

  factory VoiceMessage.fromJson(Map<String, dynamic> json) {
    return VoiceMessage(
      id: json['id'] as int,
      senderCaregiverId: json['senderCaregiverId'] as int,
      patientId: json['patientId'] as int,
      audioFilePath: json['audioFilePath'] as String,
      isPlayed: json['isPlayed'] as bool?,
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
      'senderCaregiverId': senderCaregiverId,
      'patientId': patientId,
      'audioFilePath': audioFilePath,
      if (isPlayed != null) 'isPlayed': isPlayed,
    };
  }
}
