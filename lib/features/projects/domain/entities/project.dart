import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final String category;
  final List<String> requiredSkills;
  final int maxMembers;
  final int memberCount;
  final DateTime deadline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status; // 'open' | 'full' | 'closed'

  const Project({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.category,
    required this.requiredSkills,
    required this.maxMembers,
    required this.memberCount,
    required this.deadline,
    required this.createdAt,
    required this.updatedAt,
    this.status = 'open',
  });

  bool get isFull => memberCount >= maxMembers || status == 'full';
  bool get isClosed => status == 'closed';
  bool get isDeadlineExpired {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final deadlineStart = DateTime(deadline.year, deadline.month, deadline.day);
    return deadlineStart.isBefore(todayStart);
  }

  bool get canAcceptApplications => !isFull && !isClosed && !isDeadlineExpired;

  Project copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    String? category,
    List<String>? requiredSkills,
    int? maxMembers,
    int? memberCount,
    DateTime? deadline,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
  }) {
    return Project(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      maxMembers: maxMembers ?? this.maxMembers,
      memberCount: memberCount ?? this.memberCount,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'category': category,
      'requiredSkills': requiredSkills,
      'maxMembers': maxMembers,
      'memberCount': memberCount,
      'deadline': Timestamp.fromDate(deadline),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'status': status,
    };
  }

  factory Project.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Project.fromMap(data, id: doc.id);
  }

  factory Project.fromMap(Map<String, dynamic> map, {required String id}) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return Project(
      id: id,
      ownerId: (map['ownerId'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      category: (map['category'] as String?) ?? '',
      requiredSkills:
          (map['requiredSkills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      maxMembers: (map['maxMembers'] as num?)?.toInt() ?? 2,
      memberCount: (map['memberCount'] as num?)?.toInt() ?? 1,
      deadline: parseDate(map['deadline']),
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
      status: (map['status'] as String?) ?? 'open',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Project && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
