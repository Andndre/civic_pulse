import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/data.dart';
import '../../../../core/network/network.dart';

// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepositoryInterface>((ref) {
  return AuthRepository();
});

// Auth State
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final Map<String, String> fieldErrors;
  final bool needsClassSetup;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.fieldErrors = const {},
    this.needsClassSetup = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    bool? needsClassSetup,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      needsClassSetup: needsClassSetup ?? this.needsClassSetup,
    );
  }
}

// Auth Notifier - Riverpod 3.x Notifier pattern
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _checkAuthStatus();
    return const AuthState();
  }

  AuthRepositoryInterface get _repository => ref.read(authRepositoryProvider);

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

      // After login, go to home page directly - class setup will be handled separately
      // when teacher chooses to create a class from home page
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.user,
        fieldErrors: const {},
        needsClassSetup: false,
      );
    } catch (e) {
      Map<String, String> fieldErrors = {};
      if (e is ApiException) {
        fieldErrors = e.fieldErrors;
      }
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _formatError(e),
        fieldErrors: fieldErrors,
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

      // After successful registration, reset to unauthenticated 
      // so user goes to login page instead of directly to home/dashboard
      // User must login with their new credentials
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      Map<String, String> fieldErrors = {};
      if (e is ApiException) {
        fieldErrors = e.fieldErrors;
      }
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _formatError(e),
        fieldErrors: fieldErrors,
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
    } catch (e) {
      state = state.copyWith(errorMessage: _formatError(e));
    }
  }

  Future<String?> createClass({
    required String name,
    required String gradeCategory,
    required int gradeLevel,
  }) async {
    try {
      final user = state.user;
      final classCode = await _repository.createClass(
        name: name,
        gradeCategory: gradeCategory,
        gradeLevel: gradeLevel,
        homeroomTeacherId: user?.id,
      );
      state = state.copyWith(needsClassSetup: false);
      return classCode;
    } catch (e) {
      state = state.copyWith(errorMessage: _formatError(e));
      return null;
    }
  }

  String _formatError(Object e) {
    final str = e.toString();
    if (str.startsWith('Exception: ')) {
      return str.substring(11);
    }
    return str;
  }

  void clearError() {
    state = state.copyWith(
      errorMessage: null,
      fieldErrors: const {},
    );
  }

  void completeClassSetup() {
    state = state.copyWith(needsClassSetup: false);
  }

  Future<bool> updateProfile({
    required String name,
    String? dateOfBirth,
    String? parentName,
    String? parentPhone,
    String? phone,
    String? address,
    String? gender,
  }) async {
    final currentStudent = state.user;
    if (currentStudent == null) {
      state = state.copyWith(errorMessage: 'Pengguna tidak ditemukan');
      return false;
    }
    
    try {
      final updatedUser = await _repository.updateStudentProfile(
        currentStudent.id,
        {
          'name': name,
          'date_of_birth': dateOfBirth,
          'parent_name': parentName,
          'parent_phone': parentPhone,
          'phone': phone,
          'address': address,
          'gender': gender,
        },
      );
      state = state.copyWith(
        user: updatedUser,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: _formatError(e),
      );
      return false;
    }
  }
}

// Auth Notifier Provider
final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

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


