import 'package:flutter/material.dart';
import '../../../../../core/constants/constants.dart';
import '../../../../../shared/services/services.dart';
import 'game_widgets.dart';

/// Kartu Sortir Kategori — game_type: 'sorting'
/// Payload format:
/// {
///   "categories": ["Toleran", "Intoleran"],
///   "items": [
///     {"id": "a", "label": "Membiarkan teman beribadah", "category": "Toleran"},
///     {"id": "b", "label": "Mengejek teman beda agama", "category": "Intoleran"}
///   ]
/// }
///
/// UI: item diseret ke keranjang kategori berwarna (DragTarget)
class SortingGameCard extends StatefulWidget {
  final LearningNode node;
  final void Function(Map<String, dynamic> answer) onComplete;

  const SortingGameCard({super.key, required this.node, required this.onComplete});

  @override
  State<SortingGameCard> createState() => _SortingGameCardState();
}

class _SortingGameCardState extends State<SortingGameCard> {
  static const Color _accent = AppColors.pulseUnderstanding;

  // Warna keranjang bergilir; dua pertama dipertahankan hijau/merah
  // karena kategori sortir umumnya berpasangan positif/negatif.
  static const List<Color> _bucketColors = [
    AppColors.success,
    AppColors.danger,
    AppColors.pulseParticipation,
    AppColors.pulseSocialEngagement,
    AppColors.pulseLearning,
    AppColors.chartCyan,
  ];

  // item id → category chosen by user
  final Map<String, String> _sorted = {};
  bool _submitted = false;
  int _correctCount = 0;

  List<String> get _categories {
    final payload = widget.node.payload ?? {};
    final raw = payload['categories'];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return [];
  }

  List<Map<String, dynamic>> get _items {
    final payload = widget.node.payload ?? {};
    final raw = payload['items'];
    if (raw is List) {
      return raw
          .where((e) => e is Map)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .where((e) => e['id'] != null && e['category'] != null)
          .toList();
    }
    return [];
  }

  List<Map<String, dynamic>> get _unsortedItems =>
      _items.where((item) => !_sorted.containsKey(item['id'].toString())).toList();

  List<Map<String, dynamic>> _itemsInCategory(String category) =>
      _items.where((item) => _sorted[item['id'].toString()] == category).toList();

  Color _colorForCategory(String category) =>
      _bucketColors[_categories.indexOf(category) % _bucketColors.length];

