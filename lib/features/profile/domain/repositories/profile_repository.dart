import 'dart:io';
import 'package:calista/features/auth/domain/entities/user_profile.dart';

abstract class ProfileRepository {
  Stream<UserProfile?> watchUserProfile(String uid);
  Future<UserProfile?> getUserProfile(String uid);
  Future<void> updateUserProfile(UserProfile profile);
  Future<String> uploadAvatar({required String uid, required File file});
}
