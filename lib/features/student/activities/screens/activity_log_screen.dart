import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/services/data_models.dart';
import '../providers/activity_provider.dart';

class ActivityLogScreen extends ConsumerStatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  ConsumerState<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends ConsumerState<ActivityLogScreen> {
  String? _selectedCategory;

  final List<Map<String, dynamic>> _categories = [
    {'value': null, 'label': 'Semua'},
    {'value': 'participation', 'label': 'Partisipasi'},
    {'value': 'understanding', 'label': 'Pemahaman'},
    {'value': 'learning', 'label': 'Pembelajaran'},
    {'value': 'social_engagement', 'label': 'Keterlibatan Sosial'},
  ];

  @override
  Widget build(BuildContext context) {
    final activitiesAsync = ref.watch(activityListProvider);

    return GradientShellScaffold(
      title: 'Aktivitas Kewargaan',
      subtitle: 'Portofolio kegiatanmu',
      onRefresh: () async => ref.invalidate(activityListProvider),
      trailing: IconButton(
        icon: const Icon(Icons.filter_list, color: Colors.white),
        tooltip: 'Filter aktivitas',
        onPressed: () => _showFilterBottomSheet(context),
      ),
      headerExtra: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final cat in _categories) ...[
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildFilterChip(
                  label: cat['label'] as String,
                  selected: _selectedCategory == cat['value'],
                  onTap: () => setState(
                      () => _selectedCategory = cat['value'] as String?),
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/student/activities/add'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Aktivitas'),
      ),
      body: activitiesAsync.when(
        data: (activities) {
          final filteredActivities = _selectedCategory == null
              ? activities
              : activities
                  .where((a) => a.category == _selectedCategory)
                  .toList();

          if (filteredActivities.isEmpty) {
            return _buildEmptyState();
          }

          return _buildActivityList(filteredActivities);
        },
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
            AppSpacing.vGapMd,
            Text('Gagal memuat aktivitas: $error'),
            AppSpacing.vGapMd,
            AppButton(
              label: 'Coba Lagi',
              variant: AppButtonVariant.primary,
              onPressed: () => ref.invalidate(activityListProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: selected ? AppColors.primaryDark : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.assignment_outlined,
      title: 'Belum Ada Aktivitas',
      description: 'Catat aktivitas positifmu untuk membangun portofolio PULSE.',
      actionLabel: 'Tambah Aktivitas Pertama',
      onAction: () => context.push('/student/activities/add'),
    );
  }

  Widget _buildActivityList(List<ActivityLog> activities) {
    return Column(
      children: [
        for (final activity in activities)
          _ActivityCard(
            activity: activity,
            onTap: () => context.push('/student/activities/${activity.id}'),
          ),
        // Ruang untuk FAB agar item terakhir tidak tertutup
        const SizedBox(height: 72),
      ],
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Aktivitas',
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
                ..._categories.map((cat) {
                  final isSelected = _selectedCategory == cat['value'];
                  return ListTile(
                    leading: Icon(
                      _getCategoryIcon(cat['value'] as String?),
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                    title: Text(
                      cat['label'] as String,
                      style: AppTypography.bodyLarge.copyWith(
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
                    onTap: () {
                      setState(() => _selectedCategory = cat['value'] as String?);
                      Navigator.pop(context);
                    },
                  );
                }),
                AppSpacing.vGapLg,
                if (_selectedCategory != null)
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() => _selectedCategory = null);
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Hapus Filter',
                        style: AppTypography.labelLarge.copyWith(
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

  IconData _getCategoryIcon(String? category) {
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
        return Icons.list_alt;
    }
  }
}

class _ActivityCard extends StatelessWidget {
  final ActivityLog activity;
  final VoidCallback onTap;

  const _ActivityCard({required this.activity, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: activity.photoUrl != null
                  ? Image.network(
                      activity.photoUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
            AppSpacing.hGapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.vGapXs,
                  Row(
                    children: [
                      StatusBadge(
                        label: _getCategoryLabel(activity.category),
                        status: _getCategoryStatus(activity.category),
                      ),
                    ],
                  ),
                  AppSpacing.vGapXs,
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                      AppSpacing.hGapXs,
                      Text(
                        activity.location,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                      AppSpacing.hGapXs,
                      Text(
                        _formatDate(activity.activityDate),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: AppColors.background,
      child: Icon(
        _getCategoryIcon(activity.category),
        color: AppColors.textSecondary,
        size: 32,
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
        return category;
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

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${months[date.month - 1]}';
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
        return Icons.assignment;
    }
  }
}
