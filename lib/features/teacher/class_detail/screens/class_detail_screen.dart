import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/constants.dart';
import '../../home/providers/teacher_provider.dart';
import '../../../../shared/services/services.dart';

class ClassDetailScreen extends ConsumerStatefulWidget {
  final String classId;

  const ClassDetailScreen({super.key, required this.classId});

  @override
  ConsumerState<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends ConsumerState<ClassDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final classIdInt = int.tryParse(widget.classId) ?? 0;
    final classAsync = ref.watch(classDetailProvider(classIdInt));
    final summaryAsync = ref.watch(classSummaryProvider(classIdInt));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: classAsync.when(
          data: (cls) => Text(cls?.name ?? 'Kelas'),
          loading: () => const Text('Memuat...'),
          error: (_, _) => const Text('Kelas'),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/teacher/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareClassCode(context, classAsync),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value, classIdInt),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit Kelas')),
              const PopupMenuItem(value: 'delete', child: Text('Hapus Kelas')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Ringkasan'),
            Tab(text: 'Siswa'),
            Tab(text: 'Pengaturan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRingkasanTab(classIdInt, summaryAsync),
          _buildSiswaTab(classIdInt),
          _buildPengaturanTab(classIdInt, classAsync),
        ],
      ),
    );
  }

  Widget _buildRingkasanTab(int classId, AsyncValue<Map<String, dynamic>> summaryAsync) {
    return summaryAsync.when(
      data: (summary) => SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Siswa',
                    '${summary['totalStudents']}',
                    Icons.people,
                    AppColors.primary,
                  ),
                ),
                AppSpacing.hGapMd,
                Expanded(
                  child: _buildStatCard(
                    'Rata-rata PULSE',
                    (summary['averagePulse'] as double).toStringAsFixed(1),
                    Icons.trending_up,
                    _getPulseColor(summary['averagePulse'] as double),
                  ),
                ),
              ],
            ),
            AppSpacing.vGapMd,
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Materi Selesai',
                    '${summary['completedMaterials']}/${summary['totalMaterials']}',
                    Icons.check_circle,
                    AppColors.success,
                  ),
                ),
                AppSpacing.hGapMd,
                Expanded(
                  child: _buildStatCard(
                    'Kode Kelas',
                    summary['classCode'] ?? '-',
                    Icons.qr_code,
                    AppColors.secondary,
                  ),
                ),
              ],
            ),
            AppSpacing.vGapLg,
            Text(
              'Distribusi Status PULSE',
              style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary),
            ),
            AppSpacing.vGapMd,
            _buildStatusDistribution(
              summary['greenCount'] as int,
              summary['yellowCount'] as int,
              summary['redCount'] as int,
              summary['totalStudents'] as int,
            ),
            AppSpacing.vGapLg,
            Text(
              'Progres Kelas',
              style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary),
            ),
            AppSpacing.vGapMd,
            _buildDonutChart(summary),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          AppSpacing.vGapSm,
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDistribution(int green, int yellow, int red, int total) {
    return AppCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatusItem('Baik', green, AppColors.success),
          _buildStatusItem('Perbaikan', yellow, AppColors.warning),
          _buildStatusItem('Perlu Perhatian', red, AppColors.danger),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Center(
            child: Text('$count', style: AppTypography.titleMedium.copyWith(color: color, fontWeight: FontWeight.bold)),
          ),
        ),
        AppSpacing.vGapXs,
        Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildDonutChart(Map<String, dynamic> summary) {
    final completed = summary['completedMaterials'] as int;
    final total = summary['totalMaterials'] as int;
    final progress = total > 0 ? completed / total : 0.0;

    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 60,
              startDegreeOffset: -90,
              sections: [
                PieChartSectionData(value: progress * 100, color: AppColors.success, radius: 20, showTitle: false),
                PieChartSectionData(value: (1 - progress) * 100, color: AppColors.divider, radius: 20, showTitle: false),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${(progress * 100).toInt()}%', style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              Text('Selesai', style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSiswaTab(int classId) {
    final studentsAsync = ref.watch(classStudentsProvider(classId));

    return studentsAsync.when(
      data: (students) {
        if (students.isEmpty) {
          return const EmptyState(icon: Icons.people_outline, title: 'Belum Ada Siswa', description: 'Siswa akan muncul setelah bergabung dengan kelas ini.');
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(classStudentsProvider(classId)),
          child: ListView.builder(
            padding: AppSpacing.screenPadding,
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _StudentListTile(student: student, onTap: () => context.go('/teacher/class/$classId/students/${student.id}')),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildPengaturanTab(int classId, AsyncValue<TeacherClass?> classAsync) {
    final summaryAsync = ref.watch(classSummaryProvider(classId));
    return classAsync.when(
      data: (cls) {
        if (cls == null) return const SizedBox();
        final studentCount = summaryAsync.maybeWhen(
          data: (s) => s['totalStudents'] as int? ?? cls.studentCount,
          orElse: () => cls.studentCount,
        );

        return SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Informasi Kelas', style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary)),
              AppSpacing.vGapMd,
              _buildInfoRow('Nama Kelas', cls.name),
              _buildInfoRow('Jenjang', cls.gradeCategory),
              _buildInfoRow('Tingkat', 'Kelas ${cls.gradeLevel}'),
              _buildInfoRow('Kode Kelas', cls.classCode, canCopy: true),
              AppSpacing.vGapLg,
              Text('Statistik', style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary)),
              AppSpacing.vGapMd,
              _buildInfoRow('Jumlah Siswa', '$studentCount siswa'),
              _buildInfoRow('Materi Selesai', '${cls.completedMaterials}/${cls.totalMaterials}'),
              _buildInfoRow('Rata-rata PULSE', cls.averagePulse.toStringAsFixed(2)),
              AppSpacing.vGapXl,
              SizedBox(
                width: double.infinity,
                child: AppButton(label: 'Bagikan Kode Kelas', variant: AppButtonVariant.primary, icon: Icons.share, onPressed: () => _shareClassCode(context, classAsync)),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool canCopy = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
            Row(
              children: [
                Text(value, style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                if (canCopy) ...[
                  AppSpacing.hGapSm,
                  GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kode disalin!'))),
                    child: Icon(Icons.copy, size: 18, color: AppColors.primary),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPulseColor(double pulse) {
    if (pulse >= 3.5) return AppColors.success;
    if (pulse >= 2.5) return AppColors.warning;
    return AppColors.danger;
  }

  void _shareClassCode(BuildContext context, AsyncValue<TeacherClass?> classAsync) {
    classAsync.whenData((cls) {
      if (cls != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kode kelas: ${cls.classCode}'),
            action: SnackBarAction(label: 'Salin', onPressed: () {}),
          ),
        );
      }
    });
  }

  void _handleMenuAction(BuildContext context, String action, int classId) {
    if (action == 'delete') _showDeleteConfirmation(context, classId);
  }

  void _showDeleteConfirmation(BuildContext context, int classId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kelas'),
        content: const Text('Apakah Anda yakin ingin menghapus kelas ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(teacherServiceProvider).deleteClass(classId);
              ref.invalidate(teacherClassesProvider);
              if (context.mounted) context.go('/teacher/home');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _StudentListTile extends StatelessWidget {
  final ClassStudent student;
  final VoidCallback onTap;

  const _StudentListTile({required this.student, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Center(
              child: Text(_getInitials(student.name), style: AppTypography.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name, style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary)),
                AppSpacing.vGapXs,
                Row(
                  children: [
                    _buildMiniPulseBar(),
                    AppSpacing.hGapSm,
                    StatusBadge(label: _getStatusLabel(student.overallPulse), status: _getStatus(student.overallPulse)),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildMiniPulseBar() {
    return Expanded(
      child: Row(
        children: [
          _buildPulseDot(student.participation),
          _buildPulseDot(student.understanding),
          _buildPulseDot(student.learning),
          _buildPulseDot(student.socialEngagement),
        ],
      ),
    );
  }

  Widget _buildPulseDot(double value) {
    Color color = value >= 3.5 ? AppColors.success : (value >= 2.5 ? AppColors.warning : AppColors.danger);
    return Container(margin: const EdgeInsets.only(right: 4), width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    return parts.length >= 2 ? '${parts[0][0]}${parts[1][0]}'.toUpperCase() : name.substring(0, 1).toUpperCase();
  }

  String _getStatusLabel(double avg) => avg >= 3.5 ? 'Baik' : (avg >= 2.5 ? 'Perbaikan' : 'Perlu Perhatian');
  AppStatus _getStatus(double avg) => avg >= 3.5 ? AppStatus.success : (avg >= 2.5 ? AppStatus.warning : AppStatus.danger);
}