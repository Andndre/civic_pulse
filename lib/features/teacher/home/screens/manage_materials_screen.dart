import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/services/services.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ManageMaterialsScreen extends ConsumerStatefulWidget {
  final int classId;

  const ManageMaterialsScreen({
    super.key,
    required this.classId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ManageMaterialsScreenState();
}

class _ManageMaterialsScreenState extends ConsumerState<ManageMaterialsScreen> {
  bool _isLoading = true;
  List<LearningMaterial> _materials = [];
  TeacherClass? _classDetail;
  List<TeacherClass> _myClasses = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final materialService = ref.read(materialServiceProvider);
      final teacherService = ref.read(teacherServiceProvider);

      // Load class detail
      _classDetail = await teacherService.getClassDetail(widget.classId);

      // Load class materials
      _materials = await materialService.getClassMaterials(widget.classId);

      // Load all my classes (for duplication target)
      final user = ref.read(currentUserProvider);
      if (user != null) {
        _myClasses = await teacherService.getTeacherClasses(user.id);
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDuplicateMaterial(int materialId, int targetClassId) async {
    setState(() => _isLoading = true);
    try {
      final materialService = ref.read(materialServiceProvider);
      await materialService.duplicateMaterial(
        materialId: materialId,
        targetClassId: targetClassId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Materi berhasil diduplikasi ke kelas tujuan!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menduplikasi materi: $e'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  void _showDuplicateDialog(LearningMaterial material) {
    // Filter classes to exclude current class
    final otherClasses = _myClasses.where((c) => c.id != widget.classId).toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Duplikat "${material.title}"'),
          content: otherClasses.isEmpty
              ? const Text('Anda tidak memiliki kelas lain untuk menduplikasi materi ini.')
              : Container(
                  width: 400,
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: otherClasses.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final c = otherClasses[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.name,
                                    style: AppTypography.titleSmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tingkat ${c.gradeLevel}',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 72,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _handleDuplicateMaterial(material.id, c.id);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                child: const Text('Salin'),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_classDetail != null ? 'Kelola Materi - ${_classDetail!.name}' : 'Kelola Materi Kelas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: $_errorMessage',
                        style: const TextStyle(color: AppColors.danger),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 800;
                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWide ? AppSpacing.xl : AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderCard(isWide),
                          const SizedBox(height: 24),
                          _buildMaterialsSection(isWide),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildHeaderCard(bool isWide) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusLg,
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _classDetail?.name ?? 'Kelas PPKn',
                  style: AppTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kelola Papan Aktivitas E-Learning, pre/post-test, dan kuis gamifikasi untuk kelas ini. Anda dapat menambahkan materi custom atau menyalin materi ke kelas lainnya.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (isWide) const SizedBox(width: 40),
          if (isWide)
            ElevatedButton.icon(
              onPressed: () async {
                final refresh = await context.push<bool>('/teacher/class/${widget.classId}/materials/0/edit');
                if (refresh == true) _loadData();
              },
              icon: const Icon(Icons.add),
              label: const Text('Input Materi Baru'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMaterialsSection(bool isWide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daftar Materi Aktif (${_materials.length})',
              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            if (!isWide)
              IconButton(
                icon: const Icon(Icons.add, color: AppColors.primary),
                onPressed: () async {
                  final refresh = await context.push<bool>('/teacher/class/${widget.classId}/materials/0/edit');
                  if (refresh == true) _loadData();
                },
                tooltip: 'Input Materi Baru',
              ),
          ],
        ),
        const SizedBox(height: 16),
        _materials.isEmpty
            ? Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      const Icon(Icons.menu_book_outlined, size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada materi terdaftar di kelas ini.',
                        style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Silakan buat materi baru untuk memulai.',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final refresh = await context.push<bool>('/teacher/class/${widget.classId}/materials/0/edit');
                          if (refresh == true) _loadData();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Input Materi Baru'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textOnPrimary,
                          minimumSize: const Size(0, 48),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                children: [
                  for (var i = 0; i < _materials.length; i++) ...[
                    if (i > 0) const SizedBox(height: 16),
                    _buildMaterialCard(_materials[i]),
                  ],
                ],
              ),
      ],
    );
  }

  Widget _buildMaterialCard(LearningMaterial m) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusMd,
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    m.title,
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.15),
                    borderRadius: AppRadius.chip,
                  ),
                  child: Text(
                    '${m.gradeCategory} - Kelas ${m.gradeLevel}',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              m.description ?? 'Tidak ada deskripsi.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showDuplicateDialog(m),
                  icon: const Icon(Icons.copy_all_outlined, size: 18),
                  label: const Text('Duplikat'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final refresh = await context.push<bool>('/teacher/class/${widget.classId}/materials/${m.id}/edit');
                    if (refresh == true) _loadData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceVariant,
                    foregroundColor: AppColors.textPrimary,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
                  ),
                  child: const Text('Ubah / Detail'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
