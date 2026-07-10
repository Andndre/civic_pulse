import 'package:flutter/material.dart';
import '../../../../../core/constants/constants.dart';
import '../../../../../shared/services/services.dart';

/// Kartu materi teks — node_type: 'content'
/// Menampilkan judul, body teks, dan gambar opsional
class ContentCard extends StatelessWidget {
  final LearningNode node;
  final VoidCallback onComplete;

  const ContentCard({super.key, required this.node, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (node.title != null) ...[
            Text(
              node.title!,
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.vGapMd,
          ],
          if (node.imageUrl != null) ...[
            ClipRRect(
              borderRadius: AppRadius.radiusMd,
              child: Image.network(
                node.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: AppRadius.radiusMd,
                  ),
                  child: const Icon(Icons.image_not_supported, size: 40, color: AppColors.textSecondary),
                ),
              ),
            ),
            AppSpacing.vGapMd,
          ],
          if (node.body != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Text(
                node.body!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
              ),
            ),
          const SizedBox(height: 32),
          AppButton(
            label: 'Lanjutkan',
            variant: AppButtonVariant.primary,
            onPressed: onComplete,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}
