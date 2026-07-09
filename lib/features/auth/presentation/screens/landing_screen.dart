import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // App Logo & Header
              Center(
                child: Column(
                  children: [
                    SafeImageAsset(
                      'assets/Logo_civicpulse.png',
                      height: 70,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Selamat Datang',
                      style: AppTypography.headlineLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pilih jenjang pendidikan Anda untuk memulai belajar Kewarganegaraan secara seru!',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Grid of Education Levels
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.85,
                  children: [
                    _buildEducationCard(
                      context: context,
                      title: 'Sekolah Dasar',
                      alias: 'SD',
                      color: const Color(0xFFD32F2F), // Merah SD
                      icon: Icons.child_care,
                      isLocked: true,
                    ),
                    _buildEducationCard(
                      context: context,
                      title: 'Sekolah Menengah\nPertama',
                      alias: 'SMP',
                      color: const Color(0xFF1976D2), // Biru SMP
                      icon: Icons.menu_book,
                      isLocked: true,
                    ),
                    _buildEducationCard(
                      context: context,
                      title: 'Sekolah Menengah\nAtas',
                      alias: 'SMA',
                      color: const Color(0xFF00796B), // Toska Premium SMA
                      icon: Icons.school,
                      isLocked: false,
                      onTap: () => context.go('/login'),
                    ),
                    _buildEducationCard(
                      context: context,
                      title: 'Perguruan Tinggi',
                      alias: 'PT',
                      color: const Color(0xFFF57C00), // Kuning Emas PT
                      icon: Icons.account_balance,
                      isLocked: true,
                    ),
                  ],
                ),
              ),
              // Footer
              Center(
                child: Text(
                  'Civic Pulse v1.0.0',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEducationCard({
    required BuildContext context,
    required String title,
    required String alias,
    required Color color,
    required IconData icon,
    required bool isLocked,
    VoidCallback? onTap,
  }) {
    final cardContent = Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isLocked ? AppColors.surface.withValues(alpha: 0.7) : AppColors.surface,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(
          color: isLocked
              ? AppColors.divider.withValues(alpha: 0.5)
              : color.withValues(alpha: 0.3),
          width: isLocked ? 1 : 2,
        ),
        boxShadow: isLocked
            ? []
            : [
                BoxShadow(
                  color: color.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Stack(
        children: [
          // Locked lock icon indicator in top right
          if (isLocked)
            const Positioned(
              top: 0,
              right: 0,
              child: Icon(
                Icons.lock,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ),
          // Active dot in top right
          if (!isLocked)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          // Main Body
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon container
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isLocked ? Colors.grey.withValues(alpha: 0.1) : color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: isLocked ? AppColors.textSecondary : color,
                ),
              ),
              const SizedBox(height: 14),
              // Alias Badge
              Text(
                alias,
                style: AppTypography.titleLarge.copyWith(
                  color: isLocked ? AppColors.textSecondary : color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              // Full Title
              Text(
                title,
                style: AppTypography.labelMedium.copyWith(
                  color: isLocked ? AppColors.textSecondary : AppColors.textPrimary,
                  fontWeight: isLocked ? FontWeight.normal : FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return InkWell(
      onTap: isLocked
          ? () {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Jenjang $alias akan segera hadir pada update berikutnya!',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: AppColors.info,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }
          : onTap,
      borderRadius: AppRadius.radiusLg,
      child: isLocked
          ? Opacity(
              opacity: 0.6,
              child: cardContent,
            )
          : cardContent,
    );
  }
}
