import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';
import '../../../auth/data/models/auth_models.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class StudentProfileScreen extends ConsumerWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          children: [
            // Profile header
            _buildProfileHeader(context, user),
            AppSpacing.vGapLg,

            // Profile details card
            _buildProfileDetailsCard(user),
            AppSpacing.vGapLg,

            // PULSE Summary
            _buildPulseSummaryCard(),
            AppSpacing.vGapLg,

            // Settings sections
            _buildSettingsSection(context, ref),
            AppSpacing.vGapLg,

            // Logout button
            _buildLogoutButton(context, ref),
            AppSpacing.vGapXl,
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, User? user) {
    return AppCard(
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: user?.avatarUrl != null
                ? ClipOval(
                    child: Image.network(
                      user!.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _buildInitialsAvatar(user.name),
                    ),
                  )
                : _buildInitialsAvatar(user?.name ?? 'S'),
          ),
          AppSpacing.vGapMd,
          Text(
            user?.name ?? 'Student',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          AppSpacing.vGapXs,
          Text(
            user?.email ?? 'student@email.com',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          AppSpacing.vGapXs,
          StatusBadge(
            label: 'Siswa',
            status: AppStatus.info,
          ),
          AppSpacing.vGapMd,
          AppButton(
            label: 'Edit Profil',
            variant: AppButtonVariant.outline,
            size: AppButtonSize.small,
            onPressed: () => context.push('/student/profile/edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialsAvatar(String name) {
    final initials = name.isNotEmpty
        ? name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'S';
    return Center(
      child: Text(
        initials,
        style: AppTypography.headlineMedium.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPulseSummaryCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, color: AppColors.primary),
              AppSpacing.hGapSm,
              Text(
                'Ringkasan PULSE',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          AppSpacing.vGapMd,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPulseMetric('Partisipasi', 3.5),
              _buildPulseMetric('Pemahaman', 4.0),
              _buildPulseMetric('Pembelajaran', 3.8),
              _buildPulseMetric('Keterlibatan', 3.2),
            ],
          ),
          AppSpacing.vGapMd,
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Icon(Icons.emoji_events, color: AppColors.success),
                AppSpacing.hGapSm,
                Expanded(
                  child: Text(
                    'Skor keseluruhan: 3.6 - Dalam batas baik!',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseMetric(String label, double score) {
    Color scoreColor;
    if (score >= 3.5) {
      scoreColor = AppColors.success;
    } else if (score >= 2.5) {
      scoreColor = AppColors.warning;
    } else {
      scoreColor = AppColors.danger;
    }

    return Column(
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: score / 5,
                strokeWidth: 5,
                backgroundColor: AppColors.divider,
                valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
              ),
              Text(
                score.toStringAsFixed(1),
                style: AppTypography.labelSmall.copyWith(
                  color: scoreColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pengaturan',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        AppSpacing.vGapSm,
        _buildSettingsItem(
          icon: Icons.notifications_outlined,
          title: 'Notifikasi',
          subtitle: 'Pengaturan notifikasi aplikasi',
          onTap: () => _showComingSoonSnackBar(context),
        ),
        _buildSettingsItem(
          icon: Icons.lock_outline,
          title: 'Privasi & Keamanan',
          subtitle: 'Ubah kata sandi, keamanan akun',
          onTap: () => _showComingSoonSnackBar(context),
        ),
        _buildSettingsItem(
          icon: Icons.help_outline,
          title: 'Bantuan',
          subtitle: 'FAQ, hubungi kami',
          onTap: () => _showComingSoonSnackBar(context),
        ),
        _buildSettingsItem(
          icon: Icons.info_outline,
          title: 'Tentang Aplikasi',
          subtitle: 'Versi 1.0.0',
          onTap: () => _showAboutDialog(context),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return AppButton(
      label: 'Keluar',
      variant: AppButtonVariant.danger,
      icon: Icons.logout,
      onPressed: () => _showLogoutConfirmation(context, ref),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: BorderSide(color: AppColors.divider),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ref.read(authNotifierProvider.notifier).logout();
                    context.go('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Keluar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showComingSoonSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur akan segera hadir!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.school, color: AppColors.primary),
            AppSpacing.hGapSm,
            const Text('CivicPulse'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aplikasi monitoring PULSE untuk pendidikan kewarganegaraan multikultural.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.vGapMd,
            Text(
              'Versi: 1.0.0',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            AppSpacing.vGapXs,
            Text(
              '© 2024 CivicPulse',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetailsCard(User? user) {
    if (user == null) return const SizedBox.shrink();

    final hasDob = user.dateOfBirth != null && user.dateOfBirth!.isNotEmpty;
    final hasGender = user.gender != null && user.gender!.isNotEmpty;
    final hasPhone = user.phone != null && user.phone!.isNotEmpty;
    final hasAddress = user.address != null && user.address!.isNotEmpty;
    final hasParentName = user.parentName != null && user.parentName!.isNotEmpty;
    final hasParentPhone = user.parentPhone != null && user.parentPhone!.isNotEmpty;

    final noDetails = !hasDob && !hasGender && !hasPhone && !hasAddress && !hasParentName && !hasParentPhone;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline, color: AppColors.primary),
              AppSpacing.hGapSm,
              Text(
                'Detail Profil & Orang Tua',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppSpacing.vGapMd,
          if (noDetails)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Text(
                  'Detail profil belum dilengkapi.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else ...[
            if (hasDob) _buildDetailRow(Icons.cake_outlined, 'Tanggal Lahir', _formatDateString(user.dateOfBirth!)),
            if (hasGender) _buildDetailRow(user.gender == 'male' ? Icons.male : Icons.female, 'Jenis Kelamin', user.gender == 'male' ? 'Laki-laki' : 'Perempuan'),
            if (hasPhone) _buildDetailRow(Icons.phone_android, 'No. Telepon', user.phone!),
            if (hasAddress) _buildDetailRow(Icons.home_outlined, 'Alamat', user.address!),
            if (hasDob || hasGender || hasPhone || hasAddress)
              if (hasParentName || hasParentPhone) const Divider(height: 24, thickness: 0.5),
            if (hasParentName) _buildDetailRow(Icons.people_alt_outlined, 'Nama Orang Tua / Wali', user.parentName!),
            if (hasParentPhone) _buildDetailRow(Icons.phone_in_talk, 'No. Telp Orang Tua / Wali', user.parentPhone!),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          AppSpacing.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateString(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return dateString;
    }
  }
}