import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:radar_chart_plus/radar_chart_plus.dart';
import '../../../../core/constants/constants.dart';
import '../../home/providers/teacher_provider.dart';
import '../../../../shared/services/services.dart';
import '../../../student/activities/providers/activity_provider.dart';

class TeacherStudentProfileScreen extends ConsumerStatefulWidget {
  final String classId;
  final String studentId;

  const TeacherStudentProfileScreen({
    super.key,
    required this.classId,
    required this.studentId,
  });

  @override
  ConsumerState<TeacherStudentProfileScreen> createState() => _TeacherStudentProfileScreenState();
}

class _TeacherStudentProfileScreenState extends ConsumerState<TeacherStudentProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final classIdInt = int.tryParse(widget.classId) ?? 0;
    final studentIdInt = int.tryParse(widget.studentId) ?? 0;
    final studentsAsync = ref.watch(classStudentsProvider(classIdInt));
    final notesAsync = ref.watch(anecdotalNotesProvider(studentIdInt));
    final activitiesAsync = ref.watch(studentActivitiesProvider(studentIdInt));
    final pulseAsync = ref.watch(studentPulseScoresProvider(studentIdInt));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil Siswa'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/teacher/class/${widget.classId}'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(studentPulseScoresProvider(studentIdInt));
              ref.invalidate(classStudentsProvider(classIdInt));
            },
          ),
        ],
      ),
      body: studentsAsync.when(
        data: (students) {
          final student = students.where((s) => s.id == studentIdInt).firstOrNull;
          if (student == null) {
            return const EmptyState(icon: Icons.person_off, title: 'Siswa Tidak Ditemukan', description: 'Data siswa tidak tersedia.');
          }
          return _buildContent(student, notesAsync, studentIdInt, activitiesAsync, pulseAsync);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(context, studentIdInt),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(
    ClassStudent student,
    AsyncValue<List<AnecdotalNote>> notesAsync,
    int studentId,
    AsyncValue<List<ActivityLog>> activitiesAsync,
    AsyncValue<Map<String, dynamic>> pulseAsync,
  ) {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header
          _buildProfileHeader(student),
          AppSpacing.vGapLg,

          // PULSE Matrix Grid
          Text('Matriks Skor PULSE', style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary)),
          AppSpacing.vGapMd,
          _buildPulseMatrixFromAsync(student, pulseAsync),
          AppSpacing.vGapLg,

          // PULSE Radar Chart
          Text('Grafik Radar', style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary)),
          AppSpacing.vGapMd,
          _buildRadarChartFromAsync(student, pulseAsync),
          AppSpacing.vGapLg,

          // Test Scores per material
          _buildTestScoresSection(pulseAsync),
          AppSpacing.vGapLg,

          // Activity Logs Preview
          _buildActivityLogsPreview(activitiesAsync),
          AppSpacing.vGapLg,

          // Anecdotal Notes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Catatan Anekdot', style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary)),
              TextButton.icon(
                onPressed: () => _showAddNoteDialog(context, studentId),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah'),
              ),
            ],
          ),
          AppSpacing.vGapMd,
          _buildAnecdotalNotes(notesAsync, studentId),
          AppSpacing.vGapXl,
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ClassStudent student) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _getInitials(student.name),
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.primary,
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
                Text(
                  student.name,
                  style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
                ),
                AppSpacing.vGapXs,
                Text(
                  student.email,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
                AppSpacing.vGapXs,
                Row(
                  children: [
                    StatusBadge(
                      label: _getStatusLabel(student.overallPulse),
                      status: _getStatus(student.overallPulse),
                    ),
                    AppSpacing.hGapSm,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(student.overallPulse).withValues(alpha: 0.1),
                        borderRadius: AppRadius.chip,
                      ),
                      child: Text(
                        'Avg: ${student.overallPulse.toStringAsFixed(2)}',
                        style: AppTypography.labelSmall.copyWith(
                          color: _getStatusColor(student.overallPulse),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseMatrixFromAsync(ClassStudent student, AsyncValue<Map<String, dynamic>> pulseAsync) {
    return pulseAsync.when(
      data: (data) {
        final scores = data['pulse_scores'] as Map<String, dynamic>? ?? {};
        final participation = (scores['participation'] as num?)?.toDouble() ?? student.participation;
        final understanding = (scores['understanding'] as num?)?.toDouble() ?? student.understanding;
        final learning = (scores['learning'] as num?)?.toDouble() ?? student.learning;
        final socialEngagement = (scores['social_engagement'] as num?)?.toDouble() ?? student.socialEngagement;
        return _buildPulseMatrixWidget(participation, understanding, learning, socialEngagement);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => _buildPulseMatrixWidget(
        student.participation, student.understanding,
        student.learning, student.socialEngagement,
      ),
    );
  }

  Widget _buildPulseMatrixWidget(double p, double u, double l, double se) {
    final dimensions = [
      {'label': 'Partisipasi', 'value': p, 'dimension': 'P'},
      {'label': 'Pemahaman', 'value': u, 'dimension': 'U'},
      {'label': 'Pembelajaran', 'value': l, 'dimension': 'L'},
      {'label': 'Keterlibatan', 'value': se, 'dimension': 'SE'},
    ];

    return AppCard(
      child: Column(
        children: [
          // Header row
          Row(
            children: [
              const SizedBox(width: 80),
              Expanded(
                child: Text('Skor', style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
              ),
              Text('Status', style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
              const SizedBox(width: 48),
            ],
          ),
          AppSpacing.vGapSm,
          const Divider(height: 1),
          AppSpacing.vGapSm,
          ...dimensions.map((dim) => _buildMatrixRow(
            dim['label'] as String,
            dim['dimension'] as String,
            dim['value'] as double,
          )),
        ],
      ),
    );
  }

  Widget _buildMatrixRow(String label, String dimension, double score) {
    final color = _getScoreColor(score);
    final statusLabel = score >= 3.5 ? 'Baik' : (score >= 2.5 ? 'Sedang' : 'Perlu');
    final statusColor = color;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          // Dimension label
          SizedBox(
            width: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dimension, style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary)),
                Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary)),
              ],
            ),
          ),
          // Score value
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Center(
              child: Text(
                score.toStringAsFixed(1),
                style: AppTypography.titleMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          AppSpacing.hGapSm,
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: AppRadius.chip,
            ),
            child: Text(
              statusLabel,
              style: AppTypography.labelSmall.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          // Progress bar
          SizedBox(
            width: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: List.generate(5, (index) {
                    final threshold = (index + 1) * 1.0;
                    final isActive = score >= threshold;
                    return Container(
                      margin: const EdgeInsets.only(left: 2),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isActive ? color : AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
                AppSpacing.vGapXs,
                Text(
                  '${(score / 5 * 100).toInt()}%',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarChartFromAsync(ClassStudent student, AsyncValue<Map<String, dynamic>> pulseAsync) {
    return pulseAsync.when(
      data: (data) {
        final scores = data['pulse_scores'] as Map<String, dynamic>? ?? {};
        final p  = (scores['participation'] as num?)?.toDouble()  ?? student.participation;
        final u  = (scores['understanding'] as num?)?.toDouble()  ?? student.understanding;
        final l  = (scores['learning'] as num?)?.toDouble()       ?? student.learning;
        final se = (scores['social_engagement'] as num?)?.toDouble() ?? student.socialEngagement;
        return _buildRadarChartWidget(p, u, l, se);
      },
      loading: () => const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => _buildRadarChartWidget(
        student.participation, student.understanding,
        student.learning, student.socialEngagement,
      ),
    );
  }

  Widget _buildRadarChartWidget(double p, double u, double l, double se) {
    return SizedBox(
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
            data: [p, u, l, se],
            borderColor: AppColors.primary,
            fillColor: AppColors.primary.withValues(alpha: 0.3),
            dotColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTestScoresSection(AsyncValue<Map<String, dynamic>> pulseAsync) {
    return pulseAsync.when(
      data: (data) {
        final testScores = data['test_scores'] as List<dynamic>? ?? [];
        if (testScores.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Skor Pre-Test & Post-Test', style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary)),
            AppSpacing.vGapMd,
            ...testScores.map((item) {
              final map = item as Map<String, dynamic>;
              final materialTitle = map['material_title'] as String? ?? 'Materi #${map['material_id']}';
              final preScore = map['pre_test_score'] as int?;
              final postScore = map['post_test_score'] as int?;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(materialTitle, style: AppTypography.titleSmall.copyWith(color: AppColors.textPrimary)),
                      AppSpacing.vGapSm,
                      Row(
                        children: [
                          _buildScoreChip('Pre-Test', preScore, AppColors.info),
                          AppSpacing.hGapMd,
                          _buildScoreChip('Post-Test', postScore, AppColors.success),
                          AppSpacing.hGapMd,
                          _buildScoreChip(
                            'Peningkatan',
                            (preScore != null && postScore != null) ? (postScore - preScore) : null,
                            (preScore != null && postScore != null)
                                ? (postScore >= preScore ? AppColors.success : AppColors.danger)
                                : AppColors.textSecondary,
                            showSign: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
    );
  }

  Widget _buildScoreChip(String label, int? score, Color color, {bool showSign = false}) {
    final text = score == null
        ? '-'
        : (showSign && score > 0 ? '+$score' : '$score');
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: AppRadius.radiusSm,
          ),
          child: Text(
            score != null ? '$text%' : '-',
            style: AppTypography.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityLogsPreview(AsyncValue<List<ActivityLog>> activitiesAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Log Aktivitas Terkini', style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary)),
            TextButton(
              onPressed: () {
                // TODO: Navigate to full activity log
              },
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        AppSpacing.vGapMd,
        activitiesAsync.when(
          data: (activities) {
            if (activities.isEmpty) {
              return AppCard(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        Icon(Icons.history, size: 32, color: AppColors.textSecondary),
                        AppSpacing.vGapSm,
                        Text('Belum ada aktivitas', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              );
            }
            return SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: activities.take(5).length,
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: AppSpacing.sm),
                    child: AppCard(
                      onTap: () => context.push('/teacher/activities/${activity.id}'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _buildCategoryIcon(activity.category),
                              AppSpacing.hGapXs,
                              Expanded(
                                child: Text(
                                  _getCategoryLabel(activity.category),
                                  style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.vGapSm,
                          Text(
                            activity.title,
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Text(
                            _formatDate(activity.activityDate),
                            style: AppTypography.labelSmall.copyWith(color: AppColors.textHint),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
        ),
      ],
    );
  }

  Widget _buildCategoryIcon(String category) {
    IconData icon;
    Color color;
    switch (category) {
      case 'participation':
        icon = Icons.how_to_reg;
        color = AppColors.primary;
        break;
      case 'understanding':
        icon = Icons.lightbulb;
        color = AppColors.warning;
        break;
      case 'learning':
        icon = Icons.school;
        color = AppColors.success;
        break;
      case 'social_engagement':
        icon = Icons.people;
        color = AppColors.info;
        break;
      default:
        icon = Icons.assignment;
        color = AppColors.textSecondary;
    }
    return Icon(icon, size: 16, color: color);
  }

  Widget _buildAnecdotalNotes(AsyncValue<List<AnecdotalNote>> notesAsync, int studentId) {
    return notesAsync.when(
      data: (notes) {
        if (notes.isEmpty) {
          return AppCard(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Icon(Icons.note_add, size: 48, color: AppColors.textSecondary),
                  AppSpacing.vGapMd,
                  Text('Belum ada catatan', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  AppSpacing.vGapSm,
                  Text('Tekan tombol + untuk menambah catatan anekdot.', style: AppTypography.labelSmall.copyWith(color: AppColors.textHint)),
                ],
              ),
            ),
          );
        }

        return Column(
          children: notes.map((note) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _AnecdotalNoteCard(note: note, onDelete: () => _deleteNote(note.id, studentId)),
          )).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
    );
  }

  void _showAddNoteDialog(BuildContext context, int studentId) {
    final contentController = TextEditingController();
    String selectedDimension = 'participation';

    final dimensions = [
      {'value': 'participation', 'label': 'Partisipasi', 'icon': Icons.how_to_reg},
      {'value': 'understanding', 'label': 'Pemahaman', 'icon': Icons.lightbulb},
      {'value': 'learning', 'label': 'Pembelajaran', 'icon': Icons.school},
      {'value': 'social_engagement', 'label': 'Keterlibatan Sosial', 'icon': Icons.people},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                  Text('Catatan Anekdot Baru', style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              AppSpacing.vGapMd,
              Text('Dimensi PULSE', style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary)),
              AppSpacing.vGapSm,
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: dimensions.map((dim) {
                  final isSelected = selectedDimension == dim['value'];
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(dim['icon'] as IconData, size: 16, color: isSelected ? Colors.white : AppColors.textSecondary),
                        AppSpacing.hGapXs,
                        Text(dim['label'] as String),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (sel) { if (sel) setState(() => selectedDimension = dim['value'] as String); },
                    selectedColor: AppColors.primary,
                    labelStyle: AppTypography.labelMedium.copyWith(color: isSelected ? Colors.white : AppColors.textPrimary),
                  );
                }).toList(),
              ),
              AppSpacing.vGapMd,
              AppTextField(
                label: 'Catatan',
                hint: 'Tuliskan observasi tentang siswa...',
                controller: contentController,
                maxLines: 4,
              ),
              AppSpacing.vGapLg,
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: 'Simpan Catatan',
                  variant: AppButtonVariant.primary,
                  onPressed: () async {
                    if (contentController.text.isNotEmpty) {
                      try {
                        final service = ref.read(teacherServiceProvider);
                        await service.createAnecdotalNote(
                          studentId: studentId,
                          content: contentController.text,
                          dimension: selectedDimension,
                        );
                        ref.invalidate(anecdotalNotesProvider(studentId));
                        if (context.mounted) Navigator.pop(context);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal menyimpan catatan: ${e.toString().replaceAll('Exception: ', '')}'),
                              backgroundColor: AppColors.danger,
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteNote(int noteId, int studentId) async {
    await ref.read(teacherServiceProvider).deleteAnecdotalNote(studentId, noteId);
    ref.invalidate(anecdotalNotesProvider(studentId));
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    return parts.length >= 2 ? '${parts[0][0]}${parts[1][0]}'.toUpperCase() : name.substring(0, 1).toUpperCase();
  }

  String _getStatusLabel(double avg) => avg >= 3.5 ? 'Baik' : (avg >= 2.5 ? 'Perbaikan' : 'Perlu Perhatian');
  AppStatus _getStatus(double avg) => avg >= 3.5 ? AppStatus.success : (avg >= 2.5 ? AppStatus.warning : AppStatus.danger);
  Color _getStatusColor(double avg) => avg >= 3.5 ? AppColors.success : (avg >= 2.5 ? AppColors.warning : AppColors.danger);
  Color _getScoreColor(double score) => score >= 3.5 ? AppColors.success : (score >= 2.5 ? AppColors.warning : AppColors.danger);

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'participation': return 'Partisipasi';
      case 'understanding': return 'Pemahaman';
      case 'learning': return 'Pembelajaran';
      case 'social_engagement': return 'Keterlibatan';
      default: return category;
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${months[date.month - 1]}';
  }
}

class _AnecdotalNoteCard extends StatelessWidget {
  final AnecdotalNote note;
  final VoidCallback onDelete;

  const _AnecdotalNoteCard({required this.note, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildDimensionBadge(),
              const Spacer(),
              Text(_formatDate(note.createdAt), style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary)),
              AppSpacing.hGapSm,
              GestureDetector(
                onTap: () => _showDeleteConfirmation(context),
                child: Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
              ),
            ],
          ),
          AppSpacing.vGapMd,
          Text(note.content, style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildDimensionBadge() {
    String label;
    Color color;
    switch (note.dimension) {
      case 'participation':
        label = 'Partisipasi';
        color = AppColors.primary;
        break;
      case 'understanding':
        label = 'Pemahaman';
        color = AppColors.warning;
        break;
      case 'learning':
        label = 'Pembelajaran';
        color = AppColors.success;
        break;
      case 'social_engagement':
        label = 'Keterlibatan';
        color = AppColors.info;
        break;
      default:
        label = note.dimension;
        color = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: AppRadius.chip),
      child: Text(label, style: AppTypography.labelSmall.copyWith(color: color, fontWeight: FontWeight.bold)),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Catatan'),
        content: const Text('Apakah Anda yakin ingin menghapus catatan ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); onDelete(); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${months[date.month - 1]}';
  }
}
