import 'package:calista/features/auth/domain/entities/user_profile.dart';
import 'package:calista/features/projects/domain/entities/project.dart';
import 'package:calista/features/applications/domain/entities/project_application.dart';

abstract class ApplicationRepository {
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
