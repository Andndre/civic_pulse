import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';

class ScoresFeedbackScreen extends StatelessWidget {
  const ScoresFeedbackScreen({super.key});

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
                Icon(Icons.bar_chart, size: 64, color: AppColors.primary),
                AppSpacing.vGapMd,
                Text('Scores Feedback Screen'),
                AppSpacing.vGapSm,
                Text('Halaman skor & umpan balik - Sprint 3'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
