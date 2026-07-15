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

    return FutureBuilder(
      future: user != null
          ? classService.getStudentClasses(user.id)
          : Future.value([]),
      builder: (context, classSnapshot) {
        final enrolledClass = classSnapshot.data?.isNotEmpty == true
            ? classSnapshot.data!.first
            : null;

        return GradientShellScaffold(
          title: 'Galeri Belajar',
          subtitle: 'Jelajahi materimu',
          onRefresh: () async => ref.invalidate(materialsProvider),
          headerExtra: enrolledClass == null
              ? null
              : Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.school_rounded,
                          color: Colors.white, size: 16),
                      AppSpacing.hGapSm,
                      Text(
                        '${enrolledClass.name} · ${enrolledClass.gradeCategory} Kelas ${enrolledClass.gradeLevel}',
                        style: AppTypography.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
          body: materialsAsync.when(
            data: (materials) {
              if (materials.isEmpty) {
                return EmptyState(
                  icon: Icons.menu_book_outlined,
                  title: 'Tidak Ada Materi',
                  description: enrolledClass != null
                      ? 'Materi untuk kelasmu belum tersedia'
                      : 'Kamu belum masuk ke kelas manapun. Hubungi guru untuk bergabung.',
                  actionLabel: enrolledClass != null ? null : 'Login Ulang',
                  onAction:
                      enrolledClass != null ? null : () => context.go('/login'),
                );
              }

              return Column(
                children: [
                  for (var i = 0; i < materials.length; i++) ...[
                    if (i > 0) AppSpacing.vGapMd,
                    MaterialCard(
                      id: materials[i].id,
                      title: materials[i].title,
                      description: materials[i].description,
                      thumbnailUrl: materials[i].thumbnailUrl,
                      estimatedDuration: materials[i].estimatedDuration,
                      gradeCategory: materials[i].gradeCategory,
                      gradeLevel: materials[i].gradeLevel,
                      status: materials[i].status,
                      onTap: () =>
                          context.go('/student/learning/${materials[i].id}'),
                    ),
                  ],
                ],
              );
            },
            loading: () => Column(
              children: [
                for (var i = 0; i < 4; i++) ...[
                  if (i > 0) AppSpacing.vGapMd,
                  const ShimmerCard(),
                ],
              ],
            ),
            error: (error, _) => EmptyState(
              icon: Icons.error_outline,
              title: 'Gagal Memuat',
              description: error.toString(),
              actionLabel: 'Coba Lagi',
              onAction: () => ref.invalidate(materialsProvider),
            ),
          ),
        );
      },
    );
  }
}
