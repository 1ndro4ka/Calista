import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:calista/features/auth/domain/entities/user_profile.dart';
import 'package:calista/features/notifications/domain/entities/app_notification.dart';
import 'package:calista/features/projects/domain/entities/project.dart';
import 'package:calista/features/projects/domain/entities/project_member.dart';

abstract class ProjectRemoteDataSource {
  Stream<List<Project>> watchNewProjects({int limit = 50});
  Stream<Project?> watchProjectById(String projectId);
  Future<Project?> getProjectById(String projectId);
  Stream<List<Project>> watchCreatedProjects(String userId);
  Stream<List<Project>> watchParticipatingProjects(String userId);
  Future<Project> createProject(Project project, UserProfile creator);
  Future<void> updateProject(Project project);
  Future<void> deleteProject(String projectId);
  Stream<List<ProjectMember>> watchProjectMembers(String projectId);
  Future<void> leaveProject({
    required String projectId,
    required String userId,
    required String userName,
  });
  Stream<Set<String>> watchFavoriteProjectIds(String userId);
  Future<void> toggleFavorite({
    required String userId,
    required String projectId,
    required bool isFavorite,
  });
}

class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final FirebaseFirestore _firestore;

  ProjectRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Project>> watchNewProjects({int limit = 50}) {
    return _firestore
        .collection('projects')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Project.fromFirestore(doc)).toList());
  }

  @override
  Stream<Project?> watchProjectById(String projectId) {
    return _firestore.collection('projects').doc(projectId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return Project.fromFirestore(doc);
    });
  }

  @override
  Future<Project?> getProjectById(String projectId) async {
    final doc = await _firestore.collection('projects').doc(projectId).get();
    if (!doc.exists || doc.data() == null) return null;
    return Project.fromFirestore(doc);
  }

  @override
  Stream<List<Project>> watchCreatedProjects(String userId) {
    return _firestore
        .collection('projects')
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Project.fromFirestore(doc)).toList());
  }

  @override
  Stream<List<Project>> watchParticipatingProjects(String userId) {
    // 1. Get project_members for this user where role == 'member'
    return _firestore
        .collection('project_members')
        .where('userId', isEqualTo: userId)
        .where('role', isEqualTo: 'member')
        .snapshots()
        .asyncMap((membersSnapshot) async {
          if (membersSnapshot.docs.isEmpty) return <Project>[];

          final projectIds = membersSnapshot.docs
              .map((d) => d.data()['projectId'] as String?)
              .whereType<String>()
              .toSet()
              .toList();

          if (projectIds.isEmpty) return <Project>[];

          // Firestore 'whereIn' supports up to 30 items
          final chunks = <List<String>>[];
          for (var i = 0; i < projectIds.length; i += 30) {
            chunks.add(
              projectIds.sublist(
                i,
                i + 30 > projectIds.length ? projectIds.length : i + 30,
              ),
            );
          }

          final List<Project> projects = [];
          for (final chunk in chunks) {
            final query = await _firestore
                .collection('projects')
                .where(FieldPath.documentId, whereIn: chunk)
                .get();
            projects.addAll(query.docs.map((d) => Project.fromFirestore(d)));
          }

          projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return projects;
        });
  }

  @override
  Future<Project> createProject(Project project, UserProfile creator) async {
    final projectRef = _firestore.collection('projects').doc();
    final projectId = projectRef.id;

    final projectWithId = project.copyWith(
      id: projectId,
      ownerId: creator.uid,
      memberCount: 1, // Creator is first member
      status: 'open',
    );

    final membershipId = '${projectId}_${creator.uid}';
    final membershipRef = _firestore.collection('project_members').doc(membershipId);
    final ownerMember = ProjectMember(
      id: membershipId,
      projectId: projectId,
      userId: creator.uid,
      role: 'owner',
      joinedAt: DateTime.now(),
      userName: creator.fullName,
      userTelegram: creator.telegramUsername,
      userSkills: creator.skills,
      userAvatarUrl: creator.avatarUrl,
    );

    final batch = _firestore.batch();
    batch.set(projectRef, projectWithId.toFirestore());
    batch.set(membershipRef, ownerMember.toFirestore());
    await batch.commit();

    return projectWithId;
  }

  @override
  Future<void> updateProject(Project project) async {
    await _firestore
        .collection('projects')
        .doc(project.id)
        .update(project.toFirestore());
  }

  @override
  Future<void> deleteProject(String projectId) async {
    final batch = _firestore.batch();

    // Delete project doc
    batch.delete(_firestore.collection('projects').doc(projectId));

    // Delete related project_members
    final membersQuery = await _firestore
        .collection('project_members')
        .where('projectId', isEqualTo: projectId)
        .get();
    for (final doc in membersQuery.docs) {
      batch.delete(doc.reference);
    }

    // Delete related applications
    final appsQuery = await _firestore
        .collection('applications')
        .where('projectId', isEqualTo: projectId)
        .get();
    for (final doc in appsQuery.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  @override
  Stream<List<ProjectMember>> watchProjectMembers(String projectId) {
    return _firestore
        .collection('project_members')
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) {
          final members =
              snapshot.docs.map((doc) => ProjectMember.fromFirestore(doc)).toList();
          // Sort owners first, then by joinedAt
          members.sort((a, b) {
            if (a.isOwner && !b.isOwner) return -1;
            if (!a.isOwner && b.isOwner) return 1;
            return a.joinedAt.compareTo(b.joinedAt);
          });
          return members;
        });
  }

  @override
  Future<void> leaveProject({
    required String projectId,
    required String userId,
    required String userName,
  }) async {
    final membershipRef =
        _firestore.collection('project_members').doc('${projectId}_$userId');
    final projectRef = _firestore.collection('projects').doc(projectId);

    await _firestore.runTransaction((transaction) async {
      final membershipDoc = await transaction.get(membershipRef);
      if (!membershipDoc.exists) return;

      final role = membershipDoc.data()?['role'] as String?;
      if (role == 'owner') {
        throw StateError('Создатель не может покинуть собственный проект');
      }

      final projectDoc = await transaction.get(projectRef);
      if (!projectDoc.exists) return;

      final currentCount = (projectDoc.data()?['memberCount'] as num?)?.toInt() ?? 1;
      final maxMembers = (projectDoc.data()?['maxMembers'] as num?)?.toInt() ?? 2;
      final newCount = (currentCount - 1).clamp(1, maxMembers);
      final ownerId = projectDoc.data()?['ownerId'] as String?;
      final projectTitle = projectDoc.data()?['title'] as String? ?? 'Проект';

      // 1. Delete member
      transaction.delete(membershipRef);

      // 2. Decrement memberCount & restore open status
      transaction.update(projectRef, {
        'memberCount': newCount,
        'status': 'open',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 3. Notify owner if exists
      if (ownerId != null && ownerId.isNotEmpty) {
        final notifRef = _firestore.collection('notifications').doc();
        final notif = AppNotification(
          id: notifRef.id,
          recipientId: ownerId,
          type: 'member_left',
          title: 'Участник покинул проект',
          body: '$userName покинул(а) проект «$projectTitle».',
          projectId: projectId,
          isRead: false,
          createdAt: DateTime.now(),
        );
        transaction.set(notifRef, notif.toFirestore());
      }
    });
  }

  @override
  Stream<Set<String>> watchFavoriteProjectIds(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toSet());
  }

  @override
  Future<void> toggleFavorite({
    required String userId,
    required String projectId,
    required bool isFavorite,
  }) async {
    final ref = _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(projectId);

    if (isFavorite) {
      await ref.set({
        'projectId': projectId,
        'addedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.delete();
    }
  }
}
