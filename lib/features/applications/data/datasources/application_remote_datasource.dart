import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:calista/core/errors/app_exception.dart';
import 'package:calista/features/auth/domain/entities/user_profile.dart';
import 'package:calista/features/notifications/domain/entities/app_notification.dart';
import 'package:calista/features/projects/domain/entities/project.dart';
import 'package:calista/features/projects/domain/entities/project_member.dart';
import 'package:calista/features/applications/domain/entities/project_application.dart';

abstract class ApplicationRemoteDataSource {
  Future<void> submitApplication({
    required Project project,
    required UserProfile applicant,
    String? message,
  });

  Future<void> cancelApplication({
    required String applicationId,
    required String applicantId,
  });

  Future<void> acceptApplication({
    required ProjectApplication application,
    required String ownerId,
  });

  Future<void> rejectApplication({
    required ProjectApplication application,
    required String ownerId,
  });

  Stream<List<ProjectApplication>> watchIncomingApplicationsForOwner(String ownerId);
  Stream<List<ProjectApplication>> watchMyApplications(String applicantId);
  Stream<ProjectApplication?> watchApplicationForProjectAndUser({
    required String projectId,
    required String applicantId,
  });
}

class ApplicationRemoteDataSourceImpl implements ApplicationRemoteDataSource {
  final FirebaseFirestore _firestore;

  ApplicationRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> submitApplication({
    required Project project,
    required UserProfile applicant,
    String? message,
  }) async {
    final appId = '${project.id}_${applicant.uid}';
    final appRef = _firestore.collection('applications').doc(appId);
    final projectRef = _firestore.collection('projects').doc(project.id);

    await _firestore.runTransaction((transaction) async {
      // 1. Check existing application
      final appDoc = await transaction.get(appRef);
      if (appDoc.exists) {
        final existingStatus = appDoc.data()?['status'] as String?;
        if (existingStatus == 'pending') {
          throw const DuplicateApplicationException();
        }
      }

      // 2. Check project state
      final projDoc = await transaction.get(projectRef);
      if (!projDoc.exists) {
        throw const NotFoundException('Проект не найден');
      }

      final projData = projDoc.data()!;
      final memberCount = (projData['memberCount'] as num?)?.toInt() ?? 1;
      final maxMembers = (projData['maxMembers'] as num?)?.toInt() ?? 2;
      final status = projData['status'] as String? ?? 'open';
      final deadline = (projData['deadline'] as Timestamp).toDate();

      if (memberCount >= maxMembers || status == 'full') {
        throw const ProjectFullException();
      }

      if (DateTime.now().isAfter(deadline)) {
        throw const DeadlineExpiredException();
      }

      if (projData['ownerId'] == applicant.uid) {
        throw const ValidationException('Вы являетесь создателем этого проекта');
      }

      // 3. Create application
      final now = DateTime.now();
      final application = ProjectApplication(
        id: appId,
        projectId: project.id,
        projectTitle: project.title,
        applicantId: applicant.uid,
        applicantName: applicant.fullName,
        applicantTelegram: applicant.telegramUsername,
        applicantSkills: applicant.skills,
        applicantAvatarUrl: applicant.avatarUrl,
        message: message?.trim(),
        status: 'pending',
        createdAt: now,
      );

      transaction.set(appRef, application.toFirestore());

      // 4. Create internal notification for project owner
      final notifRef = _firestore.collection('notifications').doc();
      final notification = AppNotification(
        id: notifRef.id,
        recipientId: project.ownerId,
        type: 'application_received',
        title: 'Новая заявка',
        body: '${applicant.fullName} подал(а) заявку в проект «${project.title}».',
        projectId: project.id,
        applicationId: appId,
        isRead: false,
        createdAt: now,
      );
      transaction.set(notifRef, notification.toFirestore());
    });
  }

