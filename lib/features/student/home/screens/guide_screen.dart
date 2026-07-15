import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientShellScaffold(
      title: 'Panduan Aplikasi',
      subtitle: 'Cara pakai CivicPulse',
      showBackButton: true,
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIntroductionCard(),
            AppSpacing.vGapLg,
            Text(
              'Alur Belajar & Aktivitas',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.vGapMd,
            _buildStepGuide(
              stepNumber: '1',
              title: 'Pre-Test',
              description: 'Mengerjakan kuis awal singkat sebelum masuk ke materi pembelajaran untuk mengukur pemahaman awal Anda.',
              icon: Icons.assignment_outlined,
              iconColor: AppColors.primary,
            ),
            AppSpacing.vGapMd,
            _buildStepGuide(
              stepNumber: '2',
              title: 'Membaca E-Book',
              description: 'Pelajari materi utama secara menyeluruh melalui berkas PDF dan penjelasan audio yang disediakan oleh guru.',
              icon: Icons.menu_book_outlined,
              iconColor: AppColors.success,
            ),
            AppSpacing.vGapMd,
            _buildStepGuide(
              stepNumber: '3',
              title: 'Papan Aktivitas (Games)',
              description: 'Ikuti tantangan interaktif menyenangkan seperti Mencocokkan Pasangan, Sortir Kategori, dan Swipe Benar/Salah untuk memperkuat pemahaman.',
              icon: Icons.sports_esports_outlined,
              iconColor: AppColors.warning,
            ),
            AppSpacing.vGapMd,
            _buildStepGuide(
              stepNumber: '4',
              title: 'Tantangan Sosial',
              description: 'Lakukan aksi nyata bertema kewargaan di lingkungan sekitar Anda, ambil foto/video bukti, tulis cerita singkat, lalu unggah untuk dinilai guru.',
              icon: Icons.people_alt_outlined,
              iconColor: AppColors.chartPurple,
            ),
            AppSpacing.vGapMd,
            _buildStepGuide(
              stepNumber: '5',
              title: 'Post-Test',
              description: 'Selesaikan kuis akhir setelah mempelajari materi untuk melihat tingkat peningkatan pemahaman Anda.',
              icon: Icons.assignment_turned_in_outlined,
              iconColor: AppColors.danger,
            ),
            AppSpacing.vGapLg,
            _buildPulseExplanationCard(),
            AppSpacing.vGapXl,
          ],
        ),
    );
  }

  Widget _buildIntroductionCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.stars, color: AppColors.primary, size: 28),
              AppSpacing.hGapSm,
              Text(
                'Selamat Datang di CivicPulse!',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppSpacing.vGapMd,
          Text(
            'CivicPulse dirancang untuk membantu Anda memantau dan meningkatkan kompetensi kewargaan multikultural melalui 4 dimensi utama: Partisipasi, Pemahaman, Pembelajaran, dan Keterlibatan Sosial (PULSE).',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepGuide({
    required String stepNumber,
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
  }) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: AppTypography.titleMedium.copyWith(
                  color: iconColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18, color: iconColor),
                    AppSpacing.hGapXs,
                    Text(
                      title,
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                AppSpacing.vGapXs,
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseExplanationCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: AppColors.primary, size: 24),
              AppSpacing.hGapSm,
              Text(
                'Mengenal Metrik PULSE',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppSpacing.vGapMd,
          _buildPulseMetricDesc('P', 'Participation', 'Mengukur keaktifan Anda menyelesaikan modul dan papan aktivitas game.'),
          AppSpacing.vGapSm,
          _buildPulseMetricDesc('U', 'Understanding', 'Mengukur tingkat kebenaran jawaban Anda dalam mini-game papan aktivitas.'),
          AppSpacing.vGapSm,
          _buildPulseMetricDesc('L', 'Learning', 'Mengukur selisih peningkatan nilai Anda dari Pre-Test ke Post-Test.'),
          AppSpacing.vGapSm,
          _buildPulseMetricDesc('S / E', 'Social Engagement', 'Mengukur kualitas aksi nyata tantangan sosial berdasarkan penilaian langsung dari Guru.'),
        ],
      ),
    );
  }

  Widget _buildPulseMetricDesc(String symbol, String name, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              symbol,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        AppSpacing.hGapSm,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                desc,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
