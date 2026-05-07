import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/material_provider.dart';
import '../widgets/material_card.dart';

class LearningGalleryScreen extends ConsumerWidget {
  const LearningGalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialsAsync = ref.watch(materialsProvider);
    final filter = ref.watch(materialFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Galeri Belajar'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            color: AppColors.surface,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Semua',
                    isSelected: filter.gradeCategory == null,
                    onTap: () {
                      ref.read(materialFilterProvider.notifier).clear();
                    },
                  ),
                  AppSpacing.hGapSm,
                  _FilterChip(
                    label: 'SMP',
                    isSelected: filter.gradeCategory == 'SMP',
                    onTap: () {
                      ref.read(materialFilterProvider.notifier).setGradeCategory('SMP');
                    },
                  ),
                  AppSpacing.hGapSm,
                  _FilterChip(
                    label: 'SMA',
                    isSelected: filter.gradeCategory == 'SMA',
                    onTap: () {
                      ref.read(materialFilterProvider.notifier).setGradeCategory('SMA');
                    },
                  ),
                ],
              ),
            ),
          ),

          // Materials grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(materialsProvider);
              },
              child: materialsAsync.when(
                data: (materials) {
                  if (materials.isEmpty) {
                    return const EmptyState(
                      icon: Icons.menu_book_outlined,
                      title: 'Tidak Ada Materi',
                      description: 'Materi untuk jenjang ini belum tersedia',
                    );
                  }

                  return GridView.builder(
                    padding: AppSpacing.screenPadding,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                    ),
                    itemCount: materials.length,
                    itemBuilder: (context, index) {
                      final material = materials[index];
                      return MaterialCard(
                        id: material.id,
                        title: material.title,
                        description: material.description,
                        thumbnailUrl: material.thumbnailUrl,
                        estimatedDuration: material.estimatedDuration,
                        gradeCategory: material.gradeCategory,
                        gradeLevel: material.gradeLevel,
                        status: material.status,
                        onTap: () => context.go('/student/learning/${material.id}'),
                      );
                    },
                  );
                },
                loading: () => GridView.builder(
                  padding: AppSpacing.screenPadding,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) => const ShimmerCard(),
                ),
                error: (error, _) => EmptyState(
                  icon: Icons.error_outline,
                  title: 'Gagal Memuat',
                  description: error.toString(),
                  actionLabel: 'Coba Lagi',
                  onAction: () => ref.invalidate(materialsProvider),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.chip,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: AppRadius.chip,
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
