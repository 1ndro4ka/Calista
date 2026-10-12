import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectApplication {
  final String id;
  final String projectId;
  final String projectTitle;
  final String applicantId;
  final String applicantName;
  final String applicantTelegram;
  final List<String> applicantSkills;
  final String? applicantAvatarUrl;
  final String? message;
  final String status; // 'pending' | 'accepted' | 'rejected' | 'cancelled'
  final DateTime createdAt;
  final DateTime? reviewedAt;

  const ProjectApplication({
    required this.id,
    required this.projectId,
    required this.projectTitle,
    required this.applicantId,
    required this.applicantName,
    required this.applicantTelegram,
    required this.applicantSkills,
    this.applicantAvatarUrl,
    this.message,
    this.status = 'pending',
    required this.createdAt,
    this.reviewedAt,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  bool get isCancelled => status == 'cancelled';

  String get statusRussianLabel {
    switch (status) {
      case 'accepted':
        return 'Принята';
      case 'rejected':
        return 'Отклонена';
      case 'cancelled':
        return 'Отменена';
      case 'pending':
      default:
        return 'Ожидает';
    }
  }

  ProjectApplication copyWith({
    String? id,
    String? projectId,
    String? projectTitle,
    String? applicantId,
    String? applicantName,
    String? applicantTelegram,
    List<String>? applicantSkills,
    String? applicantAvatarUrl,
    String? message,
    String? status,
    DateTime? createdAt,
    DateTime? reviewedAt,
  }) {
    return ProjectApplication(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      projectTitle: projectTitle ?? this.projectTitle,
      applicantId: applicantId ?? this.applicantId,
      applicantName: applicantName ?? this.applicantName,
      applicantTelegram: applicantTelegram ?? this.applicantTelegram,
      applicantSkills: applicantSkills ?? this.applicantSkills,
      applicantAvatarUrl: applicantAvatarUrl ?? this.applicantAvatarUrl,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'projectTitle': projectTitle,
      'applicantId': applicantId,
      'applicantName': applicantName,
      'applicantTelegram': applicantTelegram,
      'applicantSkills': applicantSkills,
      'applicantAvatarUrl': applicantAvatarUrl,
      'message': message,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
    };
  }

  factory ProjectApplication.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ProjectApplication.fromMap(data, id: doc.id);
  }

  factory ProjectApplication.fromMap(Map<String, dynamic> map, {required String id}) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return ProjectApplication(
      id: id,
      projectId: (map['projectId'] as String?) ?? '',
      projectTitle: (map['projectTitle'] as String?) ?? '',
      applicantId: (map['applicantId'] as String?) ?? '',
      applicantName: (map['applicantName'] as String?) ?? '',
      applicantTelegram: (map['applicantTelegram'] as String?) ?? '',
      applicantSkills:
          (map['applicantSkills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      applicantAvatarUrl: map['applicantAvatarUrl'] as String?,
      message: map['message'] as String?,
      status: (map['status'] as String?) ?? 'pending',
      createdAt: parseDate(map['createdAt']),
      reviewedAt: map['reviewedAt'] != null ? parseDate(map['reviewedAt']) : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectApplication && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
