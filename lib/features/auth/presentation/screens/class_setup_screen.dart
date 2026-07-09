import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/constants.dart';
import '../providers/auth_provider.dart';
import '../../../../features/student/providers/student_providers.dart';
import '../../../../features/student/learning/providers/material_provider.dart';

class ClassSetupScreen extends ConsumerStatefulWidget {
  const ClassSetupScreen({super.key});

  @override
  ConsumerState<ClassSetupScreen> createState() => _ClassSetupScreenState();
}

class _ClassSetupScreenState extends ConsumerState<ClassSetupScreen> {
  final _classNameController = TextEditingController();
  final _classCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _gradeCategory = 'SMP';
  int _gradeLevel = 7;
  bool _isLoading = false;
  String? _generatedClassCode;
  String? _selectedStudentGradeCategory;

  @override
  void dispose() {
    _classNameController.dispose();
    _classCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateClass() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Format input tidak valid. Silakan periksa kembali.',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final classCode = await ref.read(authNotifierProvider.notifier).createClass(
            name: _classNameController.text.trim(),
            gradeCategory: _gradeCategory,
            gradeLevel: _gradeLevel,
          );

      if (classCode != null) {
        setState(() => _generatedClassCode = classCode);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleJoinClass() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Format input tidak valid. Silakan periksa kembali.',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref
          .read(authNotifierProvider.notifier)
          .joinClass(_classCodeController.text.trim().toUpperCase());

      if (mounted) {
        final currentAuthState = ref.read(authNotifierProvider);
        if (currentAuthState.errorMessage == null && !currentAuthState.needsClassSetup) {
          // Invalidate student-related providers to fetch fresh data
          ref.invalidate(studentClassesProvider);
          ref.invalidate(materialsProvider);
          ref.invalidate(activitiesProvider);
          _navigateToHome();
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _shareClassCode() async {
    if (_generatedClassCode == null) return;

    await SharePlus.instance.share(
      ShareParams(
        text: 'Bergabunglah dengan kelas CivicPulse saya!\n\nKode Kelas: $_generatedClassCode\n\nDownload app: https://civicpulse.app',
        subject: 'Undangan Kelas CivicPulse',
      ),
    );
  }

  Future<void> _copyClassCode() async {
    if (_generatedClassCode == null) return;
    await Clipboard.setData(ClipboardData(text: _generatedClassCode!));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Kode kelas berhasil disalin',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  void _navigateToHome() {
    final user = ref.read(authNotifierProvider).user;
    if (user?.isTeacher == true) {
      context.go('/teacher/home');
    } else {
      context.go('/student/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final isTeacher = user?.isTeacher ?? false;

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    next.errorMessage!,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        ref.read(authNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await ref.read(authNotifierProvider.notifier).logout();
            if (context.mounted) {
              context.go('/login');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isTeacher),
                AppSpacing.vGapXl,
                if (isTeacher)
                  _buildTeacherSetup()
                else
                  _buildStudentSetup(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isTeacher) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.2),
            borderRadius: AppRadius.radiusMd,
          ),
          child: const Icon(
            Icons.class_outlined,
            size: 32,
            color: AppColors.primary,
          ),
        ),
        AppSpacing.vGapLg,
        Text(
          isTeacher ? 'Buat Kelas Baru' : 'Bergabung Kelas',
          style: AppTypography.headlineLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        AppSpacing.vGapSm,
        Text(
          isTeacher
              ? 'Buat kelas untuk memulai pemantauan PULSE siswa'
              : 'Masukkan kode kelas dari guru untuk bergabung',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTeacherSetup() {
    if (_generatedClassCode != null) {
      return _buildClassCodeGenerated();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'Nama Kelas',
          hint: 'Contoh: Kelas VII-A',
          controller: _classNameController,
          prefixIcon: const Icon(Icons.class_outlined),
          enabled: !_isLoading,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nama kelas wajib diisi';
            }
            return null;
          },
        ),
        AppSpacing.vGapMd,
        _buildGradeSelector(),
        AppSpacing.vGapXl,
        AppButton(
          label: 'Buat Kelas',
          loading: _isLoading,
          onPressed: _handleCreateClass,
        ),
      ],
    );
  }

  Widget _buildGradeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jenjang Pendidikan',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        AppSpacing.vGapSm,
        Row(
          children: [
            Expanded(
              child: _GradeChip(
                label: 'SMP',
                isSelected: _gradeCategory == 'SMP',
                onTap: () => setState(() {
                  _gradeCategory = 'SMP';
                  _gradeLevel = 7;
                }),
              ),
            ),
            AppSpacing.hGapSm,
            Expanded(
              child: _GradeChip(
                label: 'SMA',
                isSelected: _gradeCategory == 'SMA',
                onTap: () => setState(() {
                  _gradeCategory = 'SMA';
                  _gradeLevel = 10;
                }),
              ),
            ),
          ],
        ),
        AppSpacing.vGapMd,
        Text(
          'Tingkat',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        AppSpacing.vGapSm,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _buildGradeLevels(),
        ),
      ],
    );
  }

  List<Widget> _buildGradeLevels() {
    final start = _gradeCategory == 'SMP' ? 7 : 10;
    final end = _gradeCategory == 'SMP' ? 9 : 12;

    return List.generate(
      end - start + 1,
      (index) {
        final level = start + index;
        return _GradeChip(
          label: 'Kelas $level',
          isSelected: _gradeLevel == level,
          onTap: () => setState(() => _gradeLevel = level),
        );
      },
    );
  }

  Widget _buildClassCodeGenerated() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          child: Column(
            children: [
              const Icon(
                Icons.check_circle,
                size: 48,
                color: AppColors.success,
              ),
              AppSpacing.vGapMd,
              Text(
                'Kelas Berhasil Dibuat!',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              AppSpacing.vGapLg,
              Text(
                'Bagikan kode ini ke siswa:',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              AppSpacing.vGapMd,
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.2),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Text(
                  _generatedClassCode!,
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
              ),
              AppSpacing.vGapMd,
              Text(
                'Kode ini unik dan hanya untuk kelas ini',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        AppSpacing.vGapLg,
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _copyClassCode,
                icon: const Icon(Icons.copy),
                label: const Text('Salin'),
              ),
            ),
            AppSpacing.hGapMd,
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _shareClassCode,
                icon: const Icon(Icons.share),
                label: const Text('Bagikan'),
              ),
            ),
          ],
        ),
        AppSpacing.vGapLg,
        AppButton(
          label: 'Mulai ke Beranda',
          onPressed: _navigateToHome,
        ),
      ],
    );
  }

  Widget _buildStudentSetup() {
    if (_selectedStudentGradeCategory == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih Jenjang Pendidikan Anda:',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.vGapLg,
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 0.9,
            children: [
              _buildStudentGradeCard(
                title: 'Sekolah Dasar',
                alias: 'SD',
                color: const Color(0xFFD32F2F),
                icon: Icons.child_care,
                isLocked: true,
              ),
              _buildStudentGradeCard(
                title: 'Sekolah Menengah\nPertama',
                alias: 'SMP',
                color: const Color(0xFF1976D2),
                icon: Icons.menu_book,
                isLocked: false,
                onTap: () => setState(() {
                  _selectedStudentGradeCategory = 'SMP';
                }),
              ),
              _buildStudentGradeCard(
                title: 'Sekolah Menengah\nAtas',
                alias: 'SMA',
                color: const Color(0xFF00796B),
                icon: Icons.school,
                isLocked: false,
                onTap: () => setState(() {
                  _selectedStudentGradeCategory = 'SMA';
                }),
              ),
              _buildStudentGradeCard(
                title: 'Perguruan Tinggi',
                alias: 'PT',
                color: const Color(0xFFF57C00),
                icon: Icons.account_balance,
                isLocked: true,
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Enrolled Grade category banner with change button
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: AppRadius.radiusMd,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _selectedStudentGradeCategory == 'SMP' ? Icons.menu_book : Icons.school,
                color: AppColors.primary,
              ),
              AppSpacing.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jenjang Pendidikan',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _selectedStudentGradeCategory == 'SMP'
                          ? 'SMP (Sekolah Menengah Pertama)'
                          : 'SMA (Sekolah Menengah Atas)',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _selectedStudentGradeCategory = null;
                }),
                child: Text(
                  'Ubah',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        AppSpacing.vGapLg,
        AppTextField(
          label: 'Kode Kelas',
          hint: 'Masukkan 6-digit kode kelas',
          controller: _classCodeController,
          prefixIcon: const Icon(Icons.key_outlined),
          textCapitalization: TextCapitalization.characters,
          enabled: !_isLoading,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Kode kelas wajib diisi';
            }
            if (value.length < 6) {
              return 'Kode kelas harus 6 karakter';
            }
            return null;
          },
        ),
        AppSpacing.vGapXl,
        AppButton(
          label: 'Bergabung Kelas',
          loading: _isLoading,
          onPressed: _handleJoinClass,
        ),
      ],
    );
  }

  Widget _buildStudentGradeCard({
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
          if (!isLocked)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: isLocked ? Colors.grey.withValues(alpha: 0.1) : color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isLocked ? AppColors.textSecondary : color,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                alias,
                style: AppTypography.titleMedium.copyWith(
                  color: isLocked ? AppColors.textSecondary : color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: AppTypography.labelSmall.copyWith(
                  color: isLocked ? AppColors.textSecondary : AppColors.textPrimary,
                  fontWeight: isLocked ? FontWeight.normal : FontWeight.w600,
                  fontSize: 10,
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

class _GradeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GradeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.chip,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: AppRadius.chip,
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
