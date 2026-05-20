import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/data.dart';
import '../../../../core/network/network.dart';

// Toggle this to switch between mock and real API
const bool _useMockData = false;

// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepositoryInterface>((ref) {
  if (_useMockData) {
    return MockAuthRepository();
  }
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

      if (!_useMockData) {
        await ApiClient.instance.setToken(response.token);
      }

      // After login, go to home page directly - class setup will be handled separately
      // when teacher chooses to create a class from home page
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.user,
        needsClassSetup: false,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
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

      if (!_useMockData) {
        await ApiClient.instance.setToken(response.token);
      }

      // After successful registration, reset to unauthenticated 
      // so user goes to login page instead of directly to home/dashboard
      // User must login with their new credentials
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } finally {
      if (!_useMockData) {
        await ApiClient.instance.clearToken();
      }
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> joinClass(String classCode) async {
    try {
      await _repository.joinClass(classCode);
      state = state.copyWith(needsClassSetup: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
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
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
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

// =============================================================================
// MOCK AUTH REPOSITORY
// =============================================================================

class MockAuthRepository implements AuthRepositoryInterface {
  @override
  Future<AuthResponse> login(LoginRequest request) async {
    debugPrint('[MOCK] Login attempt: ${request.email}');
    await Future.delayed(const Duration(milliseconds: 500));

    if (request.email == 'andi@email.com' && request.password == 'password123') {
      return AuthResponse(
        token: 'mock_student_token_123',
        user: User(
          id: 1,
          name: 'Andi Pratama',
          email: request.email,
          role: UserRole.student,
          isActive: true,
          createdAt: DateTime.now(),
        ),
      );
    }

    if (request.email == 'siti@email.com' && request.password == 'password123') {
      return AuthResponse(
        token: 'mock_teacher_token_456',
        user: User(
          id: 2,
          name: 'Bu Siti Rahayu',
          email: request.email,
          role: UserRole.teacher,
          isActive: true,
          createdAt: DateTime.now(),
        ),
        classCode: 'VIIA2024',
      );
    }

    throw Exception('Email atau password salah');
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    debugPrint('[MOCK] Register: ${request.name} as ${request.role}');
    await Future.delayed(const Duration(milliseconds: 500));

    final userRole = request.role == 'teacher' ? UserRole.teacher : UserRole.student;

    return AuthResponse(
      token: 'mock_register_token_${DateTime.now().millisecondsSinceEpoch}',
      user: User(
        id: 100,
        name: request.name,
        email: request.email,
        role: userRole,
        isActive: true,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<User?> getCurrentUser() async {
    return null; // Mock doesn't persist session
  }

  @override
  Future<String?> joinClass(String classCode) async {
    debugPrint('[MOCK] Join class: $classCode');
    await Future.delayed(const Duration(milliseconds: 400));
    return classCode;
  }

  @override
  Future<String?> createClass({
    required String name,
    required String gradeCategory,
    required int gradeLevel,
  }) async {
    debugPrint('[MOCK] Create class: $name ($gradeCategory $gradeLevel)');
    await Future.delayed(const Duration(milliseconds: 400));
    return 'MOCK${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
  }
}
