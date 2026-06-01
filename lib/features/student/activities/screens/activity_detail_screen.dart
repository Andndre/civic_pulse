import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';
import '../providers/activity_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/services/services.dart';

class ActivityDetailScreen extends ConsumerWidget {
  final int activityId;

  const ActivityDetailScreen({super.key, required this.activityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(activityProvider(activityId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Aktivitas'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: activityAsync.value != null ? [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/student/activities/$activityId/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ] : null,
      ),
      body: activityAsync.when(
        data: (activity) {
          if (activity == null) {
            return const EmptyState(
              icon: Icons.error_outline,
              title: 'Aktivitas Tidak Ditemukan',
              description: 'Detail aktivitas tidak dapat ditemukan atau telah dihapus.',
            );
          }
          return _buildContent(context, activity);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
              AppSpacing.vGapMd,
              Text('Gagal memuat detail aktivitas: $error'),
              AppSpacing.vGapMd,
              AppButton(
                label: 'Coba Lagi',
                onPressed: () => ref.invalidate(activityProvider(activityId)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ActivityLog activity) {
    final categoryLabel = _getCategoryLabel(activity.category);
    final categoryStatus = _getCategoryStatus(activity.category);
    final categoryColor = _getCategoryColor(activity.category);
    final categoryIcon = _getCategoryIcon(activity.category);

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card (Title & Category)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.1),
                        borderRadius: AppRadius.radiusSm,
                      ),
                      child: Icon(
                        categoryIcon,
                        color: categoryColor,
                        size: 20,
                      ),
                    ),
                    AppSpacing.hGapSm,
                    StatusBadge(
                      label: categoryLabel,
                      status: categoryStatus,
                    ),
                  ],
                ),
                AppSpacing.vGapMd,
                Text(
                  activity.title,
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vGapMd,

          // Metadata Card (Date & Location)
          AppCard(
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Icons.calendar_today_outlined,
                  iconColor: AppColors.primary,
                  label: 'Tanggal Kegiatan',
                  value: _formatDate(activity.activityDate),
                ),
                const Divider(height: 24, thickness: 0.5),
                _buildInfoRow(
                  icon: Icons.location_on_outlined,
                  iconColor: AppColors.danger,
                  label: 'Lokasi Kegiatan',
                  value: _formatLocationLabel(activity.location),
                ),
              ],
            ),
          ),
          AppSpacing.vGapMd,

          // PULSE Dimension description Card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.star_outline, color: categoryColor),
                    AppSpacing.hGapSm,
                    Text(
                      'Dimensi PULSE',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                AppSpacing.vGapSm,
                Text(
                  _getCategoryDescription(activity.category),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vGapMd,

          // Documentation / Evidence Section
          Text(
            'Dokumentasi & Bukti',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.vGapSm,
          if (activity.photoUrl != null && activity.photoUrl!.isNotEmpty)
            AppCard(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: AppRadius.card,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: () => _showImageDialog(context, activity.photoUrl!),
                      child: Image.network(
                        activity.photoUrl!,
                        fit: BoxFit.cover,
                        height: 240,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 240,
                            color: AppColors.surfaceVariant,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 240,
                            color: AppColors.surfaceVariant,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.broken_image_outlined,
                                  size: 48,
                                  color: AppColors.textHint,
                                ),
                                AppSpacing.vGapSm,
                                Text(
                                  'Gagal memuat gambar',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.zoom_in,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          AppSpacing.hGapXs,
                          Text(
                            'Ketuk gambar untuk memperbesar',
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
            )
          else
            AppCard(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.image_not_supported_outlined,
                        size: 48,
                        color: AppColors.textHint,
                      ),
                      AppSpacing.vGapSm,
                      Text(
                        'Tidak ada dokumentasi foto',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      AppSpacing.vGapXs,
                      Text(
                        'Aktivitas ini disimpan tanpa melampirkan foto bukti.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textHint,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          AppSpacing.vGapLg,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 18,
          ),
        ),
        AppSpacing.hGapMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              AppSpacing.vGapXs,
              Text(
                value,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(AppSpacing.md),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: const Icon(
                      Icons.broken_image,
                      size: 64,
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'participation':
        return 'Partisipasi';
      case 'understanding':
        return 'Pemahaman';
      case 'learning':
        return 'Pembelajaran';
      case 'social_engagement':
        return 'Keterlibatan Sosial';
      default:
        return category.toUpperCase();
    }
  }

  AppStatus _getCategoryStatus(String category) {
    switch (category) {
      case 'participation':
        return AppStatus.success;
      case 'understanding':
        return AppStatus.warning;
      case 'learning':
        return AppStatus.success;
      case 'social_engagement':
        return AppStatus.warning;
      default:
        return AppStatus.success;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'participation':
        return AppColors.success;
      case 'understanding':
        return AppColors.warning;
      case 'learning':
        return AppColors.primary;
      case 'social_engagement':
        return AppColors.chartPurple;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'participation':
        return Icons.how_to_reg;
      case 'understanding':
        return Icons.lightbulb_outline;
      case 'learning':
        return Icons.school_outlined;
      case 'social_engagement':
        return Icons.people_outline;
      default:
        return Icons.assignment_outlined;
    }
  }

  String _getCategoryDescription(String category) {
    switch (category) {
      case 'participation':
        return 'Partisipasi aktif dalam kegiatan sosial, keagamaan, budaya, atau kewarganegaraan di tingkat sekolah maupun masyarakat.';
      case 'understanding':
        return 'Refleksi mendalam terhadap materi pembelajaran kewarganegaraan, pemahaman nilai-nilai demokrasi, Pancasila, dan keberagaman.';
      case 'learning':
        return 'Pencapaian prestasi akademik, pengerjaan tugas-tugas terstruktur, serta keaktifan dalam proses belajar mengajar di kelas.';
      case 'social_engagement':
        return 'Keterlibatan nyata dalam aksi kerelawanan, membantu sesama, toleransi antar umat beragama, dan kolaborasi sosial.';
      default:
        return 'Aktivitas pengembangan karakter dalam portofolio PULSE.';
    }
  }

  String _formatDate(DateTime date) {
    final days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    // Simple weekday calculation (Flutter DateTime.weekday is 1 for Monday, 7 for Sunday)
    final weekday = days[date.weekday == 7 ? 0 : date.weekday];
    final month = months[date.month - 1];
    
    return '$weekday, ${date.day} $month ${date.year}';
  }

  String _formatLocationLabel(String location) {
    switch (location.toLowerCase()) {
      case 'rumah':
        return 'Rumah';
      case 'sekolah':
        return 'Sekolah';
      case 'kelas':
        return 'Kelas';
      case 'masyarakat':
        return 'Masyarakat';
      default:
        return location;
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Hapus Aktivitas'),
          content: const Text('Apakah Anda yakin ingin menghapus log aktivitas ini secara permanen?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        ),
                        SizedBox(width: 16),
                        Text('Menghapus aktivitas...'),
                      ],
                    ),
                    duration: Duration(days: 1),
                  ),
                );

                try {
                  final service = ref.read(activityServiceProvider);
                  await service.deleteActivity(activityId);
                  
                  ref.invalidate(activityListProvider);
                  final user = ref.read(currentUserProvider);
                  if (user != null) {
                    ref.invalidate(studentActivitiesProvider(user.id));
                  }
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Aktivitas berhasil dihapus'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    context.pop();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal menghapus: $e'),
                        backgroundColor: AppColors.danger,
                      ),
                    );
                  }
                }
              },
              child: const Text('Hapus', style: TextStyle(color: AppColors.danger)),
            ),
          ],
        );
      },
    );
  }
}
