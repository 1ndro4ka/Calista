import 'dart:io';
import 'package:calista/core/errors/error_handler.dart';
import 'package:calista/features/auth/domain/entities/user_profile.dart';
import 'package:calista/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:calista/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<UserProfile?> watchUserProfile(String uid) {
    return remoteDataSource.watchUserProfile(uid);
  }

  @override
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      return await remoteDataSource.getUserProfile(uid);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await remoteDataSource.updateUserProfile(profile);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<String> uploadAvatar({required String uid, required File file}) async {
    try {
      return await remoteDataSource.uploadAvatar(uid: uid, file: file);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