  @override
  Future<void> cancelApplication({
    required String applicationId,
    required String applicantId,
  }) async {
    final appRef = _firestore.collection('applications').doc(applicationId);
    final doc = await appRef.get();
    if (!doc.exists) return;

    if (doc.data()?['applicantId'] != applicantId) {
      throw const PermissionDeniedException('Вы не можете отменить чужую заявку');
    }

    await appRef.update({
      'status': 'cancelled',
      'reviewedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> acceptApplication({
    required ProjectApplication application,
    required String ownerId,
  }) async {
    final appRef = _firestore.collection('applications').doc(application.id);
    final projectRef = _firestore.collection('projects').doc(application.projectId);
    final membershipRef = _firestore
        .collection('project_members')
        .doc('${application.projectId}_${application.applicantId}');

    await _firestore.runTransaction((transaction) async {
      final projDoc = await transaction.get(projectRef);
      if (!projDoc.exists) {
        throw const NotFoundException('Проект не найден');
      }

      final projData = projDoc.data()!;
      if (projData['ownerId'] != ownerId) {
        throw const PermissionDeniedException('Вы не являетесь владельцем этого проекта');
      }

      final memberCount = (projData['memberCount'] as num?)?.toInt() ?? 1;
      final maxMembers = (projData['maxMembers'] as num?)?.toInt() ?? 2;
      final projectTitle = projData['title'] as String? ?? 'Проект';

      if (memberCount >= maxMembers) {
        throw const ProjectFullException('В проекте больше нет свободных мест');
      }

      final newCount = memberCount + 1;
      final newStatus = newCount >= maxMembers ? 'full' : 'open';

      // 1. Update application status
      transaction.update(appRef, {
        'status': 'accepted',
        'reviewedAt': FieldValue.serverTimestamp(),
      });

      // 2. Create membership
      final member = ProjectMember(
        id: '${application.projectId}_${application.applicantId}',
        projectId: application.projectId,
        userId: application.applicantId,
        role: 'member',
        joinedAt: DateTime.now(),
        userName: application.applicantName,
        userTelegram: application.applicantTelegram,
        userSkills: application.applicantSkills,
        userAvatarUrl: application.applicantAvatarUrl,
      );
      transaction.set(membershipRef, member.toFirestore());

      // 3. Increment memberCount & update status
      transaction.update(projectRef, {
        'memberCount': newCount,
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 4. Send notification to applicant
      final notifRef = _firestore.collection('notifications').doc();
      final notification = AppNotification(
        id: notifRef.id,
        recipientId: application.applicantId,
        type: 'application_accepted',
        title: 'Ваша заявка принята',
        body: 'Ваша заявка в проект «$projectTitle» была принята создателем.',
        projectId: application.projectId,
        applicationId: application.id,
        isRead: false,
        createdAt: DateTime.now(),
      );
      transaction.set(notifRef, notification.toFirestore());
    });
  }

  @override
  Future<void> rejectApplication({
    required ProjectApplication application,
    required String ownerId,
  }) async {
    final appRef = _firestore.collection('applications').doc(application.id);
    final projectRef = _firestore.collection('projects').doc(application.projectId);

    await _firestore.runTransaction((transaction) async {
      final projDoc = await transaction.get(projectRef);
      if (!projDoc.exists) return;

      final projData = projDoc.data()!;
      if (projData['ownerId'] != ownerId) {
        throw const PermissionDeniedException('Вы не являетесь владельцем этого проекта');
      }

      final projectTitle = projData['title'] as String? ?? 'Проект';

      // 1. Update application status
      transaction.update(appRef, {
        'status': 'rejected',
        'reviewedAt': FieldValue.serverTimestamp(),
      });

      // 2. Send notification to applicant
      final notifRef = _firestore.collection('notifications').doc();
      final notification = AppNotification(
        id: notifRef.id,
        recipientId: application.applicantId,
        type: 'application_rejected',
        title: 'Заявка отклонена',
        body: 'Создатель проекта «$projectTitle» отклонил вашу заявку.',
        projectId: application.projectId,
        applicationId: application.id,
        isRead: false,
        createdAt: DateTime.now(),
      );
      transaction.set(notifRef, notification.toFirestore());
    });
  }

  @override
  Stream<List<ProjectApplication>> watchIncomingApplicationsForOwner(String ownerId) {
    return _firestore
        .collection('projects')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .asyncMap((projectsSnapshot) async {
          if (projectsSnapshot.docs.isEmpty) return <ProjectApplication>[];

          final projectIds = projectsSnapshot.docs.map((d) => d.id).toList();

          final chunks = <List<String>>[];
          for (var i = 0; i < projectIds.length; i += 30) {
            chunks.add(
              projectIds.sublist(
                i,
                i + 30 > projectIds.length ? projectIds.length : i + 30,
              ),
            );
          }

          final List<ProjectApplication> applications = [];
          for (final chunk in chunks) {
            final appsQuery = await _firestore
                .collection('applications')
                .where('projectId', whereIn: chunk)
                .where('status', isEqualTo: 'pending')
                .get();

            applications.addAll(
              appsQuery.docs.map((doc) => ProjectApplication.fromFirestore(doc)),
            );
          }

          applications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return applications;
        });
  }

  @override
  Stream<List<ProjectApplication>> watchMyApplications(String applicantId) {
    return _firestore
        .collection('applications')
        .where('applicantId', isEqualTo: applicantId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => ProjectApplication.fromFirestore(doc))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  @override
  Stream<ProjectApplication?> watchApplicationForProjectAndUser({
    required String projectId,
    required String applicantId,
  }) {
    final appId = '${projectId}_$applicantId';
    return _firestore.collection('applications').doc(appId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return ProjectApplication.fromFirestore(doc);
    });
  }
}
