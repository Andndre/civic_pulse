import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:civic_pulse/features/auth/data/models/auth_models.dart';
import 'package:civic_pulse/features/auth/data/repositories/auth_repository.dart';
import 'package:civic_pulse/features/auth/presentation/providers/auth_provider.dart';
import 'package:civic_pulse/features/auth/presentation/screens/login_screen.dart';
import 'package:civic_pulse/features/auth/presentation/screens/register_screen.dart';
import 'package:civic_pulse/core/theme/app_theme.dart';

// Create mock repository for testing
class TestMockAuthRepository implements AuthRepositoryInterface {
  @override
  Future<AuthResponse> login(LoginRequest request) async {
    await Future.delayed(const Duration(milliseconds: 100));

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
    await Future.delayed(const Duration(milliseconds: 100));

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
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<User?> getCurrentUser() async {
    return null;
  }

  @override
  Future<String?> joinClass(String classCode) async {
    return classCode;
  }

  @override
  Future<String?> createClass({
    required String name,
    required String gradeCategory,
    required int gradeLevel,
    int? homeroomTeacherId,
  }) async {
    return 'MOCK${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
  }

  @override
  Future<User> updateStudentProfile(int studentId, Map<String, dynamic> data) async {
    return User(
      id: studentId,
      name: data['name'] ?? 'Andi Pratama',
      email: data['email'] ?? 'andi@email.com',
      role: UserRole.student,
      isActive: true,
      createdAt: DateTime.now(),
      dateOfBirth: data['date_of_birth'] as String?,
      parentName: data['parent_name'] as String?,
      parentPhone: data['parent_phone'] as String?,
      phone: data['phone'] as String?,
      address: data['address'] as String?,
      gender: data['gender'] as String?,
    );
  }
}

// Test helper to create the test app with router
Widget createTestApp({required Widget child, required GoRouter router}) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(TestMockAuthRepository()),
    ],
    child: MaterialApp.router(
      theme: AppTheme.lightTheme,
      routerConfig: router,
    ),
  );
}

// Create a router for testing
GoRouter createTestRouter(String initialLocation) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/student/home',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Student Home')),
        ),
      ),
      GoRoute(
        path: '/teacher/home',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Teacher Home')),
        ),
      ),
    ],
  );
}