  void _submit() {
    int correct = 0;
    for (final item in _items) {
      final id = item['id']?.toString() ?? '';
      final expected = item['category']?.toString() ?? '';
      if (_sorted[id] == expected) correct++;
    }
    setState(() {
      _submitted = true;
      _correctCount = correct;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = _categories;
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GameBadge(
            icon: Icons.category_rounded,
            label: 'Sortir Kategori',
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
            widget.node.body ?? 'Seret setiap item ke keranjang kategori yang tepat.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          AppSpacing.vGapLg,
          // Unsorted items pool
          if (_unsortedItems.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.6),
                borderRadius: AppRadius.radiusLg,
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.pan_tool_alt_rounded,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        'Seret item ke keranjang di bawah',
                        style: AppTypography.labelSmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const Spacer(),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _accent.withValues(alpha: 0.12),
                          borderRadius: AppRadius.radiusFull,
                        ),
                        child: Text(
                          '${_sorted.length}/${_items.length}',
                          style: AppTypography.labelSmall.copyWith(
                            color: gameDarken(_accent, 0.10),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final item in _unsortedItems)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Builder(
                            builder: (context) {
                              final id = item['id'] as String;
                              final label = item['label'] as String? ?? '';
                              return Draggable<String>(
                                data: id,
                                feedback: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.78,
                                  child: Transform.rotate(
                                    angle: -0.02,
                                    child: _DraggableChip(
                                        label: label, isDragging: true),
                                  ),
                                ),
                                childWhenDragging: _DraggableChip(
                                    label: label, isDragging: false, faded: true),
                                child:
                                    _DraggableChip(label: label, isDragging: false),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            AppSpacing.vGapLg,
          ],
          // Category buckets
          ...categories.map((cat) => _buildBucket(cat)),
          const SizedBox(height: 8),
          if (_submitted) _buildFeedback(),
          if (!_submitted)
            AppButton(
              label: 'Konfirmasi Jawaban',
              variant: AppButtonVariant.primary,
              onPressed: _sorted.length == _items.length ? _submit : null,
              fullWidth: true,
            ),
        ],
      ),
    );
  }

  Widget _buildBucket(String cat) {
    final catItems = _itemsInCategory(cat);
    final catColor = _colorForCategory(cat);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DragTarget<String>(
        onAcceptWithDetails: (details) {
          if (!_submitted) {
            setState(() => _sorted[details.data] = cat);
          }
        },
        builder: (context, candidateData, rejectedData) {
          final isHover = candidateData.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            constraints: const BoxConstraints(minHeight: 96),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isHover
                  ? catColor.withValues(alpha: 0.14)
                  : catColor.withValues(alpha: 0.05),
              borderRadius: AppRadius.radiusLg,
              border: Border.all(
                color: isHover ? catColor : catColor.withValues(alpha: 0.30),
                width: isHover ? 2 : 1.5,
              ),
              boxShadow: isHover
                  ? [
                      BoxShadow(
                        color: catColor.withValues(alpha: 0.20),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [catColor, gameDarken(catColor)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.inbox_rounded,
                          size: 15, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cat,
                        style: AppTypography.labelMedium.copyWith(
                          color: gameDarken(catColor, 0.10),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.12),
                        borderRadius: AppRadius.radiusFull,
                      ),
                      child: Text(
                        '${catItems.length} item',
                        style: AppTypography.labelSmall.copyWith(
                          color: gameDarken(catColor, 0.10),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (catItems.isEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        Icon(
                          Icons.file_download_outlined,
                          size: 18,
                          color: catColor.withValues(alpha: 0.45),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isHover ? 'Lepaskan di sini!' : 'Taruh item "$cat" di sini',
                          style: AppTypography.labelSmall.copyWith(
                            color: catColor.withValues(alpha: 0.55),
                            fontWeight: isHover ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final item in catItems)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _SortedChip(
                            label: item['label'] as String? ?? '',
                            color: catColor,
                            submitted: _submitted,
                            isCorrect: _submitted && item['category'] == cat,
                            onRemove: _submitted
                                ? null
                                : () => setState(
                                    () => _sorted.remove(item['id'].toString())),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeedback() {
    final total = _items.length;
    final allCorrect = _correctCount == total;
    return Column(
      children: [
        GameFeedbackBanner(
          color: allCorrect ? AppColors.success : AppColors.warning,
          icon: allCorrect ? Icons.celebration_rounded : Icons.lightbulb_rounded,
          message: allCorrect
              ? 'Sempurna! Semua item di kategori yang benar!'
              : '$_correctCount dari $total item di kategori yang tepat. Cek yang salah di atas.',
        ),
        const SizedBox(height: 16),
        AppButton(
          label: 'Lanjutkan',
          variant: AppButtonVariant.primary,
          onPressed: () => widget.onComplete({'sorted': _sorted, 'correct': _correctCount}),
          fullWidth: true,
        ),
      ],
    );
  }
}

class _DraggableChip extends StatelessWidget {
  final String label;
  final bool isDragging;
  final bool faded;

  const _DraggableChip({required this.label, required this.isDragging, this.faded = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isDragging
              ? AppColors.pulseUnderstanding
              : faded
                  ? AppColors.surfaceVariant.withValues(alpha: 0.5)
                  : AppColors.surface,
          borderRadius: AppRadius.radiusFull,
          border: Border.all(
            color: isDragging ? AppColors.pulseUnderstanding : AppColors.divider,
          ),
          boxShadow: isDragging
              ? [
                  BoxShadow(
                    color: AppColors.pulseUnderstanding.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
              : faded
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.drag_indicator_rounded,
              size: 15,
              color: isDragging ? Colors.white70 : AppColors.textHint,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                softWrap: true,
                style: AppTypography.labelSmall.copyWith(
                  color: isDragging
                      ? Colors.white
                      : faded
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                  fontWeight: isDragging ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortedChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool submitted;
  final bool isCorrect;
  final VoidCallback? onRemove;

  const _SortedChip({
    required this.label,
    required this.color,
    required this.submitted,
    required this.isCorrect,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final Color chipColor =
        submitted ? (isCorrect ? AppColors.success : AppColors.danger) : color;
    return GamePressable(
      onTap: onRemove,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.radiusFull,
          border: Border.all(color: chipColor.withValues(alpha: 0.6), width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              submitted
                  ? (isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded)
                  : Icons.close_rounded,
              size: 15,
              color: submitted ? chipColor : AppColors.textHint,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                softWrap: true,
                style: AppTypography.labelSmall.copyWith(
                  color: submitted ? gameDarken(chipColor, 0.10) : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
