import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';

class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({super.key});

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
                Text('Teacher Profile Screen'),
                AppSpacing.vGapSm,
                Text('Halaman profil guru - Sprint 4'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
