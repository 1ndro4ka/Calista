import 'package:firebase_auth/firebase_auth.dart';
import 'package:calista/core/errors/app_exception.dart';
import 'package:calista/core/errors/error_handler.dart';
import 'package:calista/core/validators/app_validators.dart';
import 'package:calista/features/auth/domain/entities/user_profile.dart';
import 'package:calista/features/auth/domain/repositories/auth_repository.dart';
import 'package:calista/features/auth/data/datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<User?> get authStateChanges => remoteDataSource.authStateChanges;

  @override
  User? get currentUser => remoteDataSource.currentUser;

  @override
  String? get currentUserId => remoteDataSource.currentUser?.uid;

  @override
  Future<UserProfile> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String telegramUsername,
    required List<String> skills,
  }) async {
    try {
      final credential = await remoteDataSource.registerWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException('Не удалось создать пользователя');
      }

      final now = DateTime.now();
      final profile = UserProfile(
        uid: user.uid,
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        telegramUsername: AppValidators.normalizeTelegram(telegramUsername),
        skills: skills,
        createdAt: now,
        updatedAt: now,
      );

      await remoteDataSource.createUserProfile(profile);
      return profile;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await remoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException('Пользователь не найден');
      }

      final profile = await remoteDataSource.getUserProfile(user.uid);
      if (profile != null) {
        return profile;
      }

      // If user profile doc doesn't exist yet, construct base profile
      final now = DateTime.now();
      final fallbackProfile = UserProfile(
        uid: user.uid,
        firstName: user.displayName?.split(' ').first ?? 'Пользователь',
        lastName: user.displayName?.split(' ').skip(1).join(' ') ?? '',
        telegramUsername: '',
        skills: const [],
        createdAt: now,
        updatedAt: now,
      );
      await remoteDataSource.createUserProfile(fallbackProfile);
      return fallbackProfile;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.signOut();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final uid = currentUserId;
      if (uid == null) return null;
      return await remoteDataSource.getUserProfile(uid);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<UserProfile?> getUserProfileById(String uid) async {
    try {
      return await remoteDataSource.getUserProfile(uid);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
