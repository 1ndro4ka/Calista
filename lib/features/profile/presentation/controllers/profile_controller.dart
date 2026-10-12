import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:calista/app/providers/app_providers.dart';
import 'package:calista/features/auth/domain/entities/user_profile.dart';

class ProfileEditState {
  final bool isLoading;
  final bool isUploadingAvatar;
  final String? errorMessage;
  final bool isSuccess;

  const ProfileEditState({
    this.isLoading = false,
    this.isUploadingAvatar = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  ProfileEditState copyWith({
    bool? isLoading,
    bool? isUploadingAvatar,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return ProfileEditState(
      isLoading: isLoading ?? this.isLoading,
      isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class ProfileController extends Notifier<ProfileEditState> {
  final ImagePicker _picker = ImagePicker();

  @override
  ProfileEditState build() => const ProfileEditState();

  Future<String?> pickAndUploadAvatar(String uid) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      state = state.copyWith(isUploadingAvatar: true, errorMessage: null);

      final file = File(pickedFile.path);
      final downloadUrl = await ref
          .read(profileRepositoryProvider)
          .uploadAvatar(uid: uid, file: file);

      state = state.copyWith(isUploadingAvatar: false);
      return downloadUrl;
    } catch (e) {
      state = state.copyWith(
        isUploadingAvatar: false,
        errorMessage: 'Не удалось загрузить фото профиля: ${e.toString()}',
      );
      return null;
    }
  }

  Future<bool> updateProfile(UserProfile profile) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    try {
      await ref.read(profileRepositoryProvider).updateUserProfile(profile);
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileEditState>(ProfileController.new);
