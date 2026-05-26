import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class EditTeacherProfileScreen extends ConsumerStatefulWidget {
  const EditTeacherProfileScreen({super.key});

  @override
  ConsumerState<EditTeacherProfileScreen> createState() => _EditTeacherProfileScreenState();
}

class _EditTeacherProfileScreenState extends ConsumerState<EditTeacherProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  DateTime? _dateOfBirth;
  String? _selectedGender;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _genders = [
    {'value': 'male', 'label': 'Laki-laki', 'icon': Icons.male},
    {'value': 'female', 'label': 'Perempuan', 'icon': Icons.female},
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final user = ref.read(currentUserProvider);
      if (user != null && mounted) {
        _nameController.text = user.name;
        _emailController.text = user.email;
        _phoneController.text = user.phone ?? '';
        _addressController.text = user.address ?? '';
        setState(() {
          if (user.dateOfBirth != null && user.dateOfBirth!.isNotEmpty) {
            _dateOfBirth = DateTime.tryParse(user.dateOfBirth!);
          }
          if (user.gender != null && user.gender!.isNotEmpty) {
            _selectedGender = user.gender;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final initialDate = _dateOfBirth ?? DateTime(1985, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950, 1, 1),
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
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final dobString = _dateOfBirth != null
        ? _dateOfBirth!.toIso8601String().split('T')[0]
        : null;

    final success = await ref.read(authNotifierProvider.notifier).updateTeacherProfile(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          dateOfBirth: dobString,
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          gender: _selectedGender,
        );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      } else {
        final errorMsg = ref.read(authNotifierProvider).errorMessage ?? 'Gagal memperbarui profil';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profil Guru'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            _buildSectionHeader('Informasi Pribadi'),
            AppSpacing.vGapSm,
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    label: 'Nama Lengkap',
                    hint: 'Masukkan nama lengkap',
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama lengkap wajib diisi';
                      }
                      if (value.trim().length < 3) {
                        return 'Nama minimal 3 karakter';
                      }
                      return null;
                    },
                  ),
                  AppSpacing.vGapMd,

                  AppTextField(
                    label: 'Email',
                    hint: 'Masukkan alamat email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email wajib diisi';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                        return 'Masukkan alamat email yang valid';
                      }
                      return null;
                    },
                  ),
                  AppSpacing.vGapMd,
                  
                  // Gender Choice
                  Text(
                    'Jenis Kelamin',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  AppSpacing.vGapXs,
                  Row(
                    children: _genders.map((g) {
                      final isSelected = _selectedGender == g['value'];
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: g['value'] == 'male' ? AppSpacing.sm : 0,
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(() => _selectedGender = g['value'] as String);
                            },
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? AppColors.primary.withValues(alpha: 0.1) 
                                    : AppColors.surface,
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.divider,
                                ),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    g['icon'] as IconData,
                                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  AppSpacing.hGapSm,
                                  Text(
                                    g['label'] as String,
                                    style: AppTypography.labelMedium.copyWith(
                                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  AppSpacing.vGapMd,

                  // Date of Birth
                  Text(
                    'Tanggal Lahir',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  AppSpacing.vGapXs,
                  InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.divider),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                          AppSpacing.hGapMd,
                          Text(
                            _dateOfBirth != null
                                ? _formatDate(_dateOfBirth!)
                                : 'Pilih Tanggal Lahir',
                            style: AppTypography.bodyMedium.copyWith(
                              color: _dateOfBirth != null
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                  AppSpacing.vGapMd,

                  AppTextField(
                    label: 'Nomor Telepon',
                    hint: 'Contoh: 081234567890',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  AppSpacing.vGapMd,

                  AppTextField(
                    label: 'Alamat',
                    hint: 'Masukkan alamat lengkap rumah',
                    controller: _addressController,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            AppSpacing.vGapXl,

            // Simpan button
            AppButton(
              label: 'Simpan Perubahan',
              variant: AppButtonVariant.primary,
              size: AppButtonSize.large,
              loading: _isSubmitting,
              onPressed: _isSubmitting ? null : _saveProfile,
            ),
            AppSpacing.vGapXl,
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Text(
        title,
        style: AppTypography.titleMedium.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
