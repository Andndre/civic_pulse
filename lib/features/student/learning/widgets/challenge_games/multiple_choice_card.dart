import 'package:flutter/material.dart';
import '../../../../../core/constants/constants.dart';
import '../../../../../shared/services/services.dart';

/// Kartu Pilihan Ganda — game_type: 'multiple_choice'
/// Payload format:
/// {
///   "question": "Teks soal",
///   "options": [{"id": "a", "label": "Pilihan A"}, ...],
///   "correct": "a"
/// }
class MultipleChoiceCard extends StatefulWidget {
  final LearningNode node;
  final void Function(Map<String, dynamic> answer) onComplete;

  const MultipleChoiceCard({super.key, required this.node, required this.onComplete});

  @override
  State<MultipleChoiceCard> createState() => _MultipleChoiceCardState();
}

class _MultipleChoiceCardState extends State<MultipleChoiceCard> {
  String? _selected;
  bool _submitted = false;

  List<Map<String, dynamic>> get _options {
    final payload = widget.node.payload ?? {};
    final raw = payload['options'];
    if (raw is List) {
      return raw
          .where((e) => e is Map)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .where((e) => e['id'] != null && e['label'] != null)
          .toList();
    }
    return [];
  }

  String? get _correct => widget.node.payload?['correct']?.toString();

  @override
  Widget build(BuildContext context) {
    final payload = widget.node.payload ?? {};
    final question = payload['question'] as String? ?? widget.node.body ?? '';

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChip(),
          AppSpacing.vGapMd,
          if (widget.node.title != null) ...[
            Text(
              widget.node.title!,
              style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
            ),
            AppSpacing.vGapSm,
          ],
          Text(
            question,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.vGapLg,
          ..._options.map((opt) => _buildOption(opt)),
          const SizedBox(height: 24),
          if (_submitted) _buildFeedback(),
          if (!_submitted)
            AppButton(
              label: 'Konfirmasi Jawaban',
              variant: AppButtonVariant.primary,
              onPressed: _selected != null ? _submit : null,
              fullWidth: true,
            ),
        ],
      ),
    );
  }

  Widget _buildChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.12),
        borderRadius: AppRadius.radiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.quiz_outlined, size: 14, color: AppColors.info),
          const SizedBox(width: 4),
          Text(
            'Pilihan Ganda',
            style: AppTypography.labelSmall.copyWith(color: AppColors.info, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(Map<String, dynamic> opt) {
    final id = opt['id']?.toString() ?? '';
    final label = opt['label']?.toString() ?? '';
    final isSelected = _selected == id;
    final isCorrect = _correct == id;

    Color borderColor = AppColors.divider;
    Color bgColor = AppColors.surface;
    if (_submitted) {
      if (isCorrect) {
        borderColor = AppColors.success;
        bgColor = AppColors.successLight.withValues(alpha: 0.1);
      } else if (isSelected && !isCorrect) {
        borderColor = AppColors.danger;
        bgColor = AppColors.danger.withValues(alpha: 0.06);
      }
    } else if (isSelected) {
      borderColor = AppColors.primary;
      bgColor = AppColors.primaryLight.withValues(alpha: 0.1);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: _submitted ? null : () => setState(() => _selected = id),
        borderRadius: AppRadius.radiusMd,
        child: Container(
          padding: AppSpacing.cardPaddingCompact,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppRadius.radiusMd,
            border: Border.all(color: borderColor, width: isSelected || (_submitted && isCorrect) ? 2 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    id.toUpperCase(),
                    style: AppTypography.labelMedium.copyWith(
                      color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              AppSpacing.hGapMd,
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                ),
              ),
              if (_submitted && isCorrect)
                const Icon(Icons.check_circle, color: AppColors.success, size: 20),
              if (_submitted && isSelected && !isCorrect)
                const Icon(Icons.cancel, color: AppColors.danger, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedback() {
    final isCorrect = _selected == _correct;
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            color: isCorrect
                ? AppColors.successLight.withValues(alpha: 0.12)
                : AppColors.danger.withValues(alpha: 0.08),
            borderRadius: AppRadius.radiusMd,
            border: Border.all(
              color: isCorrect ? AppColors.success : AppColors.danger,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.info_outline,
                color: isCorrect ? AppColors.success : AppColors.danger,
              ),
              AppSpacing.hGapSm,
              Expanded(
                child: Text(
                  isCorrect ? 'Benar! Jawaban tepat.' : 'Kurang tepat. Jawaban yang benar sudah ditandai.',
                  style: AppTypography.bodySmall.copyWith(
                    color: isCorrect ? AppColors.success : AppColors.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppButton(
          label: 'Lanjutkan',
          variant: AppButtonVariant.primary,
          onPressed: () => widget.onComplete({'selected': _selected}),
          fullWidth: true,
        ),
      ],
    );
  }

  void _submit() {
    setState(() => _submitted = true);
  }
}
