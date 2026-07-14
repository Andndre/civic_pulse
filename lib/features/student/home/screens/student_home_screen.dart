import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/services/services.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../providers/student_providers.dart';
import '../../learning/providers/material_provider.dart';

class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final classesAsync = ref.watch(studentClassesProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        await SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1976D2), // Deeper blue to blend with gradient
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2196F3), // Bright blue
                Color(0xFF1976D2), // Deep blue
              ],
              stops: [0.0, 0.45],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(studentClassesProvider);
                ref.invalidate(materialsProvider);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 28.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo & Avatar Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset(
                                'assets/Logo_civicpulse.png',
                                height: 32,
                                color: Colors.white,
                                colorBlendMode: BlendMode.srcIn,
                                errorBuilder: (context, error, stackTrace) {
                                  return Text(
                                    'CIVIC PULSE',
                                    style: AppTypography.titleLarge.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  );
                                },
                              ),
                              AvatarWidget(
                                imageUrl: user?.avatarUrl,
                                name: user?.name ?? 'Siswa',
                                size: 44,
                                onTap: () => context.go('/student/profile'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          // Dynamic Greeting
                          Text(
                            _getTimeGreeting(),
                            style: AppTypography.bodyLarge.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.name ?? 'Siswa',
                            style: AppTypography.headlineMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 26,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Class Info Badge inside Header
                          classesAsync.when(
                            data: (classes) {
                              if (classes.isEmpty) return const SizedBox.shrink();
                              final activeClass = classes.first;
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.school_rounded,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Kelas ${activeClass.name}',
                                        style: AppTypography.labelSmall.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            loading: () => const SizedBox.shrink(),
                            error: (e, _) => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                    // White Curved Container
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height - 210,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(24.0, 36.0, 24.0, 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // If no class, show empty class warning card
                          classesAsync.when(
                            data: (classes) {
                              if (classes.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 24.0),
                                  child: _buildEmptyClassCard(context, ref),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                            loading: () => const SizedBox.shrink(),
                            error: (e, _) => const SizedBox.shrink(),
                          ),
                          // 6 Main Menu Grid
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 3,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.7,
                            children: [
                              _buildMenuCard(
                                context: context,
                                title: 'E-Learning',
                                iconAsset: 'assets/icons/menu_elearning.svg',
                                onTap: () => context.go('/student/learning'),
                              ),
                              _buildMenuCard(
                                context: context,
                                title: 'Asesmen & Refleksi',
                                iconAsset: 'assets/icons/menu_assessment.svg',
                                onTap: () => context.go('/student/learning'),
                              ),
                              _buildMenuCard(
                                context: context,
                                title: 'Ringkasan Asesmen',
                                iconAsset: 'assets/icons/menu_score_summary.svg',
                                onTap: () => context.go('/student/scores'),
                              ),
                              _buildMenuCard(
                                context: context,
                                title: 'Aktivitas Kewargaan',
                                iconAsset: 'assets/icons/menu_civic_activity.svg',
                                onTap: () => context.go('/student/activities'),
                              ),
                              _buildMenuCard(
                                context: context,
                                title: 'Feedback',
                                iconAsset: 'assets/icons/menu_feedback.svg',
                                onTap: () => context.go('/student/scores'),
                              ),
                              _buildMenuCard(
                                context: context,
                                title: 'Tanya AI',
                                iconAsset: 'assets/icons/menu_ai.svg',
                                isLocked: true,
                                onTap: () => _showLockedAIInfo(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) {
      return 'Selamat pagi,';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat siang,';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat sore,';
    } else {
      return 'Selamat malam,';
    }
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required String iconAsset,
    required VoidCallback onTap,
    bool isLocked = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF0F2F5), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: SvgPicture.asset(iconAsset),
                    ),
                  ),
                  if (isLocked)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD54F),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.lock,
                          size: 9,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 32,
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyClassCard(BuildContext context, WidgetRef ref) {
    return AppCard(
      onTap: () => _showJoinClassBottomSheet(context, ref),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.warningLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school_outlined,
              color: AppColors.warning,
            ),
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Belum Bergabung Kelas',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Tap untuk bergabung dengan kelas',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  void _showLockedAIInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.lock_clock, color: Colors.amber),
            SizedBox(width: 8),
            Text('Tanya AI Terkunci'),
          ],
        ),
        content: const Text(
          'Fitur Tanya AI saat ini belum tersedia atau sedang dinonaktifkan oleh Guru Anda.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  void _showJoinClassBottomSheet(BuildContext context, WidgetRef ref) {
    final codeController = TextEditingController();
    String? errorMessage;
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bergabung dengan Kelas',
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              AppSpacing.vGapMd,
              Text(
                'Masukkan kode kelas yang diberikan oleh guru untuk bergabung dengan kelas.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              AppSpacing.vGapMd,
              AppTextField(
                controller: codeController,
                hint: 'Contoh: VIIA2024',
                label: 'Kode Kelas',
                errorText: errorMessage,
                textCapitalization: TextCapitalization.characters,
                onChanged: (_) {
                  if (errorMessage != null) {
                    setState(() => errorMessage = null);
                  }
                },
              ),
              AppSpacing.vGapMd,
              AppButton(
                label: 'Bergabung',
                loading: isLoading,
                onPressed: () async {
                  final code = codeController.text.trim();
                  if (code.isEmpty) {
                    setState(() => errorMessage = 'Kode Kelas tidak boleh kosong');
                    return;
                  }
                  if (code.length < 6) {
                    setState(() => errorMessage = 'Kode Kelas minimal 6 karakter');
                    return;
                  }

                  setState(() => isLoading = true);

                  try {
                    final classService = ref.read(classServiceProvider);
                    await classService.joinClass(code);
                    ref.invalidate(studentClassesProvider);
                    ref.invalidate(materialsProvider);
                    ref.invalidate(activitiesProvider);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Berhasil bergabung dengan kelas!'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      setState(() {
                        errorMessage = e.toString().replaceAll('Exception: ', '');
                        isLoading = false;
                      });
                    }
                  }
                },
              ),
              AppSpacing.vGapSm,
            ],
          ),
        ),
      ),
    );
  }
}
