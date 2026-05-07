import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school, size: 64, color: AppColors.primary),
                AppSpacing.vGapMd,
                Text('Student Home Screen'),
                AppSpacing.vGapSm,
                Text('Halaman beranda siswa - Sprint 2'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
