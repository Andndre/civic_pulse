import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';

class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({super.key});

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
                Icon(Icons.assignment, size: 64, color: AppColors.primary),
                AppSpacing.vGapMd,
                Text('Activity Log Screen'),
                AppSpacing.vGapSm,
                Text('Halaman log aktivitas - Sprint 3'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
