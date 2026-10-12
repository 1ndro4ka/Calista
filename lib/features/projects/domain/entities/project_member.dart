import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectMember {
  final String id;
  final String projectId;
  final String userId;
  final String role; // 'owner' | 'member'
  final DateTime joinedAt;
  final String userName;
  final String userTelegram;
  final List<String> userSkills;
  final String? userAvatarUrl;

  const ProjectMember({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.userName = '',
    this.userTelegram = '',
    this.userSkills = const [],
    this.userAvatarUrl,
  });

  bool get isOwner => role == 'owner';

  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'userId': userId,
      'role': role,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'userName': userName,
      'userTelegram': userTelegram,
      'userSkills': userSkills,
      'userAvatarUrl': userAvatarUrl,
    };
  }

  factory ProjectMember.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ProjectMember.fromMap(data, id: doc.id);
  }

  factory ProjectMember.fromMap(Map<String, dynamic> map, {required String id}) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return ProjectMember(
      id: id,
      projectId: (map['projectId'] as String?) ?? '',
      userId: (map['userId'] as String?) ?? '',
      role: (map['role'] as String?) ?? 'member',
      joinedAt: parseDate(map['joinedAt']),
      userName: (map['userName'] as String?) ?? '',
      userTelegram: (map['userTelegram'] as String?) ?? '',
      userSkills: (map['userSkills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      userAvatarUrl: map['userAvatarUrl'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectMember && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
