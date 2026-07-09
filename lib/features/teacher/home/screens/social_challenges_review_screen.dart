import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/services/services.dart';
import '../providers/teacher_provider.dart';

class SocialChallengesReviewScreen extends ConsumerStatefulWidget {
  const SocialChallengesReviewScreen({super.key});

  @override
  ConsumerState<SocialChallengesReviewScreen> createState() =>
      _SocialChallengesReviewScreenState();
}

class _SocialChallengesReviewScreenState
    extends ConsumerState<SocialChallengesReviewScreen> {
  @override
  Widget build(BuildContext context) {
    final pendingAsync = ref.watch(pendingSocialChallengesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Tinjau Tantangan Sosial',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/teacher/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(pendingSocialChallengesProvider),
          ),
        ],
      ),
      body: pendingAsync.when(
        data: (challenges) {
          if (challenges.isEmpty) {
            return _buildEmptyState();
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(pendingSocialChallengesProvider),
            child: ListView.builder(
              padding: AppSpacing.screenPadding,
              itemCount: challenges.length,
              itemBuilder: (context, index) {
                final challenge = challenges[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _PendingChallengeCard(challenge: challenge),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.danger),
              AppSpacing.vGapMd,
              Text(
                'Gagal memuat antrean tinjauan',
                style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary),
              ),
              AppSpacing.vGapXs,
              Text(
                e.toString(),
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              AppSpacing.vGapLg,
              AppButton(
                label: 'Coba Lagi',
                onPressed: () => ref.invalidate(pendingSocialChallengesProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.successLight.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 64,
                color: AppColors.success,
              ),
            ),
            AppSpacing.vGapLg,
            Text(
              'Semua Tuntas!',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.vGapSm,
            Text(
              'Tidak ada tantangan sosial siswa yang menunggu tinjauan saat ini.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGapXl,
            AppButton(
              label: 'Kembali ke Beranda',
              onPressed: () => context.go('/teacher/home'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingChallengeCard extends ConsumerStatefulWidget {
  final ActivityLog challenge;

  const _PendingChallengeCard({required this.challenge});

  @override
  ConsumerState<_PendingChallengeCard> createState() =>
      _PendingChallengeCardState();
}

class _PendingChallengeCardState extends ConsumerState<_PendingChallengeCard> {
  int _selectedScore = 4; // default score
  final _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _getRubricLabel(int score) {
    switch (score) {
      case 1:
        return 'Tidak relevan / tanpa bukti';
      case 2:
        return 'Bukti tidak sesuai instruksi';
      case 3:
        return 'Bukti sesuai, cerita singkat/dangkal';
      case 4:
        return 'Bukti sesuai & cerita konteks baik';
      case 5:
        return 'Bukti sesuai, cerita reflektif & inisiatif lebih';
      default:
        return '';
    }
  }

  Future<void> _submitReview(String status) async {
    setState(() => _isSubmitting = true);
    try {
      await ref.read(reviewSocialChallengeProvider.notifier).review(
            activityId: widget.challenge.id,
            status: status,
            score: _selectedScore,
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'approved'
                  ? 'Tantangan disetujui dengan skor $_selectedScore'
                  : 'Tantangan ditolak',
            ),
            backgroundColor: status == 'approved' ? AppColors.success : AppColors.danger,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim tinjauan: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final challenge = widget.challenge;

    return AppCard(
      padding: AppSpacing.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Student info & date
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
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
                      challenge.studentName != null && challenge.studentName!.isNotEmpty
                          ? challenge.studentName!
                          : 'Siswa ID: ${challenge.studentId}',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Dikirim pada ${_formatDate(challenge.activityDate)} | Lokasi: ${challenge.location}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.vGapMd,
          const Divider(),
          AppSpacing.vGapSm,
          // Challenge content
          Text(
            challenge.title,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.vGapSm,
          // Student description
          Container(
            width: double.infinity,
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppRadius.radiusMd,
            ),
            child: Text(
              challenge.description.isNotEmpty ? challenge.description : '(Tidak ada deskripsi cerita)',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
          AppSpacing.vGapMd,
          // Image Evidence (if exists)
          if (challenge.photoUrl != null && challenge.photoUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: AppRadius.radiusMd,
              child: Image.network(
                challenge.photoUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: AppRadius.radiusMd,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 40,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            AppSpacing.vGapLg,
          ],
          // Rubric & Score Selection
          Text(
            'Skor Keterlibatan Sosial (PULSE)',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.vGapSm,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final val = index + 1;
              final isSelected = _selectedScore == val;
              return GestureDetector(
                onTap: _isSubmitting ? null : () => setState(() => _selectedScore = val),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.divider,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$val',
                      style: AppTypography.titleMedium.copyWith(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          AppSpacing.vGapSm,
          // Rubric dynamic text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              borderRadius: AppRadius.radiusSm,
            ),
            child: Text(
              'Kriteria: ${_getRubricLabel(_selectedScore)}',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          AppSpacing.vGapLg,
          // Teacher feedback note input
          Text(
            'Catatan Review (Opsional)',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.vGapSm,
          TextField(
            controller: _noteController,
            enabled: !_isSubmitting,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Beri apresiasi atau feedback untuk siswa...',
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
          AppSpacing.vGapLg,
          // Submission Action Buttons
          if (_isSubmitting)
            const Center(child: CircularProgressIndicator())
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _submitReview('rejected'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.danger, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusMd,
                      ),
                    ),
                    child: Text(
                      'Tolak Bukti',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.danger,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                AppSpacing.hGapMd,
                Expanded(
                  child: AppButton(
                    label: 'Setujui & Kirim',
                    variant: AppButtonVariant.primary,
                    onPressed: () => _submitReview('approved'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
