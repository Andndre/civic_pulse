import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../shared/services/mock_models.dart';
import '../../learning/providers/material_provider.dart';

class ScoresFeedbackScreen extends ConsumerWidget {
  const ScoresFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pulseScoresAsync = ref.watch(pulseScoresProvider);
    final progressAsync = ref.watch(studentProgressProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Skor & Umpan Balik'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
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
          SizedBox(
            height: 250,
            child: RadarChart(
              RadarChartData(
                radarShape: RadarShape.polygon,
                tickCount: 5,
                ticksTextStyle: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                tickBorderData: BorderSide(
                  color: AppColors.divider,
                  width: 1,
                ),
                gridBorderData: BorderSide(
                  color: AppColors.divider,
                  width: 1,
                ),
                radarBorderData: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
                titleTextStyle: AppTypography.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                getTitle: (index, angle) {
                  final titles = ['Partisipasi', 'Pemahaman', 'Pembelajaran', 'Keterlibatan'];
                  return RadarChartTitle(
                    text: titles[index],
                    angle: 0,
                  );
                },
                dataSets: [
                  RadarDataSet(
                    fillColor: AppColors.primary.withValues(alpha: 0.3),
                    borderColor: AppColors.primary,
                    borderWidth: 2,
                    dataEntries: [
                      RadarEntry(value: scores.participation),
                      RadarEntry(value: scores.understanding),
                      RadarEntry(value: scores.learning),
                      RadarEntry(value: scores.socialEngagement),
                    ],
                  ),
                ],
                borderData: FlBorderData(show: false),
                radarBackgroundColor: Colors.transparent,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildScoreItem('Partisipasi', scores.participation),
        _buildScoreItem('Pemahaman', scores.understanding),
        _buildScoreItem('Pembelajaran', scores.learning),
        _buildScoreItem('Keterlibatan', scores.socialEngagement),
      ],
    );
  }

  Widget _buildScoreItem(String label, double score) {
    return Column(
      children: [
        Text(
          score.toStringAsFixed(1),
          style: AppTypography.titleMedium.copyWith(
            color: _getScoreColor(score),
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
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

class _MaterialProgressCard extends StatelessWidget {
  final StudentProgress progress;

  const _MaterialProgressCard({required this.progress});

  @override
  Widget build(BuildContext context) {
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
            children: [
              Expanded(
                child: _buildStep('Pre-test', progress.preTestStatus, progress.preTestScore),
              ),
              const Icon(Icons.arrow_forward, size: 16, color: AppColors.textSecondary),
              Expanded(
                child: _buildStep('E-Book', progress.ebookStatus, null),
              ),
              const Icon(Icons.arrow_forward, size: 16, color: AppColors.textSecondary),
              Expanded(
                child: _buildStep('Post-test', progress.postTestStatus, progress.postTestScore),
              ),
              const Icon(Icons.arrow_forward, size: 16, color: AppColors.textSecondary),
              Expanded(
                child: _buildStep('PULSE', progress.pulseStatus, null),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String label, String status, int? score) {
    final isCompleted = status == 'completed';
    return Column(
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
        if (score != null)
          Text(
            '$score%',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}