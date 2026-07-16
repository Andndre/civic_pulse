import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/services/services.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../providers/student_providers.dart';
import '../../learning/providers/material_provider.dart';

class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final classesAsync = ref.watch(studentClassesProvider);

    // Progress ring data (DESIGN.md §7.4) — turunan dari materi yang sudah ada
    final materials =
        ref.watch(materialsProvider).asData?.value ?? const <LearningMaterial>[];
    double? boardProgress;
    if (materials.isNotEmpty) {
      boardProgress = materials
              .where((m) => m.boardStatus == 'completed')
              .length /
          materials.length;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        await SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1976D2), // Deeper blue to blend with gradient
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2196F3), // Bright blue
                Color(0xFF1976D2), // Deep blue
              ],
              stops: [0.0, 0.45],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(studentClassesProvider);
                ref.invalidate(materialsProvider);
                ref.invalidate(pulseScoresProvider);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 28.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo & Avatar Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset(
                                'assets/Logo_civicpulse.png',
                                height: 32,
                                color: Colors.white,
                                colorBlendMode: BlendMode.srcIn,
                                errorBuilder: (context, error, stackTrace) {
                                  return Text(
                                    'CIVIC PULSE',
                                    style: AppTypography.titleLarge.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  );
                                },
                              ),
                              AvatarWidget(
                                imageUrl: user?.avatarUrl,
                                name: user?.name ?? 'Siswa',
                                size: 44,
                                onTap: () => context.go('/student/profile'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          // Dynamic Greeting
                          Text(
                            _getTimeGreeting(),
                            style: AppTypography.bodyLarge.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.name ?? 'Siswa',
                            style: AppTypography.headlineMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 26,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Class & Level badges inside Header
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                classesAsync.when(
                                  data: (classes) {
                                    if (classes.isEmpty) {
                                      return const SizedBox.shrink();
                                    }
                                    return _buildHeaderBadge(
                                      icon: Icons.school_rounded,
                                      label: 'Kelas ${classes.first.name}',
                                    );
                                  },
                                  loading: () => const SizedBox.shrink(),
                                  error: (e, _) => const SizedBox.shrink(),
                                ),
                                if (ref
                                        .watch(pulseScoresProvider)
                                        .asData
                                        ?.value
                                    case final pulse?)
                                  _buildHeaderBadge(
                                    icon: Icons.star_rounded,
                                    iconColor: AppColors.celebrate,
                                    label: _levelLabel(pulse.overall),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // White Curved Container
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height - 210,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(24.0, 36.0, 24.0, 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // If no class, show empty class warning card
                          classesAsync.when(
                            data: (classes) {
                              if (classes.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 24.0),
                                  child: _buildEmptyClassCard(context, ref),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                            loading: () => const SizedBox.shrink(),
                            error: (e, _) => const SizedBox.shrink(),
                          ),
                          // 6 Main Menu Grid
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 3,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.7,
                            children: [
                              // E-Learning: pusat materi & tantangan — ditandai
                              // ring progres biru (progres papan/konten).
                              _MenuCard(
                                title: 'E-Learning',
                                iconAsset: 'assets/icons/menu_elearning.svg',
                                progress: boardProgress,
                                progressColor: AppColors.pulseParticipation,
                                onTap: () => context.go('/student/learning'),
                              ),
                              // Asesmen & Refleksi: rekap nilai & umpan balik —
                              // tampil beda dari E-Learning lewat tile ikon
                              // oranye (bukan ring) dan tujuan ke layar skor.
                              _MenuCard(
                                title: 'Asesmen & Refleksi',
                                iconAsset: 'assets/icons/menu_score_summary.svg',
                                iconBg: AppColors.pulseLearning,
                                onTap: () => context.go('/student/scores'),
                              ),
                              _MenuCard(
                                title: 'Aktivitas Kewargaan',
                                iconAsset: 'assets/icons/menu_civic_activity.svg',
                                onTap: () => context.go('/student/activities'),
                              ),
                              _MenuCard(
                                title: 'Tanya AI',
                                iconAsset: 'assets/icons/menu_ai.svg',
                                isLocked: true,
                                onTap: () => _showLockedAIInfo(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) {
      return 'Selamat pagi,';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat siang,';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat sore,';
    } else {
      return 'Selamat malam,';
    }
  }

  /// Label level dari overall PULSE score (DESIGN.md §7.2) —
  /// reframe status merah dari "gagal" menjadi "level saat ini".
  String _levelLabel(double overall) {
    if (overall >= 3.5) return 'Warga Teladan';
    if (overall >= 2.5) return 'Warga Aktif';
    return 'Warga Muda';
  }

  Widget _buildHeaderBadge({
    required IconData icon,
    required String label,
    Color iconColor = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyClassCard(BuildContext context, WidgetRef ref) {
    return AppCard(
      onTap: () => _showJoinClassBottomSheet(context, ref),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.warningLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school_outlined,
              color: AppColors.warning,
            ),
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Belum Bergabung Kelas',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Tap untuk bergabung dengan kelas',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  void _showLockedAIInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.lock_clock, color: Colors.amber),
            SizedBox(width: 8),
            Text('Tanya AI Terkunci'),
          ],
        ),
        content: const Text(
          'Fitur Tanya AI saat ini belum tersedia atau sedang dinonaktifkan oleh Guru Anda.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  void _showJoinClassBottomSheet(BuildContext context, WidgetRef ref) {
    final codeController = TextEditingController();
    String? errorMessage;
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bergabung dengan Kelas',
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              AppSpacing.vGapMd,
              Text(
                'Masukkan kode kelas yang diberikan oleh guru untuk bergabung dengan kelas.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              AppSpacing.vGapMd,
              AppTextField(
                controller: codeController,
                hint: 'Contoh: VIIA2024',
                label: 'Kode Kelas',
                errorText: errorMessage,
                textCapitalization: TextCapitalization.characters,
                onChanged: (_) {
                  if (errorMessage != null) {
                    setState(() => errorMessage = null);
                  }
                },
              ),
              AppSpacing.vGapMd,
              AppButton(
                label: 'Bergabung',
                loading: isLoading,
                onPressed: () async {
                  final code = codeController.text.trim();
                  if (code.isEmpty) {
                    setState(() => errorMessage = 'Kode Kelas tidak boleh kosong');
                    return;
                  }
                  if (code.length < 6) {
                    setState(() => errorMessage = 'Kode Kelas minimal 6 karakter');
                    return;
                  }

                  setState(() => isLoading = true);

                  try {
                    final classService = ref.read(classServiceProvider);
                    await classService.joinClass(code);
                    ref.invalidate(studentClassesProvider);
                    ref.invalidate(materialsProvider);
                    ref.invalidate(activitiesProvider);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Berhasil bergabung dengan kelas!'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      setState(() {
                        errorMessage = e.toString().replaceAll('Exception: ', '');
                        isLoading = false;
                      });
                    }
                  }
                },
              ),
              AppSpacing.vGapSm,
            ],
          ),
        ),
      ),
    );
  }
}

