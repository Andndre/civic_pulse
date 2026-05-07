import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final authState = ref.read(authNotifierProvider);
    if (authState.status == AuthStatus.authenticated) {
      final user = authState.user;
      if (user != null) {
        if (authState.needsClassSetup) {
          context.go('/register/setup-class');
        } else if (user.isStudent) {
          context.go('/student/home');
        } else if (user.isTeacher) {
          context.go('/teacher/home');
        } else {
          context.go('/dashboard');
        }
      }
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.radiusXl,
              ),
              child: const Icon(
                Icons.favorite,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            AppSpacing.vGapLg,
            Text(
              'CivicPulse',
              style: AppTypography.displayMedium.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.vGapSm,
            Text(
              'Monitoring PULSE Peserta Didik',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.surface.withValues(alpha: 0.8),
              ),
            ),
            AppSpacing.vGapXxl,
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
            ),
          ],
        ),
      ),
    );
  }
}
