import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calista/app/providers/app_providers.dart';
import 'package:calista/features/applications/domain/entities/project_application.dart';

// Incoming applications stream for owner
final incomingApplicationsProvider =
    StreamProvider<List<ProjectApplication>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value([]);
  return ref.watch(applicationRepositoryProvider).watchIncomingApplicationsForOwner(uid);
});

// My submitted applications stream
final myApplicationsProvider =
    StreamProvider<List<ProjectApplication>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value([]);
  return ref.watch(applicationRepositoryProvider).watchMyApplications(uid);
});

// Applications action state controller
class ApplicationActionState {
  final bool isLoading;
  final String? errorMessage;

  const ApplicationActionState({this.isLoading = false, this.errorMessage});

  ApplicationActionState copyWith({bool? isLoading, String? errorMessage}) {
    return ApplicationActionState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ApplicationsController extends Notifier<ApplicationActionState> {
  @override
  ApplicationActionState build() => const ApplicationActionState();

  Future<bool> acceptApplication(ProjectApplication application) async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return false;

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await ref.read(applicationRepositoryProvider).acceptApplication(
            application: application,
            ownerId: uid,
          );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> rejectApplication(ProjectApplication application) async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return false;

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await ref.read(applicationRepositoryProvider).rejectApplication(
            application: application,
            ownerId: uid,
          );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> cancelApplication(String applicationId) async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return false;

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await ref.read(applicationRepositoryProvider).cancelApplication(
            applicationId: applicationId,
            applicantId: uid,
          );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}

final applicationsControllerProvider =
    NotifierProvider<ApplicationsController, ApplicationActionState>(
  ApplicationsController.new,
);
