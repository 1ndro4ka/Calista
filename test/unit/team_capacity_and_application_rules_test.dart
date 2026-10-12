import 'package:flutter_test/flutter_test.dart';
import 'package:calista/features/projects/domain/entities/project.dart';
import 'package:calista/features/applications/domain/entities/project_application.dart';

void main() {
  group('Team Capacity & Application State Rules Tests', () {
    final now = DateTime.now();

    test('Project detects full capacity when memberCount reaches maxMembers', () {
      final project = Project(
        id: 'p1',
        ownerId: 'u1',
        title: 'Тестовый проект',
        description: 'Описание тестового проекта длиной больше 20 символов',
        category: 'Разработка',
        requiredSkills: ['Flutter'],
        maxMembers: 3,
        memberCount: 3,
        deadline: now.add(const Duration(days: 7)),
        createdAt: now,
        updatedAt: now,
        status: 'open',
      );

      expect(project.isFull, isTrue);
      expect(project.canAcceptApplications, isFalse);
    });

    test('Project detects expired deadline', () {
      final project = Project(
        id: 'p2',
        ownerId: 'u1',
        title: 'Истёкший проект',
        description: 'Описание тестового проекта длиной больше 20 символов',
        category: 'Разработка',
        requiredSkills: ['Flutter'],
        maxMembers: 4,
        memberCount: 2,
        deadline: now.subtract(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now,
        status: 'open',
      );

      expect(project.isDeadlineExpired, isTrue);
      expect(project.canAcceptApplications, isFalse);
    });

    test('Open project with available slots and valid deadline can accept applications', () {
      final project = Project(
        id: 'p3',
        ownerId: 'u1',
        title: 'Активный проект',
        description: 'Описание тестового проекта длиной больше 20 символов',
        category: 'Разработка',
        requiredSkills: ['Flutter'],
        maxMembers: 5,
        memberCount: 2,
        deadline: now.add(const Duration(days: 14)),
        createdAt: now,
        updatedAt: now,
        status: 'open',
      );

      expect(project.isFull, isFalse);
      expect(project.isDeadlineExpired, isFalse);
      expect(project.canAcceptApplications, isTrue);
    });

    test('ProjectApplication status flags and labels work properly', () {
      final appPending = ProjectApplication(
        id: 'app1',
        projectId: 'p1',
        projectTitle: 'Проект',
        applicantId: 'u2',
        applicantName: 'Иван Иванов',
        applicantTelegram: 'ivan_dev',
        applicantSkills: ['Dart'],
        status: 'pending',
        createdAt: now,
      );

      expect(appPending.isPending, isTrue);
      expect(appPending.isAccepted, isFalse);
      expect(appPending.statusRussianLabel, equals('Ожидает'));

      final appAccepted = appPending.copyWith(status: 'accepted');
      expect(appAccepted.isAccepted, isTrue);
      expect(appAccepted.statusRussianLabel, equals('Принята'));

      final appRejected = appPending.copyWith(status: 'rejected');
      expect(appRejected.isRejected, isTrue);
      expect(appRejected.statusRussianLabel, equals('Отклонена'));

      final appCancelled = appPending.copyWith(status: 'cancelled');
      expect(appCancelled.isCancelled, isTrue);
      expect(appCancelled.statusRussianLabel, equals('Отменена'));
    });
  });
}
