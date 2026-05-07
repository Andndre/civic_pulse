import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

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
                Icon(Icons.person, size: 64, color: AppColors.primary),
                AppSpacing.vGapMd,
                Text('Student Profile Screen'),
                AppSpacing.vGapSm,
                Text('Halaman profil siswa - Sprint 3'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
