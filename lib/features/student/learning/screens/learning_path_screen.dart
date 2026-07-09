import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/network/network.dart';
import '../../../../shared/services/services.dart';
import '../providers/material_provider.dart';
import '../widgets/challenge_games/content_card.dart';
import '../widgets/challenge_games/matching_game_card.dart';
import '../widgets/challenge_games/multiple_choice_card.dart';
import '../widgets/challenge_games/sorting_game_card.dart';
import '../widgets/challenge_games/true_false_swipe_card.dart';

class LearningPathScreen extends ConsumerStatefulWidget {
  final int materialId;

  const LearningPathScreen({super.key, required this.materialId});

  @override
  ConsumerState<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends ConsumerState<LearningPathScreen> {
  int _currentStep = 0;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final materialAsync = ref.watch(materialProvider(widget.materialId));

    return materialAsync.when(
      data: (material) {
        if (material == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('Belajar'),
              backgroundColor: AppColors.surface,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.go('/student/learning'),
              ),
            ),
            body: const EmptyState(
              icon: Icons.error_outline,
              title: 'Materi Tidak Ditemukan',
              description: 'Materi yang Anda cari tidak tersedia',
            ),
          );
        }

        final isCompleted = material.status == 'completed';

        final steps = material.isLearningBoard
            ? ['Pre-Test', 'Baca E-Book', 'Papan Aktivitas', 'Post-Test']
            : ['Pre-Test', 'Baca E-Book', 'Post-Test'];

