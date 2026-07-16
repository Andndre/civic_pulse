import 'package:flutter/material.dart';
import '../../../../../core/constants/constants.dart';
import '../../../../../shared/services/services.dart';
import 'game_widgets.dart';

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
  static const Color _accent = AppColors.pulseParticipation;

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
          const GameBadge(
            icon: Icons.quiz_rounded,
            label: 'Pilihan Ganda',
            color: _accent,
          ),
          AppSpacing.vGapMd,
          GameQuestionCard(
            color: _accent,
            label: widget.node.title,
            text: question,
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

  Widget _buildOption(Map<String, dynamic> opt) {
    final id = opt['id']?.toString() ?? '';
    final label = opt['label']?.toString() ?? '';
    final isSelected = _selected == id;
    final isCorrect = _correct == id;

    Color borderColor = AppColors.divider;
    Color bgColor = AppColors.surface;
    List<BoxShadow>? shadow;
    if (_submitted) {
      if (isCorrect) {
        borderColor = AppColors.success;
        bgColor = AppColors.success.withValues(alpha: 0.07);
      } else if (isSelected && !isCorrect) {
        borderColor = AppColors.danger;
        bgColor = AppColors.danger.withValues(alpha: 0.06);
      }
    } else if (isSelected) {
      borderColor = _accent;
      bgColor = _accent.withValues(alpha: 0.06);
      shadow = [
        BoxShadow(
          color: _accent.withValues(alpha: 0.18),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
    }

    // Badge huruf: berubah jadi ikon status setelah dikonfirmasi
    Widget badgeChild = Text(
      id.toUpperCase(),
      style: AppTypography.labelMedium.copyWith(
        color: isSelected ? Colors.white : _accent,
        fontWeight: FontWeight.bold,
      ),
    );
    Color badgeColor = isSelected ? _accent : _accent.withValues(alpha: 0.10);
    if (_submitted) {
      if (isCorrect) {
        badgeColor = AppColors.success;
        badgeChild = const Icon(Icons.check_rounded, color: Colors.white, size: 20);
      } else if (isSelected) {
        badgeColor = AppColors.danger;
        badgeChild = const Icon(Icons.close_rounded, color: Colors.white, size: 20);
      } else {
        badgeColor = AppColors.surfaceVariant;
        badgeChild = Text(
          id.toUpperCase(),
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GamePressable(
        onTap: _submitted ? null : () => setState(() => _selected = id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppRadius.radiusLg,
            border: Border.all(
              color: borderColor,
              width: isSelected || (_submitted && isCorrect) ? 2 : 1,
            ),
            boxShadow: shadow,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
                child: Center(child: badgeChild),
              ),
              AppSpacing.hGapMd,
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
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
        GameFeedbackBanner(
          color: isCorrect ? AppColors.success : AppColors.danger,
          icon: isCorrect ? Icons.celebration_rounded : Icons.lightbulb_rounded,
          message: isCorrect
              ? 'Benar! Jawaban tepat.'
              : 'Kurang tepat. Jawaban yang benar sudah ditandai.',
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
