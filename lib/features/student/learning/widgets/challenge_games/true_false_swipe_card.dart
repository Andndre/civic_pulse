import 'package:flutter/material.dart';
import '../../../../../core/constants/constants.dart';
import '../../../../../shared/services/services.dart';

/// Kartu Swipe Benar/Salah — game_type: 'true_false_swipe'
/// Payload format:
/// {
///   "statements": [
///     {"id": "s1", "text": "Toleransi berarti membenarkan semua keyakinan orang lain", "answer": false},
///     {"id": "s2", "text": "Toleransi berarti menghormati hak orang lain untuk berbeda", "answer": true}
///   ]
/// }
///
/// UI: kartu pernyataan satu-satu, tombol ✓ (benar) dan ✗ (salah),
/// plus gesture swipe kanan = benar / kiri = salah via Dismissible
class TrueFalseSwipeCard extends StatefulWidget {
  final LearningNode node;
  final void Function(Map<String, dynamic> answer) onComplete;

  const TrueFalseSwipeCard({super.key, required this.node, required this.onComplete});

  @override
  State<TrueFalseSwipeCard> createState() => _TrueFalseSwipeCardState();
}

class _TrueFalseSwipeCardState extends State<TrueFalseSwipeCard> {
  int _currentIndex = 0;
  // item id → user answer (bool)
  final Map<String, bool> _answers = {};
  bool _showResult = false;
  bool? _lastCorrect;

  List<Map<String, dynamic>> get _statements {
    final payload = widget.node.payload ?? {};
    final raw = payload['statements'];
    if (raw is List) return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    return [];
  }

  void _answer(bool userAnswer) {
    final statements = _statements;
    if (_currentIndex >= statements.length) return;

    final stmt = statements[_currentIndex];
    final id = stmt['id'] as String;
    final correct = stmt['answer'] as bool? ?? false;
    final isCorrect = userAnswer == correct;

    setState(() {
      _answers[id] = userAnswer;
      _lastCorrect = isCorrect;
      _showResult = true;
    });

    // Auto-advance after 900ms
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _showResult = false;
        _lastCorrect = null;
        if (_currentIndex < statements.length - 1) {
          _currentIndex++;
        }
        // else stays at last — user presses "Selesai"
      });
    });
  }

  int get _correctCount {
    final stmts = _statements;
    int count = 0;
    for (final s in stmts) {
      final id = s['id'] as String;
      final correct = s['answer'] as bool? ?? false;
      if (_answers[id] == correct) count++;
    }
    return count;
  }

  bool get _allAnswered => _answers.length == _statements.length;

  @override
  Widget build(BuildContext context) {
    final statements = _statements;
    if (statements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.textSecondary),
            AppSpacing.vGapMd,
            Text('Tidak ada pernyataan', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    final isFinished = _allAnswered;

    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: [
          _buildChip(),
          AppSpacing.vGapMd,
          if (widget.node.title != null)
            Text(
              widget.node.title!,
              style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
            ),
          AppSpacing.vGapSm,
          Text(
            widget.node.body ?? 'Tentukan apakah pernyataan berikut BENAR atau SALAH.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          AppSpacing.vGapMd,
          // Progress bar
          Row(
            children: [
              Text(
                '${_answers.length}/${statements.length}',
                style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
              ),
              const Spacer(),
              Text(
                '${(_answers.length / statements.length * 100).toInt()}%',
                style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: _answers.length / statements.length,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
          const SizedBox(height: 24),
          if (!isFinished) ...[
            // Main swipe card
            Expanded(
              child: _SwipeCard(
                key: ValueKey(_currentIndex),
                statement: statements[_currentIndex]['text'] as String? ?? '',
                showResult: _showResult,
                isCorrect: _lastCorrect,
                onTrue: _showResult ? null : () => _answer(true),
                onFalse: _showResult ? null : () => _answer(false),
              ),
            ),
          ] else ...[
            // Summary
            Expanded(child: _buildSummary(statements)),
          ],
        ],
      ),
    );
  }

  Widget _buildChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: AppRadius.radiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.swipe, size: 14, color: AppColors.warning),
          const SizedBox(width: 4),
          Text(
            'Benar / Salah',
            style: AppTypography.labelSmall.copyWith(color: AppColors.warning, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(List<Map<String, dynamic>> statements) {
    final total = statements.length;
    final correct = _correctCount;
    final allCorrect = correct == total;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: allCorrect
                ? AppColors.successLight.withValues(alpha: 0.15)
                : AppColors.warning.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$correct/$total',
              style: AppTypography.titleLarge.copyWith(
                color: allCorrect ? AppColors.success : AppColors.warning,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        AppSpacing.vGapMd,
        Text(
          allCorrect ? 'Semua benar! Luar biasa!' : '$correct dari $total pernyataan tepat.',
          style: AppTypography.titleSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        AppSpacing.vGapSm,
        Text(
          'Swipe/klik membantu kamu lebih cepat memilah fakta.',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        AppButton(
          label: 'Lanjutkan',
          variant: AppButtonVariant.primary,
          onPressed: () => widget.onComplete({'answers': _answers, 'correct': _correctCount}),
          fullWidth: true,
        ),
      ],
    );
  }
}

class _SwipeCard extends StatelessWidget {
  final String statement;
  final bool showResult;
  final bool? isCorrect;
  final VoidCallback? onTrue;
  final VoidCallback? onFalse;

  const _SwipeCard({
    super.key,
    required this.statement,
    required this.showResult,
    this.isCorrect,
    this.onTrue,
    this.onFalse,
  });

  @override
  Widget build(BuildContext context) {
    Color cardBg = AppColors.surface;
    Color cardBorder = AppColors.divider;
    if (showResult && isCorrect != null) {
      cardBg = isCorrect!
          ? AppColors.successLight.withValues(alpha: 0.1)
          : AppColors.danger.withValues(alpha: 0.08);
      cardBorder = isCorrect! ? AppColors.success : AppColors.danger;
    }

    return Column(
      children: [
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: AppRadius.radiusLg,
              border: Border.all(color: cardBorder, width: showResult ? 2 : 1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showResult && isCorrect != null) ...[
                  Icon(
                    isCorrect! ? Icons.check_circle : Icons.cancel,
                    size: 48,
                    color: isCorrect! ? AppColors.success : AppColors.danger,
                  ),
                  AppSpacing.vGapMd,
                  Text(
                    isCorrect! ? 'Benar!' : 'Salah!',
                    style: AppTypography.titleMedium.copyWith(
                      color: isCorrect! ? AppColors.success : AppColors.danger,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.vGapMd,
                ],
                Text(
                  statement,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (!showResult) ...[
                  AppSpacing.vGapMd,
                  Text(
                    'Pilih di bawah atau swipe kartu →',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ActionButton(
              label: '✗ Salah',
              color: AppColors.danger,
              onTap: onFalse,
            ),
            _ActionButton(
              label: '✓ Benar',
              color: AppColors.success,
              onTap: onTrue,
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration: BoxDecoration(
          color: onTap != null ? color.withValues(alpha: 0.12) : AppColors.surfaceVariant,
          borderRadius: AppRadius.radiusMd,
          border: Border.all(color: onTap != null ? color : AppColors.divider, width: 2),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: onTap != null ? color : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
