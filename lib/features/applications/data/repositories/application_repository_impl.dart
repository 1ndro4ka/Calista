import 'package:calista/core/errors/error_handler.dart';
import 'package:calista/features/auth/domain/entities/user_profile.dart';
import 'package:calista/features/projects/domain/entities/project.dart';
import 'package:calista/features/applications/domain/entities/project_application.dart';
import 'package:calista/features/applications/domain/repositories/application_repository.dart';
import 'package:calista/features/applications/data/datasources/application_remote_datasource.dart';

class ApplicationRepositoryImpl implements ApplicationRepository {
  final ApplicationRemoteDataSource remoteDataSource;

  ApplicationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> submitApplication({
    required Project project,
    required UserProfile applicant,
    String? message,
  }) async {
    try {
      await remoteDataSource.submitApplication(
        project: project,
        applicant: applicant,
        message: message,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> cancelApplication({
    required String applicationId,
    required String applicantId,
  }) async {
    try {
      await remoteDataSource.cancelApplication(
        applicationId: applicationId,
        applicantId: applicantId,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> acceptApplication({
    required ProjectApplication application,
    required String ownerId,
  }) async {
    try {
      await remoteDataSource.acceptApplication(
        application: application,
        ownerId: ownerId,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> rejectApplication({
    required ProjectApplication application,
    required String ownerId,
  }) async {
    try {
      await remoteDataSource.rejectApplication(
        application: application,
        ownerId: ownerId,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Stream<List<ProjectApplication>> watchIncomingApplicationsForOwner(String ownerId) {
    return remoteDataSource.watchIncomingApplicationsForOwner(ownerId);
  }

  @override
  Stream<List<ProjectApplication>> watchMyApplications(String applicantId) {
    return remoteDataSource.watchMyApplications(applicantId);
  }

  @override
  Stream<ProjectApplication?> watchApplicationForProjectAndUser({
    required String projectId,
    required String applicantId,
  }) {
    return remoteDataSource.watchApplicationForProjectAndUser(
      projectId: projectId,
      applicantId: applicantId,
    );
  }
}
