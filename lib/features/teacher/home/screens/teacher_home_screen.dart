import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';
import '../providers/teacher_provider.dart';
import '../../../../shared/services/services.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class TeacherHomeScreen extends ConsumerWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(teacherClassesProvider);
    final statsAsync = ref.watch(teacherStatsProvider);
    final user = ref.watch(currentUserProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        await SystemNavigator.pop();
      },
      child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Civic Pulse',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              ref.invalidate(teacherClassesProvider);
              ref.invalidate(teacherStatsProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(teacherClassesProvider);
          ref.invalidate(teacherStatsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(user?.name, user?.avatarUrl),
              _buildStatsDashboard(statsAsync),
              _buildSectionHeader(context, ref, classesAsync),
              _buildClassesContent(context, ref, classesAsync),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateClassDialog(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Buat Kelas'),
      ),
    ),
  );
}

  Widget _buildWelcomeHeader(String? name, String? avatarUrl) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.xl,
        top: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang,',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                AppSpacing.vGapXs,
                Text(
                  name ?? 'Guru',
                  style: AppTypography.headlineLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.vGapXs,
                Text(
                  'Mari pantau karakter & perkembangan akademis siswa.',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.hGapMd,
          AvatarWidget(
            imageUrl: avatarUrl,
            name: name,
            size: 56,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsDashboard(AsyncValue<Map<String, dynamic>> statsAsync) {
    return statsAsync.when(
      data: (stats) {
        final classesCount = stats['classes_count'] ?? 0;
        final studentsCount = stats['students_count'] ?? 0;
        final notesCount = stats['anecdotal_notes_count'] ?? 0;

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Kelas',
                  '$classesCount',
                  Icons.school,
                  AppColors.primary,
                ),
              ),
              AppSpacing.hGapSm,
              Expanded(
                child: _buildStatCard(
                  'Siswa',
                  '$studentsCount',
                  Icons.people,
                  AppColors.success,
                ),
              ),
              AppSpacing.hGapSm,
              Expanded(
                child: _buildStatCard(
                  'Catatan',
                  '$notesCount',
                  Icons.assignment_outlined,
                  AppColors.warning,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Expanded(child: _buildShimmerStatCard()),
            AppSpacing.hGapSm,
            Expanded(child: _buildShimmerStatCard()),
            AppSpacing.hGapSm,
            Expanded(child: _buildShimmerStatCard()),
          ],
        ),
      ),
      error: (e, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          AppSpacing.vGapSm,
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerStatCard() {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.shimmerBase,
              shape: BoxShape.circle,
            ),
          ),
          AppSpacing.vGapSm,
          Container(
            width: 40,
            height: 24,
            color: AppColors.shimmerBase,
          ),
          AppSpacing.vGapXs,
          Container(
            width: 50,
            height: 12,
            color: AppColors.shimmerBase,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, WidgetRef ref, AsyncValue<List<TeacherClass>> classesAsync) {
    final count = classesAsync.maybeWhen(
      data: (list) => list.length,
      orElse: () => 0,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daftar Kelas',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (count > 0) ...[
            const SizedBox(height: 2),
            Text(
              'Terdapat $count kelas aktif',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildClassesContent(BuildContext context, WidgetRef ref, AsyncValue<List<TeacherClass>> classesAsync) {
    return classesAsync.when(
      data: (classes) {
        if (classes.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: _buildEmptyState(context, ref),
          );
        }
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.78,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
          ),
          itemCount: classes.length,
          itemBuilder: (context, index) {
            final cls = classes[index];
            return _ClassCard(
              cls: cls,
              onTap: () => context.go('/teacher/class/${cls.id}'),
            );
          },
        );
      },
      loading: () => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.78,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
        ),
        itemCount: 4,
        itemBuilder: (context, index) => const ShimmerCard(),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: _buildErrorState(ref, error),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return EmptyState(
      icon: Icons.school_outlined,
      title: 'Belum Ada Kelas',
      description: 'Buat kelas baru untuk mulai memantau perkembangan siswa.',
      actionLabel: 'Buat Kelas Pertama',
      onAction: () => _showCreateClassDialog(context, ref),
    );
  }

  Widget _buildErrorState(WidgetRef ref, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.danger),
          AppSpacing.vGapMd,
          Text(
            'Gagal memuat kelas',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          AppSpacing.vGapXs,
          Text(
            error.toString(),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          AppSpacing.vGapLg,
          AppButton(
            label: 'Coba Lagi',
            variant: AppButtonVariant.primary,
            onPressed: () {
              ref.invalidate(teacherClassesProvider);
              ref.invalidate(teacherStatsProvider);
            },
          ),
        ],
      ),
    );
  }

  void _showCreateClassDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    String selectedCategory = 'SMP';
    int selectedGradeLevel = 7;

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
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Buat Kelas Baru',
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              AppSpacing.vGapMd,
              AppTextField(
                label: 'Nama Kelas',
                hint: 'Contoh: VII-A',
                controller: nameController,
              ),
              AppSpacing.vGapMd,
              Text(
                'Jenjang',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.vGapSm,
              Wrap(
                spacing: AppSpacing.sm,
                children: ['SMP', 'SMA'].map((cat) {
                  final isSelected = selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          selectedCategory = cat;
                          selectedGradeLevel = cat == 'SMP' ? 7 : 10;
                        });
                      }
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceVariant,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    labelStyle: AppTypography.labelMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              AppSpacing.vGapMd,
              Text(
                'Tingkat',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.vGapSm,
              Wrap(
                spacing: AppSpacing.sm,
                children: (selectedCategory == 'SMP'
                    ? [7, 8, 9]
                    : [10, 11, 12]).map((level) {
                  final isSelected = selectedGradeLevel == level;
                  return ChoiceChip(
                    label: Text('Kelas $level'),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => selectedGradeLevel = level);
                      }
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceVariant,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    labelStyle: AppTypography.labelMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              AppSpacing.vGapLg,
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: 'Buat Kelas',
                  variant: AppButtonVariant.primary,
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.white),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Nama kelas tidak boleh kosong!',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: AppColors.danger,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                      return;
                    }

                    try {
                      final service = ref.read(teacherServiceProvider);
                      final user = ref.read(currentUserProvider);
                      final code = await service.createClass(
                        name: nameController.text.trim(),
                        gradeCategory: selectedCategory,
                        gradeLevel: selectedGradeLevel,
                        homeroomTeacherId: user?.id,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_outline, color: Colors.white),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Kelas berhasil dibuat! Kode: $code',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                        ref.invalidate(teacherClassesProvider);
                        ref.invalidate(teacherStatsProvider);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.white),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    e.toString().replaceAll('Exception: ', ''),
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: AppColors.danger,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClassCard extends ConsumerWidget {
  final TeacherClass cls;
  final VoidCallback onTap;

  const _ClassCard({required this.cls, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(classStudentsProvider(cls.id));
    final studentCount = studentsAsync.maybeWhen(
      data: (s) => s.length,
      orElse: () => cls.studentCount,
    );

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(Icons.school, size: 18, color: AppColors.primary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  cls.classCode,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vGapMd,
          Text(
            cls.name,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '${cls.gradeCategory} • Kelas ${cls.gradeLevel}',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat(Icons.people_outline, '$studentCount siswa'),
              _buildPulseIndicator(cls.averagePulse),
            ],
          ),
          AppSpacing.vGapSm,
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: LinearProgressIndicator(
              value: cls.totalMaterials > 0
                  ? cls.completedMaterials / cls.totalMaterials
                  : 0,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 5,
            ),
          ),
          AppSpacing.vGapXs,
          Text(
            '${cls.completedMaterials}/${cls.totalMaterials} materi selesai',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        AppSpacing.hGapXs,
        Text(
          text,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPulseIndicator(double avgPulse) {
    Color color;
    if (avgPulse >= 3.5) {
      color = AppColors.success;
    } else if (avgPulse >= 2.5) {
      color = AppColors.warning;
    } else {
      color = AppColors.danger;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.chip,
      ),
      child: Text(
        avgPulse == 0.0 ? '-' : avgPulse.toStringAsFixed(1),
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}