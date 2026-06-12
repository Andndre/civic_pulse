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
  bool _delayCompleted = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _checkDelay();
  }

  Future<void> _checkDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _delayCompleted = true;
    });
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    if (_navigated || !_delayCompleted) return;

    final authState = ref.read(authNotifierProvider);

    // Skip redirect if auth status is still checking
    if (authState.status == AuthStatus.initial || authState.status == AuthStatus.loading) {
      return;
    }

    _navigated = true;
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
      } else {
        context.go('/login');
      }
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth state changes so that if check completes after delay, we transition immediately
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      _navigateToNextScreen();
    });

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: SafeImageAsset(
          'assets/splash_screen.png',
          width: 140,
          height: 140,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
