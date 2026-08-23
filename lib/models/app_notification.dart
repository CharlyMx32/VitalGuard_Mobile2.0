import 'enums.dart';
import 'patient.dart';

class AppNotification {
  final int id;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final Patient? patient;
  final DateTime? createdAt;
  final Map<String, dynamic>? metadata;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    this.patient,
    this.createdAt,
    this.metadata,
  });

  int? get invitationId {
    final v = metadata?['invitation_id'] ?? metadata?['invitationId'];
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as int,
      title: json['title'] as String,
      message: json['message'] as String,
      type: NotificationType.fromApi(json['type'] as String),
      isRead: json['isRead'] as bool? ?? json['is_read'] as bool? ?? false,
      patient: json['patients'] != null
          ? Patient.fromJson(json['patients'] as Map<String, dynamic>)
          : json['patient'] != null
              ? Patient.fromJson(json['patient'] as Map<String, dynamic>)
              : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'message': message,
      'type': type.apiValue,
    };
  }
}
