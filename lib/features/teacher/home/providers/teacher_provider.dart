import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/services/services.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Teacher classes provider
final teacherClassesProvider = FutureProvider<List<TeacherClass>>((ref) async {
  final user = ref.watch(currentUserProvider);

  if (user == null || !user.isTeacher) {
    return [];
  }

  final service = ref.watch(teacherServiceProvider);
  return service.getTeacherClasses(user.id);
});

// Single class provider
final classDetailProvider = FutureProvider.family<TeacherClass?, int>((ref, classId) async {
  final service = ref.watch(teacherServiceProvider);
  return service.getClassDetail(classId);
});

// Class students provider
final classStudentsProvider = FutureProvider.family<List<ClassStudent>, int>((ref, classId) async {
  final service = ref.watch(teacherServiceProvider);
  return service.getClassStudents(classId);
});

// Student anecdotal notes provider
final anecdotalNotesProvider = FutureProvider.family<List<AnecdotalNote>, int>((ref, studentId) async {
  final service = ref.watch(teacherServiceProvider);
  return service.getAnecdotalNotes(studentId);
});

// Create anecdotal note params
class CreateAnecdotalNoteParams {
  final int studentId;
  final String content;
  final String dimension;

  const CreateAnecdotalNoteParams({
    required this.studentId,
    required this.content,
    required this.dimension,
  });
}

// Create anecdotal note provider
final createAnecdotalNoteProvider = FutureProvider.family<AnecdotalNote, CreateAnecdotalNoteParams>((ref, params) async {
  final service = ref.watch(teacherServiceProvider);
  return service.createAnecdotalNote(
    studentId: params.studentId,
    content: params.content,
    dimension: params.dimension,
  );
});

// Class summary provider
final classSummaryProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, classId) async {
  final students = await ref.watch(classStudentsProvider(classId).future);

  // Calculate summary statistics
  int greenCount = 0;
  int yellowCount = 0;
  int redCount = 0;

  for (final student in students) {
    final avg = student.overallPulse;
    if (avg >= 3.5) {
      greenCount++;
    } else if (avg >= 2.5) {
      yellowCount++;
    } else {
      redCount++;
    }
  }

  final classDetail = await ref.watch(classDetailProvider(classId).future);

  return {
    'totalStudents': students.length,
    'greenCount': greenCount,
    'yellowCount': yellowCount,
    'redCount': redCount,
    'completedMaterials': classDetail?.completedMaterials ?? 0,
    'totalMaterials': classDetail?.totalMaterials ?? 0,
    'averagePulse': classDetail?.averagePulse ?? 0.0,
    'classCode': classDetail?.classCode ?? '',
  };
});

// Student PULSE scores provider (untuk tampilan guru)
final studentPulseScoresProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, studentId) async {
  final service = ref.watch(teacherServiceProvider);
  return service.getStudentPulseScores(studentId);
});

// Teacher stats provider
final teacherStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(teacherServiceProvider);
  return service.getTeacherStats();
});

// Pending Social Challenges provider (Fase 4)
final pendingSocialChallengesProvider = FutureProvider<List<ActivityLog>>((ref) async {
  final service = ref.watch(teacherServiceProvider);
  return service.getPendingSocialChallenges();
});

// Notifier untuk mereview tantangan sosial secara async (Fase 4)
class ReviewSocialChallengeNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> review({
    required int activityId,
    required String status,
    required int score,
    String? note,
  }) async {
    state = const AsyncLoading();
    try {
      final service = ref.read(teacherServiceProvider);
      await service.reviewSocialChallenge(
        activityId: activityId,
        status: status,
        score: score,
        note: note,
      );
      state = const AsyncData(null);
      // Invalidate pending queue dan stats agar beranda guru ter-update
      ref.invalidate(pendingSocialChallengesProvider);
      ref.invalidate(teacherStatsProvider);
      ref.invalidate(teacherClassesProvider);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final reviewSocialChallengeProvider = AsyncNotifierProvider<ReviewSocialChallengeNotifier, void>(
  ReviewSocialChallengeNotifier.new,
);