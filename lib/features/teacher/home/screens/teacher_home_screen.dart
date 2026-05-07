import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

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
                Icon(Icons.class_, size: 64, color: AppColors.primary),
                AppSpacing.vGapMd,
                Text('Teacher Home Screen'),
                AppSpacing.vGapSm,
                Text('Halaman beranda guru - Sprint 4'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
