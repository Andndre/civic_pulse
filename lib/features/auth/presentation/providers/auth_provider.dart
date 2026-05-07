import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/data.dart';
import '../../../../core/network/network.dart';

// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Auth State
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final bool needsClassSetup;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.needsClassSetup = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    bool? needsClassSetup,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      needsClassSetup: needsClassSetup ?? this.needsClassSetup,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final response = await _repository.login(
        LoginRequest(email: email, password: password),
      );

      await ApiClient.instance.setToken(response.token);

      // Check if user needs to setup class (teacher) or join class (student)
      final needsSetup = response.user.isTeacher && response.classCode == null;

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.user,
        needsClassSetup: needsSetup,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final response = await _repository.register(
        RegisterRequest(
          name: name,
          email: email,
          password: password,
          role: role,
        ),
      );

      await ApiClient.instance.setToken(response.token);

      // Teachers need to create a class after registration
      final needsSetup = response.user.isTeacher;

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.user,
        needsClassSetup: needsSetup,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } finally {
      await ApiClient.instance.clearToken();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> joinClass(String classCode) async {
    try {
      await _repository.joinClass(classCode);
      state = state.copyWith(needsClassSetup: false);
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message);
    }
  }

  Future<String?> createClass({
    required String name,
    required String gradeCategory,
    required int gradeLevel,
  }) async {
    try {
      final classCode = await _repository.createClass(
        name: name,
        gradeCategory: gradeCategory,
        gradeLevel: gradeLevel,
      );
      state = state.copyWith(needsClassSetup: false);
      return classCode;
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      return null;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void completeClassSetup() {
    state = state.copyWith(needsClassSetup: false);
  }
}

// Auth Notifier Provider
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

// Convenience providers
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authNotifierProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).status == AuthStatus.authenticated;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).status == AuthStatus.loading;
});
