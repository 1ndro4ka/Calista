import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:calista/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:calista/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:calista/features/auth/domain/entities/user_profile.dart';
import 'package:calista/features/auth/domain/repositories/auth_repository.dart';

import 'package:calista/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:calista/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:calista/features/profile/domain/repositories/profile_repository.dart';

import 'package:calista/features/projects/data/datasources/project_remote_datasource.dart';
import 'package:calista/features/projects/data/repositories/project_repository_impl.dart';
import 'package:calista/features/projects/domain/repositories/project_repository.dart';

import 'package:calista/features/applications/data/datasources/application_remote_datasource.dart';
import 'package:calista/features/applications/data/repositories/application_repository_impl.dart';
import 'package:calista/features/applications/domain/repositories/application_repository.dart';

import 'package:calista/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:calista/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:calista/features/notifications/domain/repositories/notification_repository.dart';

// Firebase SDK Providers
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final firebaseStorageProvider = Provider<FirebaseStorage>((ref) => FirebaseStorage.instance);

// Data Source Providers
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSourceImpl(
    firestore: ref.watch(firestoreProvider),
    storage: ref.watch(firebaseStorageProvider),
  );
});

final projectRemoteDataSourceProvider = Provider<ProjectRemoteDataSource>((ref) {
  return ProjectRemoteDataSourceImpl(
    firestore: ref.watch(firestoreProvider),
  );
});

final applicationRemoteDataSourceProvider = Provider<ApplicationRemoteDataSource>((ref) {
  return ApplicationRemoteDataSourceImpl(
    firestore: ref.watch(firestoreProvider),
  );
});

final notificationRemoteDataSourceProvider = Provider<NotificationRemoteDataSource>((ref) {
  return NotificationRemoteDataSourceImpl(
    firestore: ref.watch(firestoreProvider),
  );
});

// Repository Providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
  );
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    remoteDataSource: ref.watch(profileRemoteDataSourceProvider),
  );
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepositoryImpl(
    remoteDataSource: ref.watch(projectRemoteDataSourceProvider),
  );
});

final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  return ApplicationRepositoryImpl(
    remoteDataSource: ref.watch(applicationRemoteDataSourceProvider),
  );
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    remoteDataSource: ref.watch(notificationRemoteDataSourceProvider),
  );
});

// Auth State Providers
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateChangesProvider).value?.uid;
});

final currentUserProfileProvider = StreamProvider<UserProfile?>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(profileRepositoryProvider).watchUserProfile(uid);
});

// Favorites Provider
final userFavoritesProvider = StreamProvider<Set<String>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(<String>{});
  return ref.watch(projectRepositoryProvider).watchFavoriteProjectIds(uid);
});

// Notifications Unread Count Provider
final unreadNotificationsCountProvider = StreamProvider<int>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(0);
  return ref.watch(notificationRepositoryProvider).watchUnreadCount(uid);
});

// Pending incoming applications badge count for Applications tab
final pendingApplicationsCountProvider = StreamProvider<int>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(0);
  return ref
      .watch(applicationRepositoryProvider)
      .watchIncomingApplicationsForOwner(uid)
      .map((list) => list.length);
});
