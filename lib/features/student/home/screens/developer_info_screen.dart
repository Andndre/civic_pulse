import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';

class DeveloperInfoScreen extends StatelessWidget {
  const DeveloperInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientShellScaffold(
      title: 'Informasi Pengembang',
      showBackButton: true,
      body: Column(
        children: [
          _buildAppLogoSection(),
          AppSpacing.vGapLg,
          _buildDeveloperCard(),
          AppSpacing.vGapLg,
          _buildResearchCard(),
          AppSpacing.vGapLg,
          _buildVersionInfo(),
          AppSpacing.vGapXl,
        ],
      ),
    );
  }

  Widget _buildAppLogoSection() {
    return AppCard(
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.school_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            AppSpacing.vGapMd,
            Text(
              'CivicPulse',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.vGapXs,
            Text(
              'Pendidikan Kewarganegaraan & Multikultural',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people_outline, color: AppColors.primary),
              AppSpacing.hGapSm,
              Text(
                'Tim Pengembang',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppSpacing.vGapMd,
          const Divider(height: 1, thickness: 0.5),
          AppSpacing.vGapMd,
          _buildMemberRow('Gunawan', 'Lead Developer & Architect', 'Merancang dan mengembangkan arsitektur frontend Flutter dan backend Laravel.'),
          AppSpacing.vGapMd,
          _buildMemberRow('Wayan Lasmawan', 'Subject Matter Expert', 'Menyusun materi, instrumen penilaian PULSE, dan validasi akademik pembelajaran.'),
        ],
      ),
    );
  }

  Widget _buildMemberRow(String name, String role, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.person, color: AppColors.primary),
          ),
        ),
        AppSpacing.hGapMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                role,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacing.vGapXs,
              Text(
                desc,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResearchCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.science_outlined, color: AppColors.primary),
              AppSpacing.hGapSm,
              Text(
                'Konteks Penelitian',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppSpacing.vGapMd,
          Text(
            'Aplikasi CivicPulse dikembangkan sebagai bagian dari penelitian instrumen monitoring non-kognitif siswa dalam pembelajaran Pendidikan Pancasila dan Kewarganegaraan (PPKn) berbasis multikultural.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          AppSpacing.vGapMd,
          Text(
            'Melalui integrasi Papan Aktivitas dan penilaian objektif PULSE, aplikasi ini diharapkan memberikan kontribusi nyata bagi dunia pendidikan Indonesia.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Column(
      children: [
        Text(
          'CivicPulse v1.0.0',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.vGapXs,
        Text(
          '© 2026 Tim Pengembang CivicPulse. Hak Cipta Dilindungi.',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
