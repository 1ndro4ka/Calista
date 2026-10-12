import 'package:firebase_auth/firebase_auth.dart';
import '../entities/user_profile.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  String? get currentUserId;

  Future<UserProfile> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String telegramUsername,
    required List<String> skills,
  });

  Future<UserProfile> login({
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<void> logout();

  Future<UserProfile?> getCurrentUserProfile();

  Future<UserProfile?> getUserProfileById(String uid);
}
