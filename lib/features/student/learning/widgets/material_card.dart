import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/constants.dart';

class MaterialCard extends StatelessWidget {
  final int id;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final int? estimatedDuration;
  final String gradeCategory;
  final int gradeLevel;
  final String status;
  final VoidCallback onTap;

  const MaterialCard({
    super.key,
    required this.id,
    required this.title,
    this.description,
    this.thumbnailUrl,
    this.estimatedDuration,
    required this.gradeCategory,
    required this.gradeLevel,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppRadius.cardRadius),
              topRight: Radius.circular(AppRadius.cardRadius),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: thumbnailUrl != null
                  ? CachedNetworkImage(
                      imageUrl: thumbnailUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.surfaceVariant,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
          ),
          // Content
          Padding(
            padding: AppSpacing.cardPaddingCompact,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Grade badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.2),
                    borderRadius: AppRadius.radiusSm,
                  ),
                  child: Text(
                    '$gradeCategory Kelas $gradeLevel',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AppSpacing.vGapSm,
                // Title
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (description != null) ...[
                  AppSpacing.vGapXs,
                  Text(
                    description!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                AppSpacing.vGapSm,
                // Duration & Status
                Row(
                  children: [
                    if (estimatedDuration != null) ...[
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$estimatedDuration menit',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const Spacer(),
                    _buildStatusBadge(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.primaryLight.withValues(alpha: 0.2),
      child: Center(
        child: Icon(
          Icons.menu_book,
          size: 40,
          color: AppColors.primary.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case 'completed':
        color = AppColors.success;
        label = 'Selesai';
        icon = Icons.check_circle;
        break;
      case 'in_progress':
        color = AppColors.warning;
        label = 'Sedang';
        icon = Icons.play_circle;
        break;
      default:
        color = AppColors.textSecondary;
        label = 'Mulai';
        icon = Icons.play_arrow;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
