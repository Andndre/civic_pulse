import 'package:flutter/material.dart';
import '../constants/constants.dart';

class ProgressCard extends StatelessWidget {
  final String title;
  final int current;
  final int total;
  final String? subtitle;
  final Color? progressColor;

  const ProgressCard({
    super.key,
    required this.title,
    required this.current,
    required this.total,
    this.subtitle,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? current / total : 0.0;
    final color = progressColor ?? AppColors.primary;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          AppSpacing.vGapSm,
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$current',
                style: AppTypography.displaySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '/ $total',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vGapSm,
          ClipRRect(
            borderRadius: AppRadius.radiusSm,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
          if (subtitle != null) ...[
            AppSpacing.vGapSm,
            Text(
              subtitle!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
