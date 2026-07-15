import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radar_chart_plus/radar_chart_plus.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/services/data_models.dart';
import '../../learning/providers/material_provider.dart';

class ScoresFeedbackScreen extends ConsumerWidget {
  const ScoresFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pulseScoresAsync = ref.watch(pulseScoresProvider);
    final progressAsync = ref.watch(studentProgressProvider);

    return GradientShellScaffold(
      title: 'Skor & Umpan Balik',
      subtitle: 'Perkembangan PULSE-mu',
      onRefresh: () async {
        ref.invalidate(pulseScoresProvider);
        ref.invalidate(studentProgressProvider);
      },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PULSE Radar Chart
          pulseScoresAsync.when(
            data: (scores) => _buildPulseSection(scores),
            loading: () => _buildLoadingCard('Memuat skor PULSE...'),
            error: (e, _) => _buildErrorCard('Gagal memuat skor PULSE'),
          ),
          AppSpacing.vGapLg,

          // Material Progress
          Text(
            'Progress Materi',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          AppSpacing.vGapMd,
          progressAsync.when(
            data: (progress) => _buildProgressList(context, progress),
            loading: () => _buildLoadingCard('Memuat progress...'),
            error: (e, _) => _buildErrorCard('Gagal memuat progress'),
          ),
          AppSpacing.vGapLg,

          // Recommendations
          _buildRecommendationCard(pulseScoresAsync),
          AppSpacing.vGapXl,
        ],
      ),
    );
  }

  Widget _buildPulseSection(PulseScores scores) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Skor PULSE',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: _getOverallStatusColor(scores.overall),
                  borderRadius: AppRadius.chip,
                ),
                child: Text(
                  _getOverallLabel(scores.overall),
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vGapMd,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: SizedBox(
              height: 220,
              child: RadarChartPlus(
                ticks: const [1.0, 2.0, 3.0, 4.0, 5.0],
                labels: const ['Partisipasi', 'Pemahaman', 'Pembelajaran', 'Keterlibatan'],
                shape: RadarChartShape.polygon,
                horizontalLabels: true,
                labelSpacing: 8,
                labelPadding: 32.0,
                labelTextStyle: AppTypography.labelSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                tickTextStyle: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                ringsStyle: RadarChartLineStyle(
                  color: AppColors.divider,
                  strokeWidth: 1,
                ),
                borderStyle: RadarChartLineStyle(
                  color: AppColors.divider,
                  strokeWidth: 1,
                ),
                dataSets: [
                  RadarDataSet(
                    data: [
                      scores.participation,
                      scores.understanding,
                      scores.learning,
                      scores.socialEngagement,
                    ],
                    borderColor: AppColors.primary,
                    fillColor: AppColors.primary.withValues(alpha: 0.3),
                    dotColor: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          AppSpacing.vGapMd,
          // Score legend
          _buildScoreLegend(scores),
        ],
      ),
    );
  }

  Widget _buildScoreLegend(PulseScores scores) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildScoreItem('Partisipasi', scores.participation, Icons.how_to_reg)),
            AppSpacing.hGapSm,
            Expanded(child: _buildScoreItem('Pemahaman', scores.understanding, Icons.lightbulb_outline)),
          ],
        ),
        AppSpacing.vGapSm,
        Row(
          children: [
            Expanded(child: _buildScoreItem('Pembelajaran', scores.learning, Icons.school_outlined)),
            AppSpacing.hGapSm,
            Expanded(child: _buildScoreItem('Keterlibatan', scores.socialEngagement, Icons.people_outline)),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreItem(String label, double score, IconData icon) {
    final color = _getScoreColor(score);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: AppRadius.radiusSm,
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          AppSpacing.hGapXs,
          Expanded(
            child: Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            score.toStringAsFixed(1),
            style: AppTypography.labelLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressList(BuildContext context, List<StudentProgress> progress) {
    return Column(
      children: progress.map((p) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _MaterialProgressCard(progress: p),
        );
      }).toList(),
    );
  }

  Widget _buildRecommendationCard(AsyncValue<PulseScores> scoresAsync) {
    return scoresAsync.when(
      data: (scores) {
        final recommendations = _getRecommendations(scores);
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb, color: AppColors.secondary),
                  AppSpacing.hGapSm,
                  Text(
                    'Saran Pengembangan',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              AppSpacing.vGapMd,
              ...recommendations.map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.arrow_right,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    AppSpacing.hGapXs,
                    Expanded(
                      child: Text(
                        rec,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildLoadingCard(String message) {
    return AppCard(
      child: SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              AppSpacing.vGapMd,
              Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return AppCard(
      child: SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.danger),
              AppSpacing.vGapMd,
              Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 3.5) return AppColors.success;
    if (score >= 2.5) return AppColors.warning;
    return AppColors.danger;
  }

  Color _getOverallStatusColor(double score) {
    if (score >= 3.5) return AppColors.success;
    if (score >= 2.5) return AppColors.warning;
    return AppColors.danger;
  }

  String _getOverallLabel(double score) {
    if (score >= 3.5) return 'Baik';
    if (score >= 2.5) return 'Perlu Perbaikan';
    return 'Perlu Perhatian';
  }

  List<String> _getRecommendations(PulseScores scores) {
    final recommendations = <String>[];

    if (scores.participation < 3.5) {
      recommendations.add('Tingkatkan partisipasi dengan lebih aktif mengikuti diskusi kelas dan kegiatan kelompok.');
    }
    if (scores.understanding < 3.5) {
      recommendations.add('Perdalam pemahaman dengan membaca materi tambahan dan berdiskusi dengan teman.');
    }
    if (scores.learning < 3.5) {
      recommendations.add('Tingkatkan pembelajaran dengan mengerjakan latihan soal dan belajar rutin setiap hari.');
    }
    if (scores.socialEngagement < 3.5) {
      recommendations.add('Perluas keterlibatan sosial dengan mengikuti kegiatan ekstrakurikuler dan kegiatan masyarakat.');
    }

    if (recommendations.isEmpty) {
      recommendations.add('Pertahankan semangat belajar! Skor PULSE kamu sudah sangat baik.');
      recommendations.add('Terus berkontribusi positif di kelas dan lingkungan sekitar.');
    }

    return recommendations;
  }
}

class _MaterialProgressCard extends ConsumerWidget {
  final StudentProgress progress;

  const _MaterialProgressCard({required this.progress});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Materi #${progress.materialId}',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          AppSpacing.vGapSm,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildStep(
                  'Pre-test',
                  progress.preTestStatus,
                  progress.preTestScore,
                ),
              ),
              _buildArrow(),
              Expanded(
                child: _buildStep(
                  'E-Book',
                  progress.ebookStatus,
                  null,
                ),
              ),
              _buildArrow(),
              Expanded(
                child: _buildStep(
                  'Post-test',
                  progress.postTestStatus,
                  progress.postTestScore,
                ),
              ),
              _buildArrow(),
              Expanded(
                child: _buildStep(
                  'PULSE',
                  progress.pulseStatus,
                  progress.pulseScore,
                  onTap: progress.pulseStatus == 'completed'
                      ? () => _showPulseDetailsDialog(context, ref, progress.materialId)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArrow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Container(
        height: 32,
        alignment: Alignment.center,
        child: const Icon(Icons.arrow_forward, size: 16, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildStep(String label, String status, int? score, {VoidCallback? onTap}) {
    final isCompleted = status == 'completed';
    final content = Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.success : AppColors.divider,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check : Icons.circle_outlined,
            size: 16,
            color: isCompleted ? Colors.white : AppColors.textSecondary,
          ),
        ),
        AppSpacing.vGapXs,
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          score != null ? '$score%' : '-',
          style: AppTypography.labelSmall.copyWith(
            color: score != null ? AppColors.textPrimary : Colors.transparent,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );

    final paddedContent = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: content,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        child: paddedContent,
      );
    }
    return paddedContent;
  }

  double _getAverageForDimension(List<PulseStatement> statements, String dimension) {
    final filtered = statements.where((s) {
      final dim = s.dimension.toLowerCase();
      if (dimension == 'participation') return dim == 'participation' || dim == 'p';
      if (dimension == 'understanding') return dim == 'understanding' || dim == 'u';
      if (dimension == 'learning') return dim == 'learning' || dim == 'l';
      if (dimension == 'social_engagement') return dim == 'social_engagement' || dim == 'se';
      return false;
    }).toList();

    if (filtered.isEmpty) return 0.0;
    final sum = filtered.fold<int>(0, (sum, item) => sum + (item.score ?? 0));
    return sum / filtered.length;
  }

  void _showPulseDetailsDialog(BuildContext context, WidgetRef ref, int materialId) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final statementsAsync = ref.watch(pulseStatementsProvider(materialId));
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.card,
              ),
              title: Text(
                'Skor PULSE Materi',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: statementsAsync.when(
                  data: (statements) {
                    if (statements.isEmpty) {
                      return const Center(child: Text('Tidak ada instrumen PULSE.'));
                    }

                    // Calculate averages for 4 dimensions
                    final pScore = _getAverageForDimension(statements, 'participation');
                    final uScore = _getAverageForDimension(statements, 'understanding');
                    final lScore = _getAverageForDimension(statements, 'learning');
                    final seScore = _getAverageForDimension(statements, 'social_engagement');

                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildDialogScoreRow('Partisipasi', pScore),
                          Divider(color: AppColors.divider, height: 1),
                          _buildDialogScoreRow('Pemahaman', uScore),
                          Divider(color: AppColors.divider, height: 1),
                          _buildDialogScoreRow('Pembelajaran', lScore),
                          Divider(color: AppColors.divider, height: 1),
                          _buildDialogScoreRow('Keterlibatan', seScore),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox(
                    height: 150,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => SizedBox(
                    height: 150,
                    child: Center(
                      child: Text(
                        'Gagal memuat detail skor.',
                        style: TextStyle(color: AppColors.danger),
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Tutup'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDialogScoreRow(String label, double score) {
    Color getScoreColor(double s) {
      if (s >= 3.5) return AppColors.success;
      if (s >= 2.5) return AppColors.warning;
      return AppColors.danger;
    }

    final color = getScoreColor(score);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: AppRadius.chip,
                ),
                child: Text(
                  score.toStringAsFixed(1),
                  style: AppTypography.titleSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vGapSm,
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 5.0,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}