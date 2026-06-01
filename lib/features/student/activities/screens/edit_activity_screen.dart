import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/services/services.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/activity_provider.dart';

class EditActivityScreen extends ConsumerStatefulWidget {
  final int activityId;

  const EditActivityScreen({super.key, required this.activityId});

  @override
  ConsumerState<EditActivityScreen> createState() => _EditActivityScreenState();
}

class _EditActivityScreenState extends ConsumerState<EditActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  String _selectedCategory = 'participation';
  String _selectedLocation = 'rumah';
  DateTime _activityDate = DateTime.now();
  XFile? _selectedImage;
  String? _existingPhotoUrl;
  bool _isSubmitting = false;
  bool _isInitialized = false;

  final List<Map<String, dynamic>> _categories = [
    {'value': 'participation', 'label': 'Partisipasi', 'icon': Icons.how_to_reg},
    {'value': 'understanding', 'label': 'Pemahaman', 'icon': Icons.lightbulb_outline},
    {'value': 'learning', 'label': 'Pembelajaran', 'icon': Icons.school_outlined},
    {'value': 'social_engagement', 'label': 'Keterlibatan Sosial', 'icon': Icons.people_outline},
  ];

  final List<Map<String, dynamic>> _locations = [
    {'value': 'rumah', 'label': 'Rumah', 'icon': Icons.home_outlined},
    {'value': 'sekolah', 'label': 'Sekolah', 'icon': Icons.school_outlined},
    {'value': 'kelas', 'label': 'Kelas', 'icon': Icons.class_outlined},
    {'value': 'masyarakat', 'label': 'Masyarakat', 'icon': Icons.people_outline},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _initializeData(ActivityLog activity) {
    if (_isInitialized) return;
    _titleController.text = activity.title;
    _selectedCategory = activity.category;
    _selectedLocation = activity.location;
    _activityDate = activity.activityDate;
    _existingPhotoUrl = activity.photoUrl;
    _isInitialized = true;
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final image = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImage = image;
          _existingPhotoUrl = null; // Clear existing photo when new one is picked
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih Sumber Gambar',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            AppSpacing.vGapLg,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ImageSourceOption(
                  icon: Icons.camera_alt,
                  label: 'Kamera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _ImageSourceOption(
                  icon: Icons.photo_library,
                  label: 'Galeri',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            AppSpacing.vGapLg,
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _activityDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _activityDate = picked);
    }
  }

  Future<void> _submitActivity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final user = ref.read(currentUserProvider);
      final studentId = user?.id ?? 1;
      final service = ref.read(activityServiceProvider);
      
      await service.updateActivity(
        activityId: widget.activityId,
        title: _titleController.text,
        category: _selectedCategory,
        location: _selectedLocation,
        activityDate: _activityDate,
        photoPath: _selectedImage?.path,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aktivitas berhasil diperbarui!'),
            backgroundColor: AppColors.success,
          ),
        );
        ref.invalidate(studentActivitiesProvider(studentId));
        ref.invalidate(activityListProvider);
        ref.invalidate(activityProvider(widget.activityId));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui: $e'),
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
    final activityAsync = ref.watch(activityProvider(widget.activityId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Aktivitas'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: activityAsync.when(
        data: (activity) {
          if (activity == null) {
            return const EmptyState(
              icon: Icons.error_outline,
              title: 'Aktivitas Tidak Ditemukan',
              description: 'Detail aktivitas tidak dapat ditemukan atau telah dihapus.',
            );
          }
          
          _initializeData(activity);

          return Form(
            key: _formKey,
            child: ListView(
              padding: AppSpacing.screenPadding,
              children: [
                // Title field
                AppTextField(
                  label: 'Judul Aktivitas',
                  hint: 'Contoh: Ikut rapat RT',
                  controller: _titleController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Judul aktivitas wajib diisi';
                    }
                    if (value.length < 5) {
                      return 'Judul minimal 5 karakter';
                    }
                    return null;
                  },
                ),
                AppSpacing.vGapMd,

                // Category selection
                Text(
                  'Kategori PULSE',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                AppSpacing.vGapSm,
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat['value'];
                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            cat['icon'] as IconData,
                            size: 18,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                          AppSpacing.hGapXs,
                          Text(cat['label'] as String),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedCategory = cat['value'] as String);
                        }
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: AppTypography.labelMedium.copyWith(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                      backgroundColor: AppColors.surface,
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.divider,
                      ),
                    );
                  }).toList(),
                ),
                AppSpacing.vGapMd,

                // Location field
                Text(
                  'Lokasi Kegiatan',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                AppSpacing.vGapSm,
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: _locations.map((loc) {
                    final isSelected = _selectedLocation == loc['value'];
                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            loc['icon'] as IconData,
                            size: 18,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                          AppSpacing.hGapXs,
                          Text(loc['label'] as String),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedLocation = loc['value'] as String);
                        }
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: AppTypography.labelMedium.copyWith(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                      backgroundColor: AppColors.surface,
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.divider,
                      ),
                    );
                  }).toList(),
                ),
                AppSpacing.vGapMd,

                // Date picker
                Text(
                  'Tanggal Aktivitas',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                AppSpacing.vGapSm,
                AppCard(
                  onTap: _selectDate,
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppColors.primary),
                      AppSpacing.hGapMd,
                      Text(
                        _formatDate(_activityDate),
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.edit, color: AppColors.textSecondary),
                    ],
                  ),
                ),
                AppSpacing.vGapMd,

                // Image picker / preview
                Text(
                  'Foto Aktivitas (opsional)',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                AppSpacing.vGapSm,
                _buildPhotoPreviewWidget(),
                AppSpacing.vGapXl,

                // Submit button
                AppButton(
                  label: 'Simpan Perubahan',
                  variant: AppButtonVariant.primary,
                  size: AppButtonSize.large,
                  loading: _isSubmitting,
                  onPressed: _isSubmitting ? null : _submitActivity,
                ),
                AppSpacing.vGapLg,
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
              AppSpacing.vGapMd,
              Text('Gagal memuat data: $error'),
              AppSpacing.vGapMd,
              AppButton(
                label: 'Kembali',
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPreviewWidget() {
    if (_selectedImage != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: kIsWeb
                ? Image.network(
                    _selectedImage!.path,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
                  )
                : Image.file(
                    File(_selectedImage!.path),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
                  ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => setState(() => _selectedImage = null),
              ),
            ),
          ),
        ],
      );
    } else if (_existingPhotoUrl != null && _existingPhotoUrl!.isNotEmpty) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Image.network(
              _existingPhotoUrl!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                onPressed: _showImageSourcePicker,
              ),
            ),
          ),
        ],
      );
    } else {
      return _buildImagePlaceholder();
    }
  }

  Widget _buildImagePlaceholder() {
    return AppCard(
      onTap: _showImageSourcePicker,
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo,
              size: 48,
              color: AppColors.textSecondary,
            ),
            AppSpacing.vGapSm,
            Text(
              'Tambah Foto Baru',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorImage() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.divider.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.broken_image_outlined,
            size: 48,
            color: AppColors.textHint,
          ),
          AppSpacing.vGapSm,
          Text(
            'Gagal memuat preview gambar',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
                    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 32),
          ),
          AppSpacing.vGapSm,
          Text(
            label,
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
