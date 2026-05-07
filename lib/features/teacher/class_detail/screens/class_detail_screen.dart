import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';

class ClassDetailScreen extends StatelessWidget {
  final String classId;

  const ClassDetailScreen({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.class_, size: 64, color: AppColors.primary),
                AppSpacing.vGapMd,
                Text('Class Detail Screen - ID: $classId'),
                AppSpacing.vGapSm,
                const Text('Halaman detail kelas - Sprint 4'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
