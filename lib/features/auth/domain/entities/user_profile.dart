import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String firstName;
  final String lastName;
  final String telegramUsername;
  final String? avatarUrl;
  final String? bio;
  final int? course;
  final String? specialty;
  final List<String> skills;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.telegramUsername,
    this.avatarUrl,
    this.bio,
    this.course,
    this.specialty,
    this.skills = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName'.trim();
  String get displayTelegram => '@$telegramUsername';

  UserProfile copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? telegramUsername,
    String? avatarUrl,
    String? bio,
    int? course,
    String? specialty,
    List<String>? skills,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      telegramUsername: telegramUsername ?? this.telegramUsername,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      course: course ?? this.course,
      specialty: specialty ?? this.specialty,
      skills: skills ?? this.skills,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'telegramUsername': telegramUsername,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'course': course,
      'specialty': specialty,
      'skills': skills,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory UserProfile.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserProfile.fromMap(data, id: doc.id);
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return UserProfile(
      uid: (map['uid'] as String?) ?? id ?? '',
      firstName: (map['firstName'] as String?) ?? '',
      lastName: (map['lastName'] as String?) ?? '',
      telegramUsername: (map['telegramUsername'] as String?) ?? '',
      avatarUrl: map['avatarUrl'] as String?,
      bio: map['bio'] as String?,
      course: map['course'] is int
          ? map['course'] as int
          : int.tryParse(map['course']?.toString() ?? ''),
      specialty: map['specialty'] as String?,
      skills: (map['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile && runtimeType == other.runtimeType && uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}
