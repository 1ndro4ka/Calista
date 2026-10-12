import 'package:calista/core/errors/error_handler.dart';
import 'package:calista/features/auth/domain/entities/user_profile.dart';
import 'package:calista/features/projects/domain/entities/project.dart';
import 'package:calista/features/projects/domain/entities/project_member.dart';
import 'package:calista/features/projects/domain/repositories/project_repository.dart';
import 'package:calista/features/projects/data/datasources/project_remote_datasource.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource remoteDataSource;

  ProjectRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<Project>> watchNewProjects({int limit = 50}) {
    return remoteDataSource.watchNewProjects(limit: limit);
  }

  @override
  Stream<Project?> watchProjectById(String projectId) {
    return remoteDataSource.watchProjectById(projectId);
  }

  @override
  Future<Project?> getProjectById(String projectId) async {
    try {
      return await remoteDataSource.getProjectById(projectId);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Stream<List<Project>> watchCreatedProjects(String userId) {
    return remoteDataSource.watchCreatedProjects(userId);
  }

  @override
  Stream<List<Project>> watchParticipatingProjects(String userId) {
    return remoteDataSource.watchParticipatingProjects(userId);
  }

  @override
  Future<Project> createProject({
    required Project project,
    required UserProfile creator,
  }) async {
    try {
      return await remoteDataSource.createProject(project, creator);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> updateProject(Project project) async {
    try {
      await remoteDataSource.updateProject(project);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> deleteProject(String projectId) async {
    try {
      await remoteDataSource.deleteProject(projectId);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Stream<List<ProjectMember>> watchProjectMembers(String projectId) {
    return remoteDataSource.watchProjectMembers(projectId);
  }

  @override
  Future<void> leaveProject({
    required String projectId,
    required String userId,
    required String userName,
  }) async {
    try {
      await remoteDataSource.leaveProject(
        projectId: projectId,
        userId: userId,
        userName: userName,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Stream<Set<String>> watchFavoriteProjectIds(String userId) {
    return remoteDataSource.watchFavoriteProjectIds(userId);
  }

  @override
  Future<void> toggleFavorite({
    required String userId,
    required String projectId,
    required bool isFavorite,
  }) async {
    try {
      await remoteDataSource.toggleFavorite(
        userId: userId,
        projectId: projectId,
        isFavorite: isFavorite,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
