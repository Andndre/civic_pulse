import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/services/mock_models.dart';
import '../../../../shared/services/mock_services.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Teacher classes provider
final teacherClassesProvider = FutureProvider<List<TeacherClass>>((ref) async {
  final authState = ref.read(authNotifierProvider);
  final user = authState.user;

  if (user == null || !user.isTeacher) {
    return [];
  }

  final service = MockTeacherService();
  return service.getTeacherClasses(user.id);
});

// Single class provider
final classDetailProvider = FutureProvider.family<TeacherClass?, int>((ref, classId) async {
  final classes = await ref.watch(teacherClassesProvider.future);
  try {
    return classes.firstWhere((c) => c.id == classId);
  } catch (_) {
    return null;
  }
});

// Class students provider
final classStudentsProvider = FutureProvider.family<List<ClassStudent>, int>((ref, classId) async {
  final service = MockTeacherService();
  return service.getClassStudents(classId);
});

// Student anecdotal notes provider
final anecdotalNotesProvider = FutureProvider.family<List<AnecdotalNote>, int>((ref, studentId) async {
  final service = MockTeacherService();
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
  final service = MockTeacherService();
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
  };
});