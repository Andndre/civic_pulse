import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/constants/constants.dart';
import '../../../../../shared/services/services.dart';
import 'game_widgets.dart';

/// Kartu Swipe Benar/Salah — game_type: 'true_false_swipe'
/// Payload format:
/// {
///   "statements": [
///     {"id": "s1", "text": "Toleransi berarti membenarkan semua keyakinan orang lain", "answer": false},
///     {"id": "s2", "text": "Toleransi berarti menghormati hak orang lain untuk berbeda", "answer": true}
///   ]
/// }
///
/// UI: kartu pernyataan satu-satu; geser kanan = benar / kiri = salah
/// (dengan stempel BENAR/SALAH mengikuti jari), atau ketuk tombol bulat ✓ / ✗.
class TrueFalseSwipeCard extends StatefulWidget {
  final LearningNode node;
  final void Function(Map<String, dynamic> answer) onComplete;

  const TrueFalseSwipeCard({super.key, required this.node, required this.onComplete});

  @override
  State<TrueFalseSwipeCard> createState() => _TrueFalseSwipeCardState();
}

class _TrueFalseSwipeCardState extends State<TrueFalseSwipeCard>
    with SingleTickerProviderStateMixin {
  static const Color _accent = AppColors.pulseLearning;
  static const double _swipeThreshold = 90;

  int _currentIndex = 0;
  // item id → user answer (bool)
  final Map<String, bool> _answers = {};
  bool _showResult = false;
  bool? _lastCorrect;

  double _dragX = 0;
  late final AnimationController _slideController;
  Animation<double>? _slide;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..addListener(() {
        if (_slide != null) setState(() => _dragX = _slide!.value);
      });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _statements {
    final payload = widget.node.payload ?? {};
    final raw = payload['statements'];
    if (raw is List) {
      return raw
          .where((e) => e is Map)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .where((e) => e['id'] != null)
          .toList();
    }
    return [];
  }

  bool get _isBusy => _showResult || _slideController.isAnimating;

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isBusy) return;
    setState(() => _dragX += details.delta.dx);
  }

  void _onPanEnd(DragEndDetails details) {
    if (_showResult || _slideController.isAnimating) return;
    final velocity = details.velocity.pixelsPerSecond.dx;
    if (_dragX.abs() > _swipeThreshold || velocity.abs() > 700) {
      final toRight = _dragX != 0 ? _dragX > 0 : velocity > 0;
      final width = MediaQuery.of(context).size.width;
      _runSlide(_dragX, toRight ? width * 1.2 : -width * 1.2, onDone: () {
        _dragX = 0;
        _answer(toRight);
      });
    } else {
      _runSlide(_dragX, 0, curve: Curves.easeOutBack);
    }
  }

  void _runSlide(double from, double to, {VoidCallback? onDone, Curve curve = Curves.easeOut}) {
    _slide = Tween<double>(begin: from, end: to)
        .animate(CurvedAnimation(parent: _slideController, curve: curve));
    _slideController.forward(from: 0).whenComplete(() {
      _slide = null;
      onDone?.call();
    });
  }

  void _answer(bool userAnswer) {
    final statements = _statements;
    if (_currentIndex >= statements.length) return;

    final stmt = statements[_currentIndex];
    final id = stmt['id']?.toString() ?? '';
    final correct = stmt['answer'] as bool? ?? false;
    final isCorrect = userAnswer == correct;

    HapticFeedback.lightImpact();
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
        _dragX = 0;
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
      final id = s['id']?.toString() ?? '';
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
            Text('Tidak ada pernyataan',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    final isFinished = _allAnswered;

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: [
          const GameBadge(
            icon: Icons.swipe_rounded,
            label: 'Benar / Salah',
            color: _accent,
          ),
          AppSpacing.vGapMd,
          if (widget.node.title != null)
            Text(
              widget.node.title!,
              textAlign: TextAlign.center,
              style: AppTypography.titleMedium
                  .copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
            ),
          AppSpacing.vGapSm,
          Text(
            widget.node.body ?? 'Geser kartu ke kanan jika BENAR, ke kiri jika SALAH.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          AppSpacing.vGapMd,
          // Progress
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.12),
                  borderRadius: AppRadius.radiusFull,
                ),
                child: Text(
                  '${_answers.length}/${statements.length}',
                  style: AppTypography.labelSmall.copyWith(
                    color: gameDarken(_accent, 0.10),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${(_answers.length / statements.length * 100).toInt()}%',
                style: AppTypography.labelSmall.copyWith(
                  color: gameDarken(_accent, 0.10),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          GameProgressBar(
            value: _answers.length / statements.length,
            color: _accent,
          ),
          const SizedBox(height: 20),
          if (!isFinished)
            _buildSwipeArea(statements)
          else
            _buildSummary(statements),
        ],
      ),
    );
  }

  Widget _buildSwipeArea(List<Map<String, dynamic>> statements) {
    final width = MediaQuery.of(context).size.width;
    final angle = _dragX / width * 0.35;
    final rightOpacity = (_dragX / _swipeThreshold).clamp(0.0, 1.0);
    final leftOpacity = (-_dragX / _swipeThreshold).clamp(0.0, 1.0);

    return Column(
      children: [
        // Drag horizontal saja, agar scroll vertikal halaman tetap jalan.
        // Kartu tumbuh mengikuti panjang teks (fleksibel, tanpa tinggi tetap).
        GestureDetector(
          onHorizontalDragUpdate: _onPanUpdate,
          onHorizontalDragEnd: _onPanEnd,
          child: Transform.translate(
            offset: Offset(_dragX, 0),
            child: Transform.rotate(
              angle: angle,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 220),
                child: _StatementCard(
                  key: ValueKey(_currentIndex),
                  statement: statements[_currentIndex]['text'] as String? ?? '',
                  number: _currentIndex + 1,
                  total: statements.length,
                  showResult: _showResult,
                  isCorrect: _lastCorrect,
                  trueStampOpacity: _showResult ? 0 : rightOpacity,
                  falseStampOpacity: _showResult ? 0 : leftOpacity,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _RoundActionButton(
              icon: Icons.close_rounded,
              label: 'Salah',
              color: AppColors.danger,
              onTap: _isBusy ? null : () => _answer(false),
            ),
            _RoundActionButton(
              icon: Icons.check_rounded,
              label: 'Benar',
              color: AppColors.success,
              onTap: _isBusy ? null : () => _answer(true),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSummary(List<Map<String, dynamic>> statements) {
    final total = statements.length;
    final correct = _correctCount;
    final allCorrect = correct == total;
    final ringColors = allCorrect
        ? [AppColors.celebrate, AppColors.warning]
        : [_accent, gameDarken(_accent)];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, value, child) => Transform.scale(scale: value, child: child),
          child: Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: ringColors,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ringColors.first.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  allCorrect ? Icons.emoji_events_rounded : Icons.flag_rounded,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 2),
                Text(
                  '$correct/$total',
                  style: AppTypography.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        AppSpacing.vGapLg,
        Text(
          allCorrect ? 'Semua benar! Luar biasa!' : '$correct dari $total pernyataan tepat.',
          style: AppTypography.titleSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        AppSpacing.vGapSm,
        Text(
          'Memilah fakta dengan cepat melatih ketajaman berpikirmu.',
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

class _StatementCard extends StatelessWidget {
  final String statement;
  final int number;
  final int total;
  final bool showResult;
  final bool? isCorrect;
  final double trueStampOpacity;
  final double falseStampOpacity;

  const _StatementCard({
    super.key,
    required this.statement,
    required this.number,
    required this.total,
    required this.showResult,
    this.isCorrect,
    this.trueStampOpacity = 0,
    this.falseStampOpacity = 0,
  });

  @override
  Widget build(BuildContext context) {
    Color cardBg = AppColors.surface;
    Color cardBorder = AppColors.divider;
    if (showResult && isCorrect != null) {
      cardBg = isCorrect!
          ? AppColors.success.withValues(alpha: 0.08)
          : AppColors.danger.withValues(alpha: 0.06);
      cardBorder = isCorrect! ? AppColors.success : AppColors.danger;
    } else if (trueStampOpacity > 0) {
      cardBorder = Color.lerp(AppColors.divider, AppColors.success, trueStampOpacity)!;
    } else if (falseStampOpacity > 0) {
      cardBorder = Color.lerp(AppColors.divider, AppColors.danger, falseStampOpacity)!;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: cardBorder, width: showResult ? 2 : 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.pulseLearning.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Stempel BENAR (swipe kanan)
          Positioned(
            top: 0,
            left: 0,
            child: Opacity(
              opacity: trueStampOpacity,
              child: _Stamp(label: 'BENAR', color: AppColors.success, angle: -0.2),
            ),
          ),
          // Stempel SALAH (swipe kiri)
          Positioned(
            top: 0,
            right: 0,
            child: Opacity(
              opacity: falseStampOpacity,
              child: _Stamp(label: 'SALAH', color: AppColors.danger, angle: 0.2),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showResult && isCorrect != null) ...[
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) =>
                        Transform.scale(scale: value, child: child),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: isCorrect! ? AppColors.success : AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCorrect! ? Icons.check_rounded : Icons.close_rounded,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
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
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.pulseLearning.withValues(alpha: 0.10),
                      borderRadius: AppRadius.radiusFull,
                    ),
                    child: Text(
                      'Pernyataan $number dari $total',
                      style: AppTypography.labelSmall.copyWith(
                        color: gameDarken(AppColors.pulseLearning, 0.10),
                        fontWeight: FontWeight.w700,
                      ),
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
                  AppSpacing.vGapLg,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.arrow_back_rounded,
                          size: 14, color: AppColors.danger),
                      const SizedBox(width: 4),
                      Text(
                        'salah',
                        style: AppTypography.labelSmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.swipe_rounded,
                          size: 16, color: AppColors.textHint),
                      const SizedBox(width: 16),
                      Text(
                        'benar',
                        style: AppTypography.labelSmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 14, color: AppColors.success),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stamp extends StatelessWidget {
  final String label;
  final Color color;
  final double angle;

  const _Stamp({required this.label, required this.color, required this.angle});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: AppRadius.radiusSm,
          border: Border.all(color: color, width: 3),
        ),
        child: Text(
          label,
          style: AppTypography.titleSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _RoundActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GamePressable(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: enabled
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color, gameDarken(color)],
                    )
                  : null,
              color: enabled ? null : AppColors.surfaceVariant,
              shape: BoxShape.circle,
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              size: 30,
              color: enabled ? Colors.white : AppColors.textHint,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: enabled ? gameDarken(color, 0.10) : AppColors.textHint,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
