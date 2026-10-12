import 'package:calista/features/projects/domain/entities/project.dart';
import 'package:calista/features/projects/domain/entities/project_member.dart';
import 'package:calista/features/auth/domain/entities/user_profile.dart';

abstract class ProjectRepository {
  /// Stream of new projects ordered by createdAt DESC
  Stream<List<Project>> watchNewProjects({int limit = 50});

  /// Single project stream
  Stream<Project?> watchProjectById(String projectId);

  /// Get project by ID
  Future<Project?> getProjectById(String projectId);

  /// Projects created by current user
  Stream<List<Project>> watchCreatedProjects(String userId);

  /// Projects where current user is a participant (member)
  Stream<List<Project>> watchParticipatingProjects(String userId);

  /// Create project with creator as first member
  Future<Project> createProject({
    required Project project,
    required UserProfile creator,
  });

  /// Update existing project
  Future<void> updateProject(Project project);

  /// Delete project and all associated members and applications
  Future<void> deleteProject(String projectId);

  /// Members of a project
  Stream<List<ProjectMember>> watchProjectMembers(String projectId);

  /// Leave a project (non-owner only)
  Future<void> leaveProject({
    required String projectId,
    required String userId,
    required String userName,
  });

  /// Stream of favorite project IDs for the user
  Stream<Set<String>> watchFavoriteProjectIds(String userId);

  /// Toggle project favorite status
  Future<void> toggleFavorite({
    required String userId,
    required String projectId,
    required bool isFavorite,
  });
}
