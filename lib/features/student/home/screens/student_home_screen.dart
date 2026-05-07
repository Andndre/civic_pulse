import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../shared/services/mock_models.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../providers/student_providers.dart';
import '../../learning/providers/material_provider.dart';

class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final classesAsync = ref.watch(studentClassesProvider);
    final materialsAsync = ref.watch(materialsProvider);
    final progressAsync = ref.watch(studentProgressProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(studentClassesProvider);
            ref.invalidate(materialsProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(context, user?.name ?? 'Siswa'),
                AppSpacing.vGapLg,

                // Class Card
                classesAsync.when(
                  data: (classes) => classes.isEmpty
                      ? _buildEmptyClassCard(context)
                      : _buildClassCard(classes.first),
                  loading: () => const ShimmerBox(height: 100),
                  error: (e, _) => _buildErrorCard(e.toString()),
                ),
                AppSpacing.vGapLg,

                // Progress Section
                Text(
                  'Progress Belajar',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppSpacing.vGapMd,
                progressAsync.when(
                  data: (progress) {
                    final completed = progress.where((p) => p.pulseStatus == 'completed').length;
                    return ProgressCard(
                      title: 'Materi Diselesaikan',
                      current: completed,
                      total: progress.length,
                      subtitle: completed == progress.length
                          ? 'Semua materi sudah diselesaikan!'
                          : '${progress.length - completed} materi belum diselesaikan',
                    );
                  },
                  loading: () => const ShimmerBox(height: 120),
                  error: (e, _) => const SizedBox.shrink(),
                ),
                AppSpacing.vGapLg,

                // Recent Materials
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Materi Terbaru',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/student/learning'),
                      child: Text(
                        'Lihat Semua',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.vGapSm,
                materialsAsync.when(
                  data: (materials) => Column(
                    children: materials.take(3).map((m) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _MaterialListTile(
                          title: m.title,
                          subtitle: '${m.gradeCategory} Kelas ${m.gradeLevel}',
                          duration: m.estimatedDuration,
                          onTap: () => context.go('/student/learning/${m.id}'),
                        ),
                      );
                    }).toList(),
                  ),
                  loading: () => const Column(
                    children: [
                      ShimmerListTile(),
                      ShimmerListTile(),
                    ],
                  ),
                  error: (e, _) => Center(
                    child: Text(
                      'Gagal memuat materi',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Selamat Pagi';
    } else if (hour < 17) {
      greeting = 'Selamat Siang';
    } else {
      greeting = 'Selamat Sore';
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                name,
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        AvatarWidget(
          name: name,
          size: 48,
          onTap: () => context.go('/student/profile'),
        ),
      ],
    );
  }

  Widget _buildEmptyClassCard(BuildContext context) {
    return AppCard(
      onTap: () => context.go('/register/setup-class'),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.warningLight,
              borderRadius: AppRadius.radiusMd,
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
            size: 16,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(StudentClass studentClass) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.2),
              borderRadius: AppRadius.radiusMd,
            ),
            child: const Icon(
              Icons.class_,
              color: AppColors.primary,
            ),
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kelas Anda',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  studentClass.name,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  studentClass.teacherName,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: AppRadius.radiusSm,
            ),
            child: Text(
              'Aktif',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return AppCard(
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger),
          AppSpacing.hGapMd,
          Expanded(
            child: Text(
              error,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MaterialListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final int? duration;
  final VoidCallback onTap;

  const _MaterialListTile({
    required this.title,
    required this.subtitle,
    this.duration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: AppSpacing.cardPaddingCompact,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.2),
              borderRadius: AppRadius.radiusSm,
            ),
            child: const Icon(
              Icons.menu_book,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (duration != null)
            Text(
              '$duration min',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          AppSpacing.hGapSm,
          const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
