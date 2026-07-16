import 'package:flutter/material.dart';
import '../../../../../core/constants/constants.dart';
import '../../../../../shared/services/services.dart';
import 'game_widgets.dart';

/// Kartu Mencocokkan Pasangan — game_type: 'matching'
/// Payload format:
/// {
///   "pairs": [
///     {"id": "p1", "left": "Toleransi", "right": "Menghormati perbedaan"},
///     {"id": "p2", "left": "Moderasi", "right": "Sikap tidak berlebihan"}
///   ]
/// }
///
/// UI: dua kolom; setiap pasangan yang dibuat mendapat warna + nomor sendiri
/// sehingga koneksi kiri-kanan terlihat jelas tanpa garis.
class MatchingGameCard extends StatefulWidget {
  final LearningNode node;
  final void Function(Map<String, dynamic> answer) onComplete;

  const MatchingGameCard({super.key, required this.node, required this.onComplete});

  @override
  State<MatchingGameCard> createState() => _MatchingGameCardState();
}

class _MatchingGameCardState extends State<MatchingGameCard> {
  static const Color _accent = AppColors.pulseSocialEngagement;

  // Warna bergilir untuk tiap pasangan (berdasar urutan item kiri)
  static const List<Color> _pairColors = [
    AppColors.pulseParticipation,
    AppColors.pulseLearning,
    AppColors.pulseSocialEngagement,
    AppColors.pulseUnderstanding,
    AppColors.chartPink,
    AppColors.chartCyan,
    AppColors.chartIndigo,
    AppColors.chartOrange,
  ];

  // Maps left id → right id (user's selections)
  final Map<String, String> _matches = {};
  String? _selectedLeft;
  bool _submitted = false;
  bool? _allCorrect;

