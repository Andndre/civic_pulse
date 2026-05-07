import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';

class LearningGalleryScreen extends StatelessWidget {
  const LearningGalleryScreen({super.key});

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
                Icon(Icons.menu_book, size: 64, color: AppColors.primary),
                AppSpacing.vGapMd,
                Text('Learning Gallery Screen'),
                AppSpacing.vGapSm,
                Text('Halaman galeri belajar - Sprint 2'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
