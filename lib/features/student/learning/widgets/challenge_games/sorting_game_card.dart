import 'package:flutter/material.dart';
import '../../../../../core/constants/constants.dart';
import '../../../../../shared/services/services.dart';

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
/// UI: item diseret ke keranjang kategori (DragTarget)
class SortingGameCard extends StatefulWidget {
  final LearningNode node;
  final void Function(Map<String, dynamic> answer) onComplete;

  const SortingGameCard({super.key, required this.node, required this.onComplete});

  @override
  State<SortingGameCard> createState() => _SortingGameCardState();
}

class _SortingGameCardState extends State<SortingGameCard> {
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
    if (raw is List) return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    return [];
  }

  List<Map<String, dynamic>> get _unsortedItems =>
      _items.where((item) => !_sorted.containsKey(item['id'])).toList();

  List<Map<String, dynamic>> _itemsInCategory(String category) =>
      _items.where((item) => _sorted[item['id']] == category).toList();

  void _submit() {
    int correct = 0;
    for (final item in _items) {
      final id = item['id'] as String;
      final expected = item['category'] as String;
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
            widget.node.body ?? 'Seret setiap item ke kategori yang tepat.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          AppSpacing.vGapLg,
          // Unsorted items pool
          if (_unsortedItems.isNotEmpty) ...[
            Text(
              'Item untuk disortir:',
              style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
            ),
            AppSpacing.vGapSm,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _unsortedItems.map((item) {
                final id = item['id'] as String;
                final label = item['label'] as String? ?? '';
                return Draggable<String>(
                  data: id,
                  feedback: _DraggableChip(label: label, isDragging: true),
                  childWhenDragging: _DraggableChip(label: label, isDragging: false, faded: true),
                  child: _DraggableChip(label: label, isDragging: false),
                );
              }).toList(),
            ),
            AppSpacing.vGapLg,
          ],
          // Category buckets
          ...categories.map((cat) {
            final catItems = _itemsInCategory(cat);
            final catColor = categories.indexOf(cat) == 0 ? AppColors.success : AppColors.danger;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.inbox, size: 16, color: catColor),
                      const SizedBox(width: 6),
                      Text(
                        cat,
                        style: AppTypography.labelMedium.copyWith(
                          color: catColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  DragTarget<String>(
                    onAcceptWithDetails: (details) {
                      if (!_submitted) {
                        setState(() => _sorted[details.data] = cat);
                      }
                    },
                    builder: (context, candidateData, rejectedData) {
                      final isHover = candidateData.isNotEmpty;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        constraints: const BoxConstraints(minHeight: 60),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isHover
                              ? catColor.withValues(alpha: 0.15)
                              : catColor.withValues(alpha: 0.04),
                          borderRadius: AppRadius.radiusMd,
                          border: Border.all(
                            color: isHover ? catColor : catColor.withValues(alpha: 0.3),
                            width: isHover ? 2 : 1,
                            style: catItems.isEmpty && !isHover
                                ? BorderStyle.solid
                                : BorderStyle.solid,
                          ),
                        ),
                        child: catItems.isEmpty
                            ? Center(
                                child: Text(
                                  'Taruh item "$cat" di sini',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: catColor.withValues(alpha: 0.5),
                                  ),
                                ),
                              )
                            : Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: catItems.map((item) {
                                  final id = item['id'] as String;
                                  final label = item['label'] as String? ?? '';
                                  final isCorrect = _submitted && item['category'] == cat;
                                  return GestureDetector(
                                    onTap: _submitted
                                        ? null
                                        : () => setState(() => _sorted.remove(id)),
                                    child: Chip(
                                      label: Text(
                                        label,
                                        style: AppTypography.labelSmall.copyWith(
                                          color: _submitted
                                              ? (isCorrect ? AppColors.success : AppColors.danger)
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      backgroundColor: _submitted
                                          ? (isCorrect
                                              ? AppColors.successLight.withValues(alpha: 0.15)
                                              : AppColors.danger.withValues(alpha: 0.1))
                                          : AppColors.surface,
                                      side: BorderSide(
                                        color: _submitted
                                            ? (isCorrect ? AppColors.success : AppColors.danger)
                                            : AppColors.divider,
                                      ),
                                      avatar: _submitted
                                          ? Icon(
                                              isCorrect ? Icons.check_circle : Icons.cancel,
                                              size: 16,
                                              color: isCorrect ? AppColors.success : AppColors.danger,
                                            )
                                          : const Icon(Icons.close, size: 14, color: AppColors.textSecondary),
                                    ),
                                  );
                                }).toList(),
                              ),
                      );
                    },
                  ),
                ],
              ),
            );
          }),
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

  Widget _buildChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: AppRadius.radiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.category_outlined, size: 14, color: AppColors.success),
          const SizedBox(width: 4),
          Text(
            'Sortir Kategori',
            style: AppTypography.labelSmall.copyWith(color: AppColors.success, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedback() {
    final total = _items.length;
    final allCorrect = _correctCount == total;
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
                      ? 'Sempurna! Semua item di kategori yang benar!'
                      : '$_correctCount dari $total item di kategori yang tepat. Cek yang salah di atas.',
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDragging
              ? AppColors.primary
              : faded
                  ? AppColors.surfaceVariant.withValues(alpha: 0.5)
                  : AppColors.surface,
          borderRadius: AppRadius.radiusSm,
          border: Border.all(
            color: isDragging ? AppColors.primary : AppColors.divider,
          ),
          boxShadow: isDragging
              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]
              : null,
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isDragging ? AppColors.textOnPrimary : faded ? AppColors.textSecondary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
