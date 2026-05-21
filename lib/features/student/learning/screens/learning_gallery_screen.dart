import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';
import '../providers/material_provider.dart';
import '../widgets/material_card.dart';
import '../../../../shared/services/services.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class LearningGalleryScreen extends ConsumerWidget {
  const LearningGalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialsAsync = ref.watch(materialsProvider);
    final classService = ref.watch(classServiceProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Galeri Belajar'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: user != null ? classService.getStudentClasses(user.id) : Future.value([]),
        builder: (context, classSnapshot) {
          final enrolledClass = classSnapshot.data?.isNotEmpty == true
              ? classSnapshot.data!.first
              : null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Class info banner
              if (enrolledClass != null)
                Container(
                  width: double.infinity,
                  padding: AppSpacing.screenPadding.copyWith(
                    top: AppSpacing.md,
                    bottom: AppSpacing.md,
                  ),
                  color: AppColors.primary.withValues(alpha: 0.1),
                  child: Row(
                    children: [
                      Icon(Icons.school, color: AppColors.primary),
                      AppSpacing.hGapMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              enrolledClass.name,
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${enrolledClass.gradeCategory} Kelas ${enrolledClass.gradeLevel}',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                        return EmptyState(
                          icon: Icons.menu_book_outlined,
                          title: 'Tidak Ada Materi',
                          description: enrolledClass != null
                              ? 'Materi untuk kelasmu belum tersedia'
                              : 'Kamu belum masuk ke kelas manapun. Hubungi guru untuk bergabung.',
                          actionLabel: enrolledClass != null ? null : 'Login Ulang',
                          onAction: enrolledClass != null
                              ? null
                              : () => context.go('/login'),
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
          );
        },
      ),
    );
  }
}
