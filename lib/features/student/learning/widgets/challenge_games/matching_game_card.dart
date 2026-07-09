import 'package:flutter/material.dart';
import '../../../../../core/constants/constants.dart';
import '../../../../../shared/services/services.dart';

/// Kartu Mencocokkan Pasangan — game_type: 'matching'
/// Payload format:
/// {
///   "pairs": [
///     {"id": "p1", "left": "Toleransi", "right": "Menghormati perbedaan"},
///     {"id": "p2", "left": "Moderasi", "right": "Sikap tidak berlebihan"}
///   ]
/// }
///
/// UI: dua kolom, klik item kiri → klik item kanan → garis terhubung
class MatchingGameCard extends StatefulWidget {
  final LearningNode node;
  final void Function(Map<String, dynamic> answer) onComplete;

  const MatchingGameCard({super.key, required this.node, required this.onComplete});

  @override
  State<MatchingGameCard> createState() => _MatchingGameCardState();
}

class _MatchingGameCardState extends State<MatchingGameCard> {
  // Maps left id → right id (user's selections)
  final Map<String, String> _matches = {};
  String? _selectedLeft;
  bool _submitted = false;
  bool? _allCorrect;

  List<Map<String, dynamic>> get _pairs {
    final payload = widget.node.payload ?? {};
    final raw = payload['pairs'];
    if (raw is List) return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    return [];
  }

  List<String> get _leftItems => _pairs.map((p) => p['left'] as String).toList();

  // Stable shuffled rights (computed once)
  late final List<String> _shuffledRights;
  late final Map<String, String> _correctMap; // left → right

  @override
  void initState() {
    super.initState();
    final rights = _pairs.map((p) => p['right'] as String).toList()..shuffle();
    _shuffledRights = rights;
    _correctMap = {for (final p in _pairs) p['left'] as String: p['right'] as String};
  }

  void _onLeftTap(String left) {
    if (_submitted) return;
    setState(() {
      _selectedLeft = left;
    });
  }

  void _onRightTap(String right) {
    if (_submitted || _selectedLeft == null) return;
    setState(() {
      _matches[_selectedLeft!] = right;
      _selectedLeft = null;
    });
  }

  void _submit() {
    final allCorrect = _correctMap.entries.every(
      (e) => _matches[e.key] == e.value,
    );
    setState(() {
      _submitted = true;
      _allCorrect = allCorrect;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChip(),
          AppSpacing.vGapMd,
          if (widget.node.title != null)
            Text(
              widget.node.title!,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          AppSpacing.vGapSm,
          Text(
            widget.node.body ?? 'Cocokkan setiap item di kiri dengan pasangannya di kanan.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          AppSpacing.vGapLg,
          // Two-column matching grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column
              Expanded(
                child: Column(
                  children: _leftItems.map((left) {
                    final isSelected = _selectedLeft == left;
                    final isMatched = _matches.containsKey(left);
                    final isCorrect = _submitted && _correctMap[left] == _matches[left];
                    final isWrong = _submitted && isMatched && !isCorrect;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _MatchItem(
                        label: left,
                        isSelected: isSelected,
                        isMatched: isMatched,
                        isCorrect: _submitted ? isCorrect : null,
                        isWrong: _submitted ? isWrong : null,
                        onTap: () => _onLeftTap(left),
                        side: MatchSide.left,
                        matchedTo: _matches[left],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 12),
              // Right column
              Expanded(
                child: Column(
                  children: _shuffledRights.map((right) {
                    final isMatchedBy = _matches.values.contains(right);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _MatchItem(
                        label: right,
                        isSelected: false,
                        isMatched: isMatchedBy,
                        isCorrect: null,
                        isWrong: null,
                        onTap: () => _onRightTap(right),
                        side: MatchSide.right,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          if (_selectedLeft != null) ...[
            AppSpacing.vGapSm,
            Text(
              'Sekarang pilih pasangannya di kolom kanan →',
              style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
            ),
          ],
          const SizedBox(height: 24),
          if (_submitted) _buildFeedback(),
          if (!_submitted)
            AppButton(
              label: 'Konfirmasi Jawaban',
              variant: AppButtonVariant.primary,
              onPressed: _matches.length == _leftItems.length ? _submit : null,
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
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: AppRadius.radiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.link, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            'Cocokkan Pasangan',
            style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedback() {
    final allCorrect = _allCorrect ?? false;
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            color: allCorrect
                ? AppColors.successLight.withValues(alpha: 0.12)
                : AppColors.warning.withValues(alpha: 0.1),
            borderRadius: AppRadius.radiusMd,
            border: Border.all(color: allCorrect ? AppColors.success : AppColors.warning),
          ),
          child: Row(
            children: [
              Icon(
                allCorrect ? Icons.check_circle : Icons.info_outline,
                color: allCorrect ? AppColors.success : AppColors.warning,
              ),
              AppSpacing.hGapSm,
              Expanded(
                child: Text(
                  allCorrect
                      ? 'Semua pasangan benar! Hebat!'
                      : 'Ada yang belum tepat. Pasangan yang benar sudah ditampilkan.',
                  style: AppTypography.bodySmall.copyWith(
                    color: allCorrect ? AppColors.success : AppColors.warning,
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
          onPressed: () => widget.onComplete({'matches': _matches}),
          fullWidth: true,
        ),
      ],
    );
  }
}

enum MatchSide { left, right }

class _MatchItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isMatched;
  final bool? isCorrect;
  final bool? isWrong;
  final VoidCallback onTap;
  final MatchSide side;
  final String? matchedTo;

  const _MatchItem({
    required this.label,
    required this.isSelected,
    required this.isMatched,
    this.isCorrect,
    this.isWrong,
    required this.onTap,
    required this.side,
    this.matchedTo,
  });

  @override
  Widget build(BuildContext context) {
    Color border = AppColors.divider;
    Color bg = AppColors.surface;
    if (isCorrect == true) {
      border = AppColors.success;
      bg = AppColors.successLight.withValues(alpha: 0.08);
    } else if (isWrong == true) {
      border = AppColors.danger;
      bg = AppColors.danger.withValues(alpha: 0.06);
    } else if (isSelected) {
      border = AppColors.primary;
      bg = AppColors.primaryLight.withValues(alpha: 0.12);
    } else if (isMatched) {
      border = AppColors.info;
      bg = AppColors.info.withValues(alpha: 0.06);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusSm,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.radiusSm,
          border: Border.all(color: border, width: isSelected ? 2 : 1),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
          textAlign: side == MatchSide.left ? TextAlign.left : TextAlign.right,
        ),
      ),
    );
  }
}
