import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/landing_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/class_setup_screen.dart';
import '../../features/student/home/screens/student_home_screen.dart';
import '../../features/student/learning/screens/learning_gallery_screen.dart';
import '../../features/student/learning/screens/learning_path_screen.dart';
import '../../features/student/activities/screens/activity_log_screen.dart';
import '../../features/student/activities/screens/add_activity_screen.dart';
import '../../features/student/activities/screens/activity_detail_screen.dart';
import '../../features/student/activities/screens/edit_activity_screen.dart';
import '../../features/student/scores/screens/scores_feedback_screen.dart';
import '../../features/student/profile/screens/student_profile_screen.dart';
import '../../features/student/profile/screens/edit_profile_screen.dart';
import '../../features/teacher/home/screens/teacher_home_screen.dart';
import '../../features/teacher/home/screens/manage_materials_screen.dart';
import '../../features/teacher/home/screens/social_challenges_review_screen.dart';
import '../../features/teacher/home/screens/teacher_material_editor_screen.dart';
import '../../features/teacher/class_detail/screens/class_detail_screen.dart';
import '../../features/teacher/student_profile/screens/student_profile_screen.dart';
import '../../features/teacher/profile/screens/teacher_profile_screen.dart';
import '../../features/teacher/profile/screens/edit_profile_screen.dart';
import 'app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class RouterTransitionNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterTransitionNotifier(this._ref) {
    _ref.listen(
      authNotifierProvider,
      (previous, next) {
        if (previous?.status != next.status || previous?.needsClassSetup != next.needsClassSetup) {
          notifyListeners();
        }
      },
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final listenable = RouterTransitionNotifier(ref);
  ref.onDispose(() => listenable.dispose());

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: listenable,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final isLoggedIn = authState.status == AuthStatus.authenticated;
      final isLoading = authState.status == AuthStatus.loading ||
          authState.status == AuthStatus.initial;
      final location = state.matchedLocation;

      // Skip redirect while loading
      if (isLoading) return null;

      // Auth routes
      final isAuthRoute = location == '/splash' ||
          location == '/landing' ||
          location == '/login' ||
          location == '/register';

      // Not logged in - redirect to login
      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      // Logged in but on auth route - redirect to appropriate home
      if (isLoggedIn && isAuthRoute) {
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

      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/landing',
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const LandingScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: '/register/setup-class',
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const ClassSetupScreen(),
        ),
      ),

      // Student Routes (with shell)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/student/home',
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const StudentHomeScreen(),
            ),
          ),
          GoRoute(
            path: '/student/learning',
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const LearningGalleryScreen(),
            ),
          ),
          GoRoute(
            path: '/student/learning/:id',
            pageBuilder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
              return NoTransitionPage<void>(
                key: state.pageKey,
                child: LearningPathScreen(materialId: id),
              );
            },
          ),
          GoRoute(
            path: '/student/activities',
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const ActivityLogScreen(),
            ),
          ),
          GoRoute(
            path: '/student/activities/add',
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const AddActivityScreen(),
            ),
          ),
          GoRoute(
            path: '/student/activities/:id',
            pageBuilder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
              return NoTransitionPage<void>(
                key: state.pageKey,
                child: ActivityDetailScreen(activityId: id),
              );
            },
          ),
          GoRoute(
            path: '/student/activities/:id/edit',
            pageBuilder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
              return NoTransitionPage<void>(
                key: state.pageKey,
                child: EditActivityScreen(activityId: id),
              );
            },
          ),
          GoRoute(
            path: '/student/scores',
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const ScoresFeedbackScreen(),
            ),
          ),
          GoRoute(
            path: '/student/profile',
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const StudentProfileScreen(),
            ),
          ),
          GoRoute(
            path: '/student/profile/edit',
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const EditProfileScreen(),
            ),
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
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const TeacherHomeScreen(),
            ),
          ),
          GoRoute(
            path: '/teacher/social-challenges/review',
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const SocialChallengesReviewScreen(),
            ),
          ),
          GoRoute(
            path: '/teacher/class/:id',
            pageBuilder: (context, state) {
              final classId = state.pathParameters['id']!;
              return NoTransitionPage<void>(
                key: state.pageKey,
                child: ClassDetailScreen(classId: classId),
              );
            },
          ),
          GoRoute(
            path: '/teacher/class/:classId/materials',
            pageBuilder: (context, state) {
              final classId = int.tryParse(state.pathParameters['classId'] ?? '0') ?? 0;
              return NoTransitionPage<void>(
                key: state.pageKey,
                child: ManageMaterialsScreen(classId: classId),
              );
            },
          ),
          GoRoute(
            path: '/teacher/class/:classId/materials/:materialId/edit',
            pageBuilder: (context, state) {
              final classId = int.tryParse(state.pathParameters['classId'] ?? '0') ?? 0;
              final materialId = int.tryParse(state.pathParameters['materialId'] ?? '0') ?? 0;
              return NoTransitionPage<void>(
                key: state.pageKey,
                child: TeacherMaterialEditorScreen(
                  classId: classId,
                  materialId: materialId,
                ),
              );
            },
          ),
          GoRoute(
            path: '/teacher/class/:classId/students/:studentId',
            pageBuilder: (context, state) {
              final classId = state.pathParameters['classId']!;
              final studentId = state.pathParameters['studentId']!;
              return NoTransitionPage<void>(
                key: state.pageKey,
                child: TeacherStudentProfileScreen(
                  classId: classId,
                  studentId: studentId,
                ),
              );
            },
          ),
          GoRoute(
            path: '/teacher/activities/:id',
            pageBuilder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
              return NoTransitionPage<void>(
                key: state.pageKey,
                child: ActivityDetailScreen(activityId: id),
              );
            },
          ),
          GoRoute(
            path: '/teacher/profile',
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const TeacherProfileScreen(),
            ),
          ),
          GoRoute(
            path: '/teacher/profile/edit',
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const EditTeacherProfileScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});
