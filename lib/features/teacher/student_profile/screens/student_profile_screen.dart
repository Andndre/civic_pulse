import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';

class TeacherStudentProfileScreen extends StatelessWidget {
  final String classId;
  final String studentId;

  const TeacherStudentProfileScreen({
    super.key,
    required this.classId,
    required this.studentId,
  });

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
                const Icon(Icons.person, size: 64, color: AppColors.primary),
                AppSpacing.vGapMd,
                Text('Student Profile - Class: $classId, Student: $studentId'),
                AppSpacing.vGapSm,
                const Text('Halaman profil siswa (guru view) - Sprint 4'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
