import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calista/app/providers/app_providers.dart';
import 'package:calista/features/auth/domain/entities/user_profile.dart';
import 'package:calista/features/projects/domain/entities/project.dart';
import 'package:calista/features/projects/domain/entities/project_member.dart';

// Single Project Provider
final projectDetailsProvider =
    StreamProvider.family<Project?, String>((ref, projectId) {
  return ref.watch(projectRepositoryProvider).watchProjectById(projectId);
});

// Project Members Provider
final projectMembersProvider =
    StreamProvider.family<List<ProjectMember>, String>((ref, projectId) {
  return ref.watch(projectRepositoryProvider).watchProjectMembers(projectId);
});

// Projects Created by Current User Provider
final myCreatedProjectsProvider = StreamProvider<List<Project>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value([]);
  return ref.watch(projectRepositoryProvider).watchCreatedProjects(uid);
});

// Projects where Current User is a Participant Provider
final myParticipatingProjectsProvider = StreamProvider<List<Project>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value([]);
  return ref.watch(projectRepositoryProvider).watchParticipatingProjects(uid);
});

// Project Action Controller (Create, Update, Delete, Leave)
class ProjectActionState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const ProjectActionState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  ProjectActionState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return ProjectActionState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class ProjectActionController extends Notifier<ProjectActionState> {
  @override
  ProjectActionState build() => const ProjectActionState();

  Future<Project?> createProject({
    required String title,
    required String description,
    required String category,
    required List<String> requiredSkills,
    required int maxMembers,
    required DateTime deadline,
    required UserProfile creator,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    try {
      final now = DateTime.now();
      final project = Project(
        id: '',
        ownerId: creator.uid,
        title: title.trim(),
        description: description.trim(),
        category: category,
        requiredSkills: requiredSkills,
        maxMembers: maxMembers,
        memberCount: 1,
        deadline: deadline,
        createdAt: now,
        updatedAt: now,
      );

      final created = await ref.read(projectRepositoryProvider).createProject(
            project: project,
            creator: creator,
          );
      state = state.copyWith(isLoading: false, isSuccess: true);
      return created;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  Future<bool> updateProject(Project project) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    try {
      await ref.read(projectRepositoryProvider).updateProject(project);
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteProject(String projectId) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    try {
      await ref.read(projectRepositoryProvider).deleteProject(projectId);
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> leaveProject({
    required String projectId,
    required String userId,
    required String userName,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    try {
      await ref.read(projectRepositoryProvider).leaveProject(
            projectId: projectId,
            userId: userId,
            userName: userName,
          );
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}

final projectActionControllerProvider =
    NotifierProvider<ProjectActionController, ProjectActionState>(
  ProjectActionController.new,
);