  List<Map<String, dynamic>> get _pairs {
    final payload = widget.node.payload ?? {};
    final raw = payload['pairs'];
    if (raw is List) {
      return raw
          .where((e) => e is Map)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return [];
  }

  List<String> get _leftItems => _pairs
      .map((p) => (p['left'] ?? '').toString())
      .where((s) => s.isNotEmpty)
      .toList();

  // Stable shuffled rights (computed once)
  late final List<String> _shuffledRights;
  late final Map<String, String> _correctMap; // left → right

  @override
  void initState() {
    super.initState();
    final rights = _pairs
        .map((p) => (p['right'] ?? '').toString())
        .where((s) => s.isNotEmpty)
        .toList()
      ..shuffle();
    _shuffledRights = rights;
    _correctMap = {
      for (final p in _pairs)
        if (p['left'] != null && p['right'] != null)
          p['left'].toString(): p['right'].toString()
    };
  }

  Color _colorForLeft(String left) =>
      _pairColors[_leftItems.indexOf(left) % _pairColors.length];

  /// Item kiri yang menunjuk ke item kanan ini (jika ada).
  String? _leftMatchedTo(String right) {
    for (final e in _matches.entries) {
      if (e.value == right) return e.key;
    }
    return null;
  }

  void _onLeftTap(String left) {
    if (_submitted) return;
    setState(() {
      _selectedLeft = _selectedLeft == left ? null : left;
    });
  }

  void _onRightTap(String right) {
    if (_submitted || _selectedLeft == null) return;
    setState(() {
      // Lepas dulu jika item kanan ini sudah dipakai pasangan lain
      _matches.removeWhere((_, v) => v == right);
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
          const GameBadge(
            icon: Icons.extension_rounded,
            label: 'Cocokkan Pasangan',
            color: _accent,
          ),
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
            widget.node.body ?? 'Ketuk item di kiri, lalu ketuk pasangannya di kanan.',
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
                        number: _leftItems.indexOf(left) + 1,
                        pairColor: _colorForLeft(left),
                        isSelected: isSelected,
                        isMatched: isMatched,
                        isCorrect: _submitted ? isCorrect : null,
                        isWrong: _submitted ? isWrong : null,
                        onTap: () => _onLeftTap(left),
                        side: MatchSide.left,
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
                    final matchedBy = _leftMatchedTo(right);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _MatchItem(
                        label: right,
                        number: matchedBy != null
                            ? _leftItems.indexOf(matchedBy) + 1
                            : null,
                        pairColor:
                            matchedBy != null ? _colorForLeft(matchedBy) : null,
                        isSelected: false,
                        isMatched: matchedBy != null,
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
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _selectedLeft != null
                ? Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.08),
                        borderRadius: AppRadius.radiusMd,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.touch_app_rounded, size: 16, color: _accent),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Sekarang pilih pasangannya di kolom kanan →',
                              style: AppTypography.labelSmall.copyWith(
                                color: gameDarken(_accent, 0.10),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
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

  Widget _buildFeedback() {
    final allCorrect = _allCorrect ?? false;
    return Column(
      children: [
        GameFeedbackBanner(
          color: allCorrect ? AppColors.success : AppColors.warning,
          icon: allCorrect ? Icons.celebration_rounded : Icons.lightbulb_rounded,
          message: allCorrect
              ? 'Semua pasangan benar! Hebat!'
              : 'Ada yang belum tepat. Pasangan yang salah ditandai merah.',
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
  final int? number;
  final Color? pairColor;
  final bool isSelected;
  final bool isMatched;
  final bool? isCorrect;
  final bool? isWrong;
  final VoidCallback onTap;
  final MatchSide side;

  const _MatchItem({
    required this.label,
    this.number,
    this.pairColor,
    required this.isSelected,
    required this.isMatched,
    this.isCorrect,
    this.isWrong,
    required this.onTap,
    required this.side,
  });

  @override
  Widget build(BuildContext context) {
    Color border = AppColors.divider;
    Color bg = AppColors.surface;
    List<BoxShadow>? shadow;
    if (isCorrect == true) {
      border = AppColors.success;
      bg = AppColors.success.withValues(alpha: 0.07);
    } else if (isWrong == true) {
      border = AppColors.danger;
      bg = AppColors.danger.withValues(alpha: 0.06);
    } else if (isSelected) {
      border = AppColors.pulseSocialEngagement;
      bg = AppColors.pulseSocialEngagement.withValues(alpha: 0.08);
      shadow = [
        BoxShadow(
          color: AppColors.pulseSocialEngagement.withValues(alpha: 0.20),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ];
    } else if (isMatched && pairColor != null) {
      border = pairColor!;
      bg = pairColor!.withValues(alpha: 0.07);
    }

    // Badge nomor pasangan
    Widget? badge;
    if (isCorrect == true) {
      badge = const _NumberBadge(color: AppColors.success, icon: Icons.check_rounded);
    } else if (isWrong == true) {
      badge = const _NumberBadge(color: AppColors.danger, icon: Icons.close_rounded);
    } else if (isMatched && pairColor != null && number != null) {
      badge = _NumberBadge(color: pairColor!, number: number);
    } else if (side == MatchSide.left && number != null) {
      badge = _NumberBadge(
        color: isSelected ? AppColors.pulseSocialEngagement : AppColors.textHint,
        number: number,
        outlined: !isSelected,
      );
    }

    return GamePressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.radiusMd,
          border: Border.all(color: border, width: isSelected || isMatched ? 2 : 1),
          boxShadow: shadow,
        ),
        child: Row(
          children: [
            if (side == MatchSide.left && badge != null) ...[
              badge,
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: isSelected || isMatched ? FontWeight.w600 : FontWeight.w400,
                ),
                textAlign: side == MatchSide.left ? TextAlign.left : TextAlign.right,
              ),
            ),
            if (side == MatchSide.right && badge != null) ...[
              const SizedBox(width: 8),
              badge,
            ],
          ],
        ),
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  final Color color;
  final int? number;
  final IconData? icon;
  final bool outlined;

  const _NumberBadge({
    required this.color,
    this.number,
    this.icon,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color,
        shape: BoxShape.circle,
        border: outlined ? Border.all(color: color, width: 1.5) : null,
      ),
      child: Center(
        child: icon != null
            ? Icon(icon, size: 14, color: Colors.white)
            : Text(
                '$number',
                style: AppTypography.labelSmall.copyWith(
                  color: outlined ? color : Colors.white,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
      ),
    );
  }
}
