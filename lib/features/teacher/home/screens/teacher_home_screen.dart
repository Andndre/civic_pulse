import 'package:flutter/material.dart';
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kelas Saya'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(teacherClassesProvider),
          ),
        ],
      ),
      body: classesAsync.when(
        data: (classes) {
          if (classes.isEmpty) {
            return _buildEmptyState(context, ref);
          }
          return _buildClassGrid(context, ref, classes);
        },
        loading: () => _buildLoadingGrid(),
        error: (error, _) => _buildErrorState(ref, error),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateClassDialog(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Buat Kelas'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return EmptyState(
      icon: Icons.school_outlined,
      title: 'Belum Ada Kelas',
      description: 'Buat kelas baru untuk mulai memantau siswa.',
      actionLabel: 'Buat Kelas Pertama',
      onAction: () => _showCreateClassDialog(context, ref),
    );
  }

  Widget _buildClassGrid(BuildContext context, WidgetRef ref, List<TeacherClass> classes) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(teacherClassesProvider);
      },
      child: GridView.builder(
        padding: AppSpacing.screenPadding,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
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
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: AppSpacing.screenPadding,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: 4,
      itemBuilder: (context, index) => const ShimmerCard(),
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
            onPressed: () => ref.invalidate(teacherClassesProvider),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Buat Kelas Baru',
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
                        setState(() => selectedCategory = cat);
                      }
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: AppTypography.labelMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  );
                }).toList(),
              ),
              AppSpacing.vGapMd,
              Text(
                'Tingkat',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textPrimary,
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
                    labelStyle: AppTypography.labelMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
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
                    if (nameController.text.isNotEmpty) {
                      try {
                        final service = ref.read(teacherServiceProvider);
                        final user = ref.read(currentUserProvider);
                        final code = await service.createClass(
                          name: nameController.text,
                          gradeCategory: selectedCategory,
                          gradeLevel: selectedGradeLevel,
                          homeroomTeacherId: user?.id,
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Kelas berhasil dibuat! Kode: $code'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                          ref.invalidate(teacherClassesProvider);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString().replaceAll('Exception: ', '')),
                              backgroundColor: AppColors.danger,
                            ),
                          );
                        }
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
    final studentCount = studentsAsync.maybeWhen(data: (s) => s.length, orElse: () => cls.studentCount);
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with class info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(Icons.class_, color: AppColors.primary),
              ),
              const Spacer(),
              Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
          AppSpacing.vGapMd,
          Text(
            cls.name,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${cls.gradeCategory} Kelas ${cls.gradeLevel}',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat(Icons.people, '$studentCount siswa'),
              _buildPulseIndicator(cls.averagePulse),
            ],
          ),
          AppSpacing.vGapSm,
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: LinearProgressIndicator(
              value: cls.totalMaterials > 0
                  ? cls.completedMaterials / cls.totalMaterials
                  : 0,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
            ),
          ),
          AppSpacing.vGapXs,
          Text(
            '${cls.completedMaterials}/${cls.totalMaterials} materi selesai',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
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
        avgPulse.toStringAsFixed(1),
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}