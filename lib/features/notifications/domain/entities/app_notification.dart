import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String recipientId;
  final String type; // 'application_received' | 'application_accepted' | 'application_rejected' | 'member_left'
  final String title;
  final String body;
  final String? projectId;
  final String? applicationId;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.recipientId,
    required this.type,
    required this.title,
    required this.body,
    this.projectId,
    this.applicationId,
    this.isRead = false,
    required this.createdAt,
  });

  AppNotification copyWith({
    String? id,
    String? recipientId,
    String? type,
    String? title,
    String? body,
    String? projectId,
    String? applicationId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      projectId: projectId ?? this.projectId,
      applicationId: applicationId ?? this.applicationId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'recipientId': recipientId,
      'type': type,
      'title': title,
      'body': body,
      'projectId': projectId,
      'applicationId': applicationId,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory AppNotification.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AppNotification.fromMap(data, id: doc.id);
  }

  factory AppNotification.fromMap(Map<String, dynamic> map, {required String id}) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return AppNotification(
      id: id,
      recipientId: (map['recipientId'] as String?) ?? '',
      type: (map['type'] as String?) ?? 'system',
      title: (map['title'] as String?) ?? '',
      body: (map['body'] as String?) ?? '',
      projectId: map['projectId'] as String?,
      applicationId: map['applicationId'] as String?,
      isRead: (map['isRead'] as bool?) ?? false,
      createdAt: parseDate(map['createdAt']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppNotification && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
