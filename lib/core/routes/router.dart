import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/class_setup_screen.dart';
import '../../features/student/home/screens/student_home_screen.dart';
import '../../features/student/learning/screens/learning_gallery_screen.dart';
import '../../features/student/learning/screens/learning_path_screen.dart';
import '../../features/student/activities/screens/activity_log_screen.dart';
import '../../features/student/activities/screens/add_activity_screen.dart';
import '../../features/student/scores/screens/scores_feedback_screen.dart';
import '../../features/student/profile/screens/student_profile_screen.dart';
import '../../features/teacher/home/screens/teacher_home_screen.dart';
import '../../features/teacher/class_detail/screens/class_detail_screen.dart';
import '../../features/teacher/student_profile/screens/student_profile_screen.dart';
import '../../features/teacher/profile/screens/teacher_profile_screen.dart';
import 'app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  // Track previous auth status to detect new login/register
  bool wasPreviouslyLoggedIn = false;

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.status == AuthStatus.authenticated;
      final isLoading = authState.status == AuthStatus.loading ||
          authState.status == AuthStatus.initial;
      final location = state.matchedLocation;

      // Skip redirect while loading
      if (isLoading) return null;

      // Auth routes
      final isAuthRoute = location == '/splash' ||
          location == '/login' ||
          location == '/register';

      // Not logged in - redirect to login
      if (!isLoggedIn && !isAuthRoute) {
        wasPreviouslyLoggedIn = false;
        return '/login';
      }

      // Logged in but on auth route - redirect to appropriate home
      // BUT: If user just registered (was not logged in before), stay on login
      if (isLoggedIn && isAuthRoute) {
        // If this is a fresh login/register (was not logged in before), go to login
        // This prevents redirect loop after registration
        if (!wasPreviouslyLoggedIn) {
          wasPreviouslyLoggedIn = true;
          return '/login';
        }

        final user = authState.user;
        if (user != null) {
          // Check if needs class setup
          if (authState.needsClassSetup) {
            return '/register/setup-class';
          }
          // Route based on role
          if (user.isStudent) return '/student/home';
          if (user.isTeacher) return '/teacher/home';
          if (user.isAdmin) return '/dashboard';
        }
        return '/login';
      }

      // Reset flag when navigating away from auth routes
      if (!isAuthRoute) {
        wasPreviouslyLoggedIn = false;
      }

      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/register/setup-class',
        builder: (context, state) => const ClassSetupScreen(),
      ),

      // Student Routes (with shell)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/student/home',
            builder: (context, state) => const StudentHomeScreen(),
          ),
          GoRoute(
            path: '/student/learning',
            builder: (context, state) => const LearningGalleryScreen(),
          ),
          GoRoute(
            path: '/student/learning/:id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
              return LearningPathScreen(materialId: id);
            },
          ),
          GoRoute(
            path: '/student/activities',
            builder: (context, state) => const ActivityLogScreen(),
          ),
          GoRoute(
            path: '/student/activities/add',
            builder: (context, state) => const AddActivityScreen(),
          ),
          GoRoute(
            path: '/student/scores',
            builder: (context, state) => const ScoresFeedbackScreen(),
          ),
          GoRoute(
            path: '/student/profile',
            builder: (context, state) => const StudentProfileScreen(),
          ),
        ],
      ),

      // Teacher Routes (with shell)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/teacher/home',
            builder: (context, state) => const TeacherHomeScreen(),
          ),
          GoRoute(
            path: '/teacher/class/:id',
            builder: (context, state) {
              final classId = state.pathParameters['id']!;
              return ClassDetailScreen(classId: classId);
            },
          ),
          GoRoute(
            path: '/teacher/class/:classId/students/:studentId',
            builder: (context, state) {
              final classId = state.pathParameters['classId']!;
              final studentId = state.pathParameters['studentId']!;
              return TeacherStudentProfileScreen(
                classId: classId,
                studentId: studentId,
              );
            },
          ),
          GoRoute(
            path: '/teacher/profile',
            builder: (context, state) => const TeacherProfileScreen(),
          ),
        ],
      ),
    ],
  );
});