        if (!_initialized) {
          if (material.preTestScore == null) {
            _currentStep = 0;
          } else if (material.ebookStatus != 'completed') {
            _currentStep = 1;
          } else if (material.isLearningBoard && material.boardStatus != 'completed') {
            _currentStep = 2;
          } else {
            _currentStep = material.isLearningBoard ? 3 : 2;
          }
          _initialized = true;
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(isCompleted ? 'Hasil Evaluasi' : 'Belajar'),
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: IconButton(
              icon: Icon(isCompleted ? Icons.arrow_back : Icons.close),
              onPressed: () => isCompleted
                  ? context.go('/student/learning')
                  : _showExitDialog(context),
            ),
          ),
          body: isCompleted
              ? _buildCompletedView(material)
              : Column(
                  children: [
                    // Progress indicator
                    _buildProgressIndicator(steps),
                    // Content
                    Expanded(child: _buildStepContent(material)),
                  ],
                ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Belajar'),
          backgroundColor: AppColors.surface,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Belajar'),
          backgroundColor: AppColors.surface,
          elevation: 0,
        ),
        body: EmptyState(
          icon: Icons.error_outline,
          title: 'Error',
          description: e.toString(),
        ),
      ),
    );
  }

  Widget _buildCompletedView(LearningMaterial material) {
    final preScore = material.preTestScore;
    final postScore = material.postTestScore;

    return Padding(
      padding: AppSpacing.screenPadding,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.successLight.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 48,
                  color: AppColors.success,
                ),
              ),
              AppSpacing.vGapLg,
              Text(
                'Materi Telah Selesai',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.vGapSm,
              Text(
                material.title,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.vGapXl,
              AppCard(
                child: Column(
                  children: [
                    Text(
                      'Hasil Evaluasi Belajar',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.vGapMd,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildResultScoreMetric(
                          'Pre-Test',
                          preScore,
                          AppColors.info,
                        ),
                        _buildResultScoreMetric(
                          'Post-Test',
                          postScore,
                          AppColors.success,
                        ),
                        _buildResultScoreMetric(
                          'Peningkatan',
                          (preScore != null && postScore != null)
                              ? (postScore - preScore)
                              : null,
                          (preScore != null &&
                                  postScore != null &&
                                  postScore >= preScore)
                              ? AppColors.success
                              : AppColors.danger,
                          showSign: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AppSpacing.vGapXl,
              Text(
                'Anda sudah menyelesaikan seluruh tahapan belajar, evaluasi, dan refleksi PULSE untuk materi ini.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.vGapLg,
              AppButton(
                label: 'Baca Kembali Materi',
                variant: AppButtonVariant.primary,
                onPressed: () => _showMaterialDialog(context, material),
                fullWidth: true,
              ),
              AppSpacing.vGapMd,
              AppButton(
                label: 'Kembali Ke Galeri',
                variant: AppButtonVariant.outline,
                onPressed: () => context.go('/student/learning'),
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMaterialDialog(BuildContext context, LearningMaterial material) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Materi Belajar'),
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: _EBookStep(
            material: material,
            onComplete: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  Widget _buildResultScoreMetric(
    String label,
    int? score,
    Color color, {
    bool showSign = false,
  }) {
    final text = score == null
        ? '-'
        : (showSign && score > 0 ? '+$score' : '$score');
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        AppSpacing.vGapXs,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: AppRadius.radiusMd,
          ),
          child: Text(
            score != null ? '$text%' : '-',
            style: AppTypography.titleLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(List<String> steps) {
    return Container(
      padding: AppSpacing.paddingMd,
      color: AppColors.surface,
      child: Column(
        children: [
          Row(
            children: List.generate(steps.length, (index) {
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
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
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
                    if (index < steps.length - 1)
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
            steps[_currentStep],
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(LearningMaterial material) {
    if (material.isLearningBoard) {
      switch (_currentStep) {
        case 0:
          return _PreTestStep(
            materialId: widget.materialId,
            onComplete: () => setState(() => _currentStep = 1),
          );
        case 1:
          return _EBookStep(
            material: material,
            onComplete: () async {
              try {
                await ref.read(materialServiceProvider).completeMedia(material.id);
                // Invalidate material cache to fetch updated statuses
                ref.invalidate(materialProvider(material.id));
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal memperbarui progress media: $e'),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                }
                return;
              }
              if (mounted) {
                setState(() => _currentStep = 2);
              }
            },
          );
        case 2:
          return _LearningBoardStep(
            material: material,
            onComplete: () => setState(() => _currentStep = 3),
          );
        case 3:
          return _PostTestStep(
            materialId: widget.materialId,
            onComplete: _showCompletionDialog,
          );
        default:
          return const SizedBox.shrink();
      }
    } else {
      switch (_currentStep) {
        case 0:
          return _PreTestStep(
            materialId: widget.materialId,
            onComplete: () => setState(() => _currentStep = 1),
          );
        case 1:
          return _EBookStep(
            material: material,
            onComplete: () => setState(() => _currentStep = 2),
          );
        case 2:
          return _PostTestStep(
            materialId: widget.materialId,
            onComplete: _showCompletionDialog,
          );
        default:
          return const SizedBox.shrink();
      }
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
    final questionsAsync = ref.watch(
      questionsProvider((materialId: materialId, type: 'pre')),
    );

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
          subtitle:
              'Jawab pertanyaan berikut untuk mengukur pemahaman awal Anda',
          onComplete: onComplete,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

// =============================================================================
// LEARNING BOARD STEP (Fase 3) — ganti _EBookStep untuk materi learning_board
// =============================================================================
class _LearningBoardStep extends ConsumerStatefulWidget {
  final LearningMaterial material;
  final VoidCallback onComplete;

  const _LearningBoardStep({required this.material, required this.onComplete});

  @override
  ConsumerState<_LearningBoardStep> createState() => _LearningBoardStepState();
}

class _LearningBoardStepState extends ConsumerState<_LearningBoardStep> {
  int _currentNodeIndex = 0;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final boardAsync = ref.watch(learningBoardProvider(widget.material.id));

    return boardAsync.when(
      data: (nodes) {
        if (nodes.isEmpty) {
          return _StepPlaceholder(
            icon: Icons.grid_view_outlined,
            title: 'Papan Aktivitas',
            subtitle: 'Tidak ada aktivitas untuk materi ini',
            buttonLabel: 'Lanjut ke Post-Test',
            onButtonPressed: widget.onComplete,
          );
        }

        // Find first incomplete node or use _currentNodeIndex
        final startIndex = _findCurrentNodeIndex(nodes);
        final effectiveIndex = _currentNodeIndex.clamp(startIndex, nodes.length - 1);
        final node = nodes[effectiveIndex];
        final completed = nodes.where((n) => n.isCompleted).length;
        final total = nodes.length;

        return Column(
          children: [
            // Progress header
            _buildBoardHeader(completed, total, effectiveIndex, nodes.length),
            // Node content
            Expanded(
              child: _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : _buildNodeCard(node, nodes, effectiveIndex),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
            AppSpacing.vGapMd,
            Text('Gagal memuat papan aktivitas:\n$e',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
            AppSpacing.vGapMd,
            AppButton(
              label: 'Coba Lagi',
              onPressed: () => ref.invalidate(learningBoardProvider(widget.material.id)),
            ),
          ],
        ),
      ),
    );
  }

  int _findCurrentNodeIndex(List<LearningNode> nodes) {
    // Resume from last incomplete node
    for (int i = 0; i < nodes.length; i++) {
      if (!nodes[i].isCompleted) return i;
    }
    return nodes.length - 1; // all done
  }

  Widget _buildBoardHeader(int completed, int total, int currentIdx, int nodeCount) {
    final percent = total > 0 ? completed / total : 0.0;
    return Container(
      padding: AppSpacing.paddingMd,
      color: AppColors.surface,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.12),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.grid_view_rounded, size: 13, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Papan Aktivitas',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'Kotak ${currentIdx + 1} dari $nodeCount',
                style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: AppRadius.radiusSm,
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeCard(LearningNode node, List<LearningNode> nodes, int index) {
    if (node.isContent) {
      return ContentCard(
        node: node,
        onComplete: () => _onNodeDone(node, nodes, index, {}),
      );
    }
    if (node.isSocialTask) {
      return _SocialTaskCard(
        node: node,
        material: widget.material,
        onComplete: () => _onNodeDone(node, nodes, index, {}),
      );
    }
    if (node.isChallenge) {
      return _buildChallengeCard(node, nodes, index);
    }
    return _StepPlaceholder(
      icon: Icons.help_outline,
      title: 'Kotak Tidak Dikenal',
      subtitle: 'Tipe node tidak dikenal: ${node.nodeType}',
      buttonLabel: 'Lewati',
      onButtonPressed: () => _onNodeDone(node, nodes, index, {}),
    );
  }

  Widget _buildChallengeCard(LearningNode node, List<LearningNode> nodes, int index) {
    void Function(Map<String, dynamic>) onDone = (answer) => _onNodeDone(node, nodes, index, answer);
    switch (node.gameType) {
      case 'matching':
        return MatchingGameCard(node: node, onComplete: onDone);
      case 'sorting':
        return SortingGameCard(node: node, onComplete: onDone);
      case 'true_false_swipe':
        return TrueFalseSwipeCard(node: node, onComplete: onDone);
      case 'multiple_choice':
      default:
        return MultipleChoiceCard(node: node, onComplete: onDone);
    }
  }

  Future<void> _onNodeDone(
    LearningNode node,
    List<LearningNode> nodes,
    int index,
    Map<String, dynamic> answer,
  ) async {
    // Social task is handled by _SocialTaskCard itself
    if (!node.isSocialTask) {
      setState(() => _isSubmitting = true);
      try {
        bool? isCorrect;
        if (node.nodeType == 'challenge') {
          isCorrect = false; // default
          if (node.gameType == 'multiple_choice') {
            final correctAnswer = node.payload?['correct']?.toString();
            final selectedAnswer = answer['selected']?.toString();
            isCorrect = selectedAnswer != null && selectedAnswer == correctAnswer;
          } else if (node.gameType == 'true_false_swipe') {
            final payload = node.payload ?? {};
            final rawStatements = payload['statements'];
            final totalStatements = rawStatements is List ? rawStatements.length : 0;
            final correctCount = answer['correct'] as int? ?? 0;
            isCorrect = totalStatements > 0 && correctCount == totalStatements;
          } else if (node.gameType == 'sorting') {
            final payload = node.payload ?? {};
            final rawItems = payload['items'];
            final totalItems = rawItems is List ? rawItems.length : 0;
            final correctCount = answer['correct'] as int? ?? 0;
            isCorrect = totalItems > 0 && correctCount == totalItems;
          } else if (node.gameType == 'matching') {
            final payload = node.payload ?? {};
            final rawPairs = payload['pairs'];
            if (rawPairs is List) {
              final correctMap = {
                for (final p in rawPairs)
                  if (p is Map && p['left'] != null && p['right'] != null)
                    p['left'].toString(): p['right'].toString()
              };
              final userMatches = answer['matches'];
              if (userMatches is Map) {
                isCorrect = correctMap.isNotEmpty &&
                    correctMap.entries.every((e) => userMatches[e.key]?.toString() == e.value);
              }
            }
          }
        }

        await ref.read(completeNodeProvider.notifier).complete(
          materialId: widget.material.id,
          nodeId: node.id,
          submittedAnswer: answer,
          isCorrect: isCorrect,
        );

        if (!mounted) return;

        // Only advance if successfully completed
        if (index < nodes.length - 1) {
          setState(() => _currentNodeIndex = index + 1);
        } else {
          // All nodes done → go to Post-Test
          widget.onComplete();
        }
      } catch (e) {
        if (mounted) {
          final errorMessage = e is ApiException ? e.message : e.toString();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Gagal menyimpan: $errorMessage'),
            backgroundColor: AppColors.danger,
          ));
        }
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    } else {
      // For social task fallback or other nodes
      if (index < nodes.length - 1) {
        setState(() => _currentNodeIndex = index + 1);
      } else {
        widget.onComplete();
      }
    }
  }
}

// =============================================================================
// SOCIAL TASK CARD — upload bukti untuk Tantangan Sosial
// =============================================================================
class _SocialTaskCard extends ConsumerStatefulWidget {
  final LearningNode node;
  final LearningMaterial material;
  final VoidCallback onComplete;

  const _SocialTaskCard({
    required this.node,
    required this.material,
    required this.onComplete,
  });

  @override
  ConsumerState<_SocialTaskCard> createState() => _SocialTaskCardState();
}

class _SocialTaskCardState extends ConsumerState<_SocialTaskCard> {
  final _captionController = TextEditingController();
  String? _photoPath;
  bool _isSubmitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (picked != null) {
        setState(() => _photoPath = picked.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih foto: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  Future<void> _submit() async {
    final captionText = _captionController.text.trim();
    if (captionText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tulis cerita singkat terlebih dahulu')),
      );
      return;
    }
    if (captionText.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tulis cerita singkat minimal 10 karakter'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await ref.read(materialServiceProvider).submitSocialTask(
        materialId: widget.material.id,
        nodeId: widget.node.id,
        caption: captionText,
        photoPath: _photoPath,
      );
      setState(() {
        _isSubmitting = false;
        _submitted = true;
      });
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        final errorMessage = e is ApiException ? e.message : e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim: $errorMessage'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_submitted) {
      return _buildSuccessView();
    }
    return _buildFormView();
  }

  Widget _buildSuccessView() {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.successLight.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, size: 48, color: AppColors.success),
          ),
          AppSpacing.vGapLg,
          Text(
            'Tantangan Sosial Dikirim!',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.vGapSm,
          Text(
            'Bukti kamu sedang menunggu review guru.\nKamu bisa lanjut ke Post-Test sekarang.',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vGapXl,
          AppButton(
            label: 'Lanjut ke Post-Test',
            variant: AppButtonVariant.primary,
            onPressed: widget.onComplete,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: AppRadius.radiusSm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.people_outline, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  'Tantangan Sosial',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          AppSpacing.vGapMd,
          if (widget.node.title != null)
            Text(
              widget.node.title!,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          AppSpacing.vGapSm,
          if (widget.node.body != null)
            Container(
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.07),
                borderRadius: AppRadius.radiusMd,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Text(
                widget.node.body!,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary, height: 1.6),
              ),
            ),
          AppSpacing.vGapLg,
          Text(
            'Unggah Bukti (Foto)',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.vGapSm,
          GestureDetector(
            onTap: _pickPhoto,
            child: Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                color: _photoPath != null
                    ? AppColors.successLight.withValues(alpha: 0.08)
                    : AppColors.surfaceVariant,
                borderRadius: AppRadius.radiusMd,
                border: Border.all(
                  color: _photoPath != null ? AppColors.success : AppColors.divider,
                  style: BorderStyle.solid,
                ),
              ),
              child: _photoPath != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.success, size: 32),
                        AppSpacing.vGapSm,
                        Text(
                          'Foto dipilih ✓',
                          style: AppTypography.labelMedium.copyWith(color: AppColors.success),
                        ),
                        AppSpacing.vGapXs,
                        Text(
                          'Ketuk untuk ganti',
                          style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppColors.textSecondary),
                        AppSpacing.vGapSm,
                        Text(
                          'Ketuk untuk pilih foto',
                          style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
                        ),
                        Text(
                          '(opsional)',
                          style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
            ),
          ),
          AppSpacing.vGapLg,
          Text(
            'Ceritakan Singkat',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.vGapSm,
          TextField(
            controller: _captionController,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Ceritakan apa yang kamu lakukan, di mana, dan bagaimana kaitannya dengan toleransi...',
              hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: AppRadius.radiusMd,
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusMd,
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: AppColors.surface,
            ),
          ),
          AppSpacing.vGapMd,
          AppButton(
            label: 'Kirim Tantangan Sosial',
            variant: AppButtonVariant.primary,
            onPressed: _submit,
            fullWidth: true,
          ),
          AppSpacing.vGapSm,
          Text(
            'Kamu dapat lanjut ke Post-Test setelah mengirim. Skor Social Engagement akan dinilai guru.',
            style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// E-Book Step (dipertahankan untuk backward-compat materi classic_pdf)
class _EBookStep extends StatefulWidget {
  final LearningMaterial material;
  final VoidCallback onComplete;

  const _EBookStep({required this.material, required this.onComplete});

  @override
  State<_EBookStep> createState() => _EBookStepState();
}

class _EBookStepState extends State<_EBookStep> {
  bool _hasRead = false;
  bool _pdfError = false;

  bool get _isPdf {
    final url = widget.material.fileUrl ?? '';
    return url.toLowerCase().contains('.pdf') ||
        url.toLowerCase().contains('pdf');
  }

  bool get _hasFile => (widget.material.fileUrl ?? '').isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!_hasFile) {
      // Tidak ada file — tampilkan description atau pesan
      return _buildNoFileView();
    }

    if (_isPdf && !_pdfError) {
      return _buildPdfView();
    }

    return _buildWebFallbackView();
  }

  Widget _buildPdfView() {
    return Column(
      children: [
        // Header
        Container(
          padding: AppSpacing.paddingMd,
          color: AppColors.surface,
          child: Row(
            children: [
              const Icon(Icons.picture_as_pdf, color: AppColors.danger),
              AppSpacing.hGapSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.material.title,
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.material.description != null)
                      Text(
                        widget.material.description!,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // PDF Viewer
        Expanded(
          child: SfPdfViewer.network(
            widget.material.fileUrl!,
            onDocumentLoadFailed: (details) {
              setState(() => _pdfError = true);
            },
            onPageChanged: (details) {
              if (!_hasRead) setState(() => _hasRead = true);
            },
          ),
        ),
        // Bottom action
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildWebFallbackView() {
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
            child: const Icon(
              Icons.menu_book,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          AppSpacing.vGapLg,
          Text(
            widget.material.title,
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.material.description != null) ...[
            AppSpacing.vGapSm,
            Container(
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: AppRadius.radiusMd,
              ),
              child: Text(
                widget.material.description!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          AppSpacing.vGapLg,
          OutlinedButton.icon(
            onPressed: () async {
              final uri = Uri.parse(widget.material.fileUrl!);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
                setState(() => _hasRead = true);
              }
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Buka Materi'),
          ),
          AppSpacing.vGapXl,
          AppButton(
            label: 'Selesai Membaca',
            onPressed: _hasRead ? widget.onComplete : null,
            fullWidth: false,
          ),
          if (!_hasRead) ...[
            AppSpacing.vGapSm,
            Text(
              'Buka materi terlebih dahulu',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoFileView() {
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
            child: const Icon(
              Icons.menu_book,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          AppSpacing.vGapLg,
          Text(
            widget.material.title,
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.material.description != null) ...[
            AppSpacing.vGapMd,
            Container(
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: AppRadius.radiusMd,
              ),
              child: Text(
                widget.material.description!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ] else ...[
            AppSpacing.vGapSm,
            Text(
              'Bacalah materi dengan seksama sebelum melanjutkan ke post-test',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          AppSpacing.vGapXl,
          AppButton(
            label: 'Selesai Membaca',
            onPressed: widget.onComplete,
            fullWidth: false,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: AppSpacing.paddingMd,
      color: AppColors.surface,
      child: Row(
        children: [
          if (_hasRead)
            const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 20),
                SizedBox(width: 6),
                Text(
                  'Sudah dibaca',
                  style: TextStyle(color: AppColors.success, fontSize: 13),
                ),
              ],
            )
          else
            Text(
              'Scroll untuk membaca materi',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          const Spacer(),
          ElevatedButton(
            onPressed: _hasRead ? widget.onComplete : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, AppSpacing.minTouchTarget),
            ),
            child: const Text('Selesai Membaca'),
          ),
        ],
      ),
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
    final questionsAsync = ref.watch(
      questionsProvider((materialId: materialId, type: 'post')),
    );

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
          subtitle:
              'Jawab pertanyaan berikut untuk mengukur pemahaman Anda setelah membaca materi',
          onComplete: onComplete,
          showScoreComparison: true,
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
  final String buttonLabel;
  final VoidCallback onButtonPressed;

  const _StepPlaceholder({
    required this.icon,
    required this.title,
    required this.subtitle,
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
      return const Center(child: CircularProgressIndicator());
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
          // Scrollable Question & Options Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.surfaceVariant,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    entry.key,
                                    style: AppTypography.labelMedium.copyWith(
                                      color: isSelected
                                          ? AppColors.textOnPrimary
                                          : AppColors.textPrimary,
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
                ],
              ),
            ),
          ),
          AppSpacing.vGapMd,
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
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, AppSpacing.minTouchTarget),
                  ),
                  child: const Text('Selanjutnya'),
                )
              else
                ElevatedButton(
                  onPressed: _answers.length == widget.questions.length
                      ? _submitQuiz
                      : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, AppSpacing.minTouchTarget),
                  ),
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
      return {'question_id': q.id, 'answer': _answers[q.id] ?? ''};
    }).toList();

    try {
      final result = await ref
          .read(materialServiceProvider)
          .submitTestResponse(
            materialId: materialId,
            type: type,
            answers: answersList,
          );

      final returnedScore = result['score'] is num
          ? (result['score'] as num).toInt()
          : 0;
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
              color: _score >= 70
                  ? AppColors.successLight
                  : AppColors.warningLight,
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
          AppButton(label: 'Lanjutkan', onPressed: widget.onComplete),
        ],
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  final String label;
  final String score;
  final Color color;

  const _ScoreChip({
    required this.label,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          score,
          style: AppTypography.titleMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
