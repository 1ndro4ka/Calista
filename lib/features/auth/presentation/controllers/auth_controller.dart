import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calista/app/providers/app_providers.dart';
import 'package:calista/features/auth/domain/entities/user_profile.dart';

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final UserProfile? userProfile;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.userProfile,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    UserProfile? userProfile,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      userProfile: userProfile ?? this.userProfile,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(authRepositoryProvider);
      final profile = await repo.login(email: email, password: password);
      state = state.copyWith(isLoading: false, userProfile: profile);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String telegramUsername,
    required List<String> skills,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(authRepositoryProvider);
      final profile = await repo.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        telegramUsername: telegramUsername,
        skills: skills,
      );
      state = state.copyWith(isLoading: false, userProfile: profile);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.sendPasswordResetEmail(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.logout();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
