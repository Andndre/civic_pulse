import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/services/services.dart';
import '../providers/material_provider.dart';

class LearningPathScreen extends ConsumerStatefulWidget {
  final int materialId;

  const LearningPathScreen({super.key, required this.materialId});

  @override
  ConsumerState<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends ConsumerState<LearningPathScreen> {
  int _currentStep = 0; // 0=PreTest, 1=EBook, 2=PostTest, 3=Pulse

  final List<String> _steps = ['Pre-Test', 'Materi', 'Post-Test', 'Refleksi PULSE'];

  @override
  Widget build(BuildContext context) {
    final materialAsync = ref.watch(materialProvider(widget.materialId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Belajar'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(context),
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),
          // Content
          Expanded(
            child: materialAsync.when(
              data: (material) {
                if (material == null) {
                  return const EmptyState(
                    icon: Icons.error_outline,
                    title: 'Materi Tidak Ditemukan',
                    description: 'Materi yang Anda cari tidak tersedia',
                  );
                }
                return _buildStepContent(material.title);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyState(
                icon: Icons.error_outline,
                title: 'Error',
                description: e.toString(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: AppSpacing.paddingMd,
      color: AppColors.surface,
      child: Column(
        children: [
          Row(
            children: List.generate(_steps.length, (index) {
              final isCompleted = index < _currentStep;
              final isCurrent = index == _currentStep;
              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.success
                            : isCurrent
                                ? AppColors.primary
                                : AppColors.surfaceVariant,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : Text(
                                '${index + 1}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: isCurrent
                                      ? AppColors.textOnPrimary
                                      : AppColors.textSecondary,
                                ),
                              ),
                      ),
                    ),
                    if (index < _steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isCompleted
                              ? AppColors.success
                              : AppColors.surfaceVariant,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          AppSpacing.vGapSm,
          Text(
            _steps[_currentStep],
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(String materialTitle) {
    switch (_currentStep) {
      case 0:
        return _PreTestStep(
          materialId: widget.materialId,
          onComplete: () => setState(() => _currentStep = 1),
        );
      case 1:
        return _EBookStep(
          materialTitle: materialTitle,
          onComplete: () => setState(() => _currentStep = 2),
        );
      case 2:
        return _PostTestStep(
          materialId: widget.materialId,
          onComplete: () => setState(() => _currentStep = 3),
        );
      case 3:
        return _PulseStep(
          materialId: widget.materialId,
          onComplete: () => _showCompletionDialog(),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari Pembelajaran?'),
        content: const Text('Progress Anda tidak akan disimpan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/student/learning');
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.celebration, color: AppColors.success),
            AppSpacing.hGapSm,
            const Text('Materi Selesai!'),
          ],
        ),
        content: const Text(
          'Selamat! Anda telah menyelesaikan materi ini. '
          'Lanjutkan ke materi lainnya atau lihat progress Anda.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/student/home');
            },
            child: const Text('Kembali Beranda'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/student/learning');
            },
            child: const Text('Materi Lain'),
          ),
        ],
      ),
    );
  }
}

// Pre-Test Step
class _PreTestStep extends ConsumerWidget {
  final int materialId;
  final VoidCallback onComplete;

  const _PreTestStep({required this.materialId, required this.onComplete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(questionsProvider((materialId: materialId, type: 'pre')));

    return questionsAsync.when(
      data: (questions) {
        if (questions.isEmpty) {
          return _StepPlaceholder(
            icon: Icons.quiz_outlined,
            title: 'Pre-Test',
            subtitle: 'Tidak ada soal pre-test untuk materi ini',
            buttonLabel: 'Lewati',
            onButtonPressed: onComplete,
          );
        }
        return _QuizView(
          questions: questions,
          title: 'Pre-Test',
          subtitle: 'Jawab pertanyaan berikut untuk mengukur pemahaman awal Anda',
          onComplete: onComplete,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

// E-Book Step
class _EBookStep extends StatelessWidget {
  final String materialTitle;
  final VoidCallback onComplete;

  const _EBookStep({required this.materialTitle, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return _StepPlaceholder(
      icon: Icons.menu_book,
      title: 'Baca Materi',
      subtitle: 'Bacalah materi dengan seksama sebelum melanjutkan ke post-test',
      materialTitle: materialTitle,
      buttonLabel: 'Selesai Membaca',
      onButtonPressed: onComplete,
    );
  }
}

// Post-Test Step
class _PostTestStep extends ConsumerWidget {
  final int materialId;
  final VoidCallback onComplete;

  const _PostTestStep({required this.materialId, required this.onComplete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(questionsProvider((materialId: materialId, type: 'post')));

    return questionsAsync.when(
      data: (questions) {
        if (questions.isEmpty) {
          return _StepPlaceholder(
            icon: Icons.quiz_outlined,
            title: 'Post-Test',
            subtitle: 'Tidak ada soal post-test untuk materi ini',
            buttonLabel: 'Lewati',
            onButtonPressed: onComplete,
          );
        }
        return _QuizView(
          questions: questions,
          title: 'Post-Test',
          subtitle: 'Jawab pertanyaan berikut untuk mengukur pemahaman Anda setelah membaca materi',
          onComplete: onComplete,
          showScoreComparison: true,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

// PULSE Step
class _PulseStep extends ConsumerWidget {
  final int materialId;
  final VoidCallback onComplete;

  const _PulseStep({required this.materialId, required this.onComplete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statementsAsync = ref.watch(pulseStatementsProvider(materialId));

    return statementsAsync.when(
      data: (statements) {
        if (statements.isEmpty) {
          return _StepPlaceholder(
            icon: Icons.favorite_outline,
            title: 'Refleksi PULSE',
            subtitle: 'Tidak ada pernyataan refleksi untuk materi ini',
            buttonLabel: 'Selesaikan',
            onButtonPressed: onComplete,
          );
        }
        return _LikertAssessmentView(
          statements: statements,
          onComplete: onComplete,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

// Step Placeholder Widget
class _StepPlaceholder extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? materialTitle;
  final String buttonLabel;
  final VoidCallback onButtonPressed;

  const _StepPlaceholder({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.materialTitle,
    required this.buttonLabel,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: AppColors.primary),
          ),
          AppSpacing.vGapLg,
          Text(
            title,
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vGapSm,
          if (materialTitle != null)
            Container(
              padding: AppSpacing.paddingSm,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: AppRadius.radiusMd,
              ),
              child: Text(
                materialTitle!,
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          AppSpacing.vGapMd,
          Text(
            subtitle,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vGapXl,
          AppButton(
            label: buttonLabel,
            onPressed: onButtonPressed,
            fullWidth: false,
          ),
        ],
      ),
    );
  }
}

// Quiz View Widget
class _QuizView extends ConsumerStatefulWidget {
  final List<Question> questions;
  final String title;
  final String subtitle;
  final VoidCallback onComplete;
  final bool showScoreComparison;

  const _QuizView({
    required this.questions,
    required this.title,
    required this.subtitle,
    required this.onComplete,
    this.showScoreComparison = false,
  });

  @override
  ConsumerState<_QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends ConsumerState<_QuizView> {
  int _currentQuestion = 0;
  final Map<int, String> _answers = {};
  bool _isSubmitted = false;
  int _score = 0;
  bool _isLoading = false;
  Map<String, dynamic>? _comparison;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_isSubmitted) {
      return _buildResultView();
    }

    final question = widget.questions[_currentQuestion];

    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress
          Row(
            children: [
              Text(
                'Pertanyaan ${_currentQuestion + 1}/${widget.questions.length}',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '${((_currentQuestion + 1) / widget.questions.length * 100).toInt()}%',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          AppSpacing.vGapSm,
          LinearProgressIndicator(
            value: (_currentQuestion + 1) / widget.questions.length,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
          AppSpacing.vGapLg,
          // Question
          Text(
            question.content,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          AppSpacing.vGapLg,
          // Options
          ...question.options.entries.map((entry) {
            final isSelected = _answers[question.id] == entry.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _answers[question.id] = entry.key;
                  });
                },
                borderRadius: AppRadius.radiusMd,
                child: Container(
                  padding: AppSpacing.cardPaddingCompact,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryLight.withValues(alpha: 0.2)
                        : AppColors.surface,
                    borderRadius: AppRadius.radiusMd,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.divider,
                      width: isSelected ? 2 : 1,
                    ),
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
                            entry.key,
                            style: AppTypography.labelMedium.copyWith(
                              color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      AppSpacing.hGapMd,
                      Expanded(
                        child: Text(
                          entry.value,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          // Navigation
          Row(
            children: [
              if (_currentQuestion > 0)
                TextButton(
                  onPressed: () => setState(() => _currentQuestion--),
                  child: const Text('Sebelumnya'),
                ),
              const Spacer(),
              if (_currentQuestion < widget.questions.length - 1)
                ElevatedButton(
                  onPressed: _answers.containsKey(question.id)
                      ? () => setState(() => _currentQuestion++)
                      : null,
                  child: const Text('Selanjutnya'),
                )
              else
                ElevatedButton(
                  onPressed: _answers.length == widget.questions.length ? _submitQuiz : null,
                  child: const Text('Kumpulkan'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _submitQuiz() async {
    if (widget.questions.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final firstQuestion = widget.questions.first;
    final materialId = firstQuestion.materialId;
    final type = firstQuestion.type;

    final answersList = widget.questions.map((q) {
      return {
        'question_id': q.id,
        'answer': _answers[q.id] ?? '',
      };
    }).toList();

    try {
      final result = await ref.read(materialServiceProvider).submitTestResponse(
        materialId: materialId,
        type: type,
        answers: answersList,
      );

      final returnedScore = result['score'] is num ? (result['score'] as num).toInt() : 0;
      final comparison = result['comparison'] as Map<String, dynamic>?;

      setState(() {
        _score = returnedScore;
        _comparison = comparison;
        _isSubmitted = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirimkan jawaban: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Widget _buildResultView() {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: _score >= 70 ? AppColors.successLight : AppColors.warningLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$_score%',
                style: AppTypography.headlineMedium.copyWith(
                  color: _score >= 70 ? AppColors.success : AppColors.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          AppSpacing.vGapLg,
          Text(
            _score >= 70 ? 'Bagus!' : 'Tetap Semangat!',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          AppSpacing.vGapSm,
          Text(
            'Skor ${widget.title}: $_score%',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (widget.showScoreComparison) ...[
            AppSpacing.vGapMd,
            Container(
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: AppRadius.radiusMd,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ScoreChip(
                    label: 'Pre',
                    score: '${_comparison?['pre_score'] ?? 75}%',
                    color: AppColors.info,
                  ),
                  AppSpacing.hGapMd,
                  _ScoreChip(
                    label: 'Post',
                    score: '${_comparison?['post_score'] ?? _score}%',
                    color: AppColors.success,
                  ),
                ],
              ),
            ),
          ],
          AppSpacing.vGapXl,
          AppButton(
            label: 'Lanjutkan',
            onPressed: widget.onComplete,
          ),
        ],
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  final String label;
  final String score;
  final Color color;

  const _ScoreChip({required this.label, required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          score,
          style: AppTypography.titleMedium.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// Likert Assessment View
class _LikertAssessmentView extends ConsumerStatefulWidget {
  final List<PulseStatement> statements;
  final VoidCallback onComplete;

  const _LikertAssessmentView({required this.statements, required this.onComplete});

  @override
  ConsumerState<_LikertAssessmentView> createState() => _LikertAssessmentViewState();
}

class _LikertAssessmentViewState extends ConsumerState<_LikertAssessmentView> {
  final Map<int, int> _responses = {};
  int _currentIndex = 0;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final statement = widget.statements[_currentIndex];
    final dimension = _getDimensionLabel(statement.dimension);

    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.2),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Text(
                  dimension,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${_currentIndex + 1}/${widget.statements.length}',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          LinearProgressIndicator(
            value: (_currentIndex + 1) / widget.statements.length,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
          AppSpacing.vGapXl,
          // Statement
          Text(
            statement.statement,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          AppSpacing.vGapLg,
          // Likert Scale
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final value = index + 1;
              final isSelected = _responses[statement.id] == value;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _responses[statement.id] = value;
                  });
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surface,
                    borderRadius: AppRadius.radiusMd,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.divider,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$value',
                        style: AppTypography.titleMedium.copyWith(
                          color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getScaleLabel(value),
                        style: AppTypography.labelSmall.copyWith(
                          fontSize: 8,
                          color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          AppSpacing.vGapSm,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tidak Pernah',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'Selalu',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Navigation
          Row(
            children: [
              if (_currentIndex > 0)
                TextButton(
                  onPressed: () => setState(() => _currentIndex--),
                  child: const Text('Sebelumnya'),
                ),
              const Spacer(),
              if (_currentIndex < widget.statements.length - 1)
                ElevatedButton(
                  onPressed: _responses.containsKey(statement.id)
                      ? () => setState(() => _currentIndex++)
                      : null,
                  child: const Text('Selanjutnya'),
                )
              else
                ElevatedButton(
                  onPressed: _responses.length == widget.statements.length
                      ? _submitPulse
                      : null,
                  child: const Text('Kumpulkan'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _submitPulse() async {
    if (widget.statements.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final firstStatement = widget.statements.first;
    final materialId = firstStatement.materialId;

    final responseList = widget.statements.map((s) {
      return {
        'statement_id': s.id,
        'score': _responses[s.id] ?? 3,
      };
    }).toList();

    try {
      await ref.read(materialServiceProvider).submitPulseResponse(
        materialId: materialId,
        responses: responseList,
      );

      ref.invalidate(pulseScoresProvider);
      ref.invalidate(studentProgressProvider);
      ref.invalidate(materialsProvider);

      setState(() {
        _isLoading = false;
      });

      widget.onComplete();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirimkan refleksi: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  String _getDimensionLabel(String dimension) {
    switch (dimension) {
      case 'participation':
        return 'Partisipasi';
      case 'understanding':
        return 'Pemahaman';
      case 'learning':
        return 'Pembelajaran';
      case 'social_engagement':
        return 'Keterlibatan Sosial';
      default:
        return dimension;
    }
  }

  String _getScaleLabel(int value) {
    switch (value) {
      case 1:
        return 'Tidak';
      case 2:
        return 'Jarang';
      case 3:
        return 'Kadang';
      case 4:
        return 'Sering';
      case 5:
        return 'Selalu';
      default:
        return '';
    }
  }
}