/// Kartu menu utama dengan ikon sticker, press feedback (scale + haptic),
/// dan progress ring opsional di sekeliling ikon (DESIGN.md §7.4).
class _MenuCard extends StatefulWidget {
  final String title;
  final String iconAsset;
  final VoidCallback onTap;
  final bool isLocked;
  final double? progress;
  final Color progressColor;
  final Color? iconBg;

  const _MenuCard({
    required this.title,
    required this.iconAsset,
    required this.onTap,
    this.isLocked = false,
    this.progress,
    this.progressColor = AppColors.primary,
    this.iconBg,
  });

  @override
  State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final progress = widget.progress?.clamp(0.0, 1.0);
    final hasRing = progress != null;

    return Semantics(
      button: true,
      label: widget.isLocked
          ? '${widget.title}, terkunci'
          : hasRing
              ? '${widget.title}, progres ${(progress * 100).round()} persen'
              : widget.title,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: const Color(0xFFF0F2F5), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: SizedBox(
                          width: 70,
                          height: 70,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (hasRing)
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: _ProgressRingPainter(
                                      progress: progress,
                                      color: widget.progressColor,
                                    ),
                                  ),
                                ),
                              if (widget.iconBg != null)
                                Container(
                                  width: 58,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    color: widget.iconBg!
                                        .withValues(alpha: 0.14),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              SvgPicture.asset(
                                widget.iconAsset,
                                width: hasRing
                                    ? 54
                                    : widget.iconBg != null
                                        ? 40
                                        : 60,
                                height: hasRing
                                    ? 54
                                    : widget.iconBg != null
                                        ? 40
                                        : 60,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (widget.isLocked)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD54F),
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: const Icon(
                              Icons.lock,
                              size: 9,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 32,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ring progres tipis di sekeliling ikon sticker — track pudar + arc berwarna,
/// mulai dari atas (jam 12), ujung membulat.
class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _ProgressRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 3.5;
    final rect = (Offset.zero & size).deflate(stroke / 2);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = color.withValues(alpha: 0.15);
    canvas.drawArc(rect, 0, 2 * math.pi, false, track);

    if (progress > 0) {
      final arc = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color;
      canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, arc);
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