void main() {
  // Set a larger surface size to ensure all widgets are visible
  const testSurfaceSize = Size(1200, 2000);

  group('Login Screen Tests', () {
    testWidgets('shows login form with email and password fields', (tester) async {
      tester.view.physicalSize = testSurfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(
        child: const LoginScreen(),
        router: createTestRouter('/login'),
      ));
      await tester.pumpAndSettle();

      // Verify form fields exist - find by type and verify we have 2
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Masuk'), findsOneWidget);
    });

    testWidgets('successful login with valid student credentials', (tester) async {
      tester.view.physicalSize = testSurfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(
        child: const LoginScreen(),
        router: createTestRouter('/login'),
      ));
      await tester.pumpAndSettle();

      // Find TextFormFields - email is first, password is second
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'andi@email.com');
      await tester.enterText(textFields.at(1), 'password123');
      await tester.pumpAndSettle();

      // Tap login button
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      // Should navigate to student home
      expect(find.text('Student Home'), findsOneWidget);
    });

    testWidgets('successful login with valid teacher credentials', (tester) async {
      tester.view.physicalSize = testSurfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(
        child: const LoginScreen(),
        router: createTestRouter('/login'),
      ));
      await tester.pumpAndSettle();

      // Find TextFormFields and enter text
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'siti@email.com');
      await tester.enterText(textFields.at(1), 'password123');
      await tester.pumpAndSettle();

      // Tap login button
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      // Should navigate to teacher home
      expect(find.text('Teacher Home'), findsOneWidget);
    });

    testWidgets('failed login with invalid credentials shows error', (tester) async {
      tester.view.physicalSize = testSurfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(
        child: const LoginScreen(),
        router: createTestRouter('/login'),
      ));
      await tester.pumpAndSettle();

      // Enter invalid credentials
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'invalid@email.com');
      await tester.enterText(textFields.at(1), 'wrongpassword');
      await tester.pumpAndSettle();

      // Tap login button
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      // Should show error snackbar
      expect(find.text('Email atau password salah'), findsOneWidget);
    });

    testWidgets('form validation - empty email shows error', (tester) async {
      tester.view.physicalSize = testSurfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(
        child: const LoginScreen(),
        router: createTestRouter('/login'),
      ));
      await tester.pumpAndSettle();

      // Only fill password field
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(1), 'password123');
      await tester.pumpAndSettle();

      // Tap login button
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      // Should show required error
      expect(find.text('Email wajib diisi'), findsOneWidget);
    });

    testWidgets('form validation - invalid email format shows error', (tester) async {
      tester.view.physicalSize = testSurfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(
        child: const LoginScreen(),
        router: createTestRouter('/login'),
      ));
      await tester.pumpAndSettle();

      // Fill with invalid email format (no @)
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'invalidemail.com');
      await tester.enterText(textFields.at(1), 'password123');
      await tester.pumpAndSettle();

      // Tap login button
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      // Should show format error
      expect(find.text('Format email tidak valid'), findsOneWidget);
    });

    testWidgets('form validation - empty password shows error', (tester) async {
      tester.view.physicalSize = testSurfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(
        child: const LoginScreen(),
        router: createTestRouter('/login'),
      ));
      await tester.pumpAndSettle();

      // Only fill email field
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'andi@email.com');
      await tester.pumpAndSettle();

      // Tap login button
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      // Should show required error
      expect(find.text('Password wajib diisi'), findsOneWidget);
    });

    testWidgets('form validation - short password shows error', (tester) async {
      tester.view.physicalSize = testSurfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(
        child: const LoginScreen(),
        router: createTestRouter('/login'),
      ));
      await tester.pumpAndSettle();

      // Fill with short password
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'andi@email.com');
      await tester.enterText(textFields.at(1), '123');
      await tester.pumpAndSettle();

      // Tap login button
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      // Should show min length error
      expect(find.text('Password minimal 6 karakter'), findsOneWidget);
    });

    testWidgets('navigates to register screen when Daftar is tapped', (tester) async {
      tester.view.physicalSize = testSurfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(
        child: const LoginScreen(),
        router: createTestRouter('/login'),
      ));
      await tester.pumpAndSettle();

      // Tap on "Daftar" link
      await tester.tap(find.text('Daftar'));
      await tester.pumpAndSettle();

      // Should navigate to register screen
      expect(find.text('Buat Akun Baru'), findsOneWidget);
    });
  });

  group('Register Screen Tests', () {
    testWidgets('shows register form with all fields', (tester) async {
      tester.view.physicalSize = testSurfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(
        child: const RegisterScreen(),
        router: createTestRouter('/register'),
      ));
      await tester.pumpAndSettle();

      // Verify form fields exist - there are 4 TextFormFields: name, email, password, confirm password
      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(find.text('Daftar Sekarang'), findsOneWidget);
      expect(find.text('Daftar sebagai'), findsOneWidget);
    });

    testWidgets('successful registration navigates to login', (tester) async {
      tester.view.physicalSize = testSurfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(
        child: const RegisterScreen(),
        router: createTestRouter('/register'),
      ));
      await tester.pumpAndSettle();

      // Fill all fields - there are 4 TextFormFields: name, email, password, confirm password
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Test User');
      await tester.enterText(textFields.at(1), 'test@email.com');
      await tester.enterText(textFields.at(2), 'password123');
      await tester.enterText(textFields.at(3), 'password123');
      await tester.pumpAndSettle();

      // Tap register button
      await tester.tap(find.text('Daftar Sekarang'));
      await tester.pumpAndSettle();

      // Should navigate back to login
      expect(find.text('Selamat Datang'), findsOneWidget);
    });

    testWidgets('form validation - empty name shows error', (tester) async {
      tester.view.physicalSize = testSurfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(
        child: const RegisterScreen(),
        router: createTestRouter('/register'),
      ));
      await tester.pumpAndSettle();

      // Fill only email, password, confirm password - leave name empty
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(1), 'test@email.com');
      await tester.enterText(textFields.at(2), 'password123');
      await tester.enterText(textFields.at(3), 'password123');
      await tester.pump();

      // Tap register button
      await tester.tap(find.text('Daftar Sekarang'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should show required error
      expect(find.text('Nama wajib diisi'), findsOneWidget);
    });

    testWidgets('form validation - empty email shows error', (tester) async {
      tester.view.physicalSize = testSurfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(
        child: const RegisterScreen(),
        router: createTestRouter('/register'),
      ));
      await tester.pumpAndSettle();

      // Fill name, password, confirm password - leave email empty
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Test User');
      await tester.enterText(textFields.at(2), 'password123');
      await tester.enterText(textFields.at(3), 'password123');
      await tester.pump();

      // Tap register button
      await tester.tap(find.text('Daftar Sekarang'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should show required error
      expect(find.text('Email wajib diisi'), findsOneWidget);
    });

    testWidgets('form validation - invalid email format shows error', (tester) async {
      tester.view.physicalSize = testSurfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(
        child: const RegisterScreen(),
        router: createTestRouter('/register'),
      ));
      await tester.pumpAndSettle();

      // Fill with invalid email format
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Test User');
      await tester.enterText(textFields.at(1), 'invalidemail.com');
      await tester.enterText(textFields.at(2), 'password123');
      await tester.enterText(textFields.at(3), 'password123');
      await tester.pump();

      // Tap register button
      await tester.tap(find.text('Daftar Sekarang'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should show format error
      expect(find.text('Format email tidak valid'), findsOneWidget);
    });

    testWidgets('form validation - empty password shows error', (tester) async {
      tester.view.physicalSize = testSurfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(
        child: const RegisterScreen(),
        router: createTestRouter('/register'),
      ));
      await tester.pumpAndSettle();

      // Fill name and email only
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Test User');
      await tester.enterText(textFields.at(1), 'test@email.com');
      await tester.pump();

      // Tap register button
      await tester.tap(find.text('Daftar Sekarang'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should show required error
      expect(find.text('Password wajib diisi'), findsOneWidget);
    });

    testWidgets('form validation - short password shows error', (tester) async {
      tester.view.physicalSize = testSurfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(
        child: const RegisterScreen(),
        router: createTestRouter('/register'),
      ));
      await tester.pumpAndSettle();

      // Fill with short password
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Test User');
      await tester.enterText(textFields.at(1), 'test@email.com');
      await tester.enterText(textFields.at(2), '123');
      await tester.enterText(textFields.at(3), '123');
      await tester.pump();

      // Tap register button
      await tester.tap(find.text('Daftar Sekarang'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should show min length error
      expect(find.text('Password minimal 6 karakter'), findsOneWidget);
    });

    testWidgets('form validation - password mismatch shows error', (tester) async {
      tester.view.physicalSize = testSurfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(
        child: const RegisterScreen(),
        router: createTestRouter('/register'),
      ));
      await tester.pumpAndSettle();

      // Fill with mismatching passwords
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Test User');
      await tester.enterText(textFields.at(1), 'test@email.com');
      await tester.enterText(textFields.at(2), 'password123');
      await tester.enterText(textFields.at(3), 'password456');
      await tester.pump();

      // Tap register button
      await tester.tap(find.text('Daftar Sekarang'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should show mismatch error
      expect(find.text('Password tidak cocok'), findsOneWidget);
    });

    testWidgets('role selection shows student and teacher options', (tester) async {
      tester.view.physicalSize = testSurfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(
        child: const RegisterScreen(),
        router: createTestRouter('/register'),
      ));
      await tester.pumpAndSettle();

      // Check that role selection exists - verify icons are present
      expect(find.byIcon(Icons.school_outlined), findsWidgets);
      expect(find.byIcon(Icons.person_outlined), findsWidgets);
    });

    testWidgets('navigates to login screen when Masuk is tapped', (tester) async {
      tester.view.physicalSize = testSurfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(
        child: const RegisterScreen(),
        router: createTestRouter('/register'),
      ));
      await tester.pumpAndSettle();

      // Tap on "Masuk" link
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      // Should navigate to login screen
      expect(find.text('Selamat Datang'), findsOneWidget);
    });
  });

  group('Logout Test', () {
    testWidgets('logout sets state to unauthenticated', (tester) async {
      // Create a Container with the mock repository
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(TestMockAuthRepository()),
        ],
      );

      // Wait for initial build to complete
      await Future.delayed(const Duration(milliseconds: 300));

      // Perform login
      await container.read(authNotifierProvider.notifier).login(
        'andi@email.com',
        'password123',
      );

      // Wait for login to complete
      await Future.delayed(const Duration(milliseconds: 200));
      var state = container.read(authNotifierProvider);
      
      // Login should succeed
      expect(state.status, AuthStatus.authenticated, reason: 'Login should succeed');

      // Perform logout
      await container.read(authNotifierProvider.notifier).logout();

      // Wait for logout to complete
      await Future.delayed(const Duration(milliseconds: 200));
      state = container.read(authNotifierProvider);
      expect(state.status, AuthStatus.unauthenticated);

      // Clean up
      container.dispose();
    });
  });
}