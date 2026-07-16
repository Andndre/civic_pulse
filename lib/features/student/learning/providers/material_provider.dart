import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/services/services.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Materials list provider - show materials for student's class, or all materials as fallback
final materialsProvider = FutureProvider<List<LearningMaterial>>((ref) async {
  final service = ref.watch(materialServiceProvider);
  final classService = ref.watch(classServiceProvider);

  // Get current user from auth state
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    return [];
  }

  // Get student's enrolled class
  List<StudentClass> studentClasses = [];
  try {
    studentClasses = await classService.getStudentClasses(user.id);
  } catch (_) {
    studentClasses = [];
  }

  // Use first enrolled class's grade info
  final enrolledClass = studentClasses.isNotEmpty ? studentClasses.first : null;

  // If enrolled in a class, filter by class materials
  if (enrolledClass != null) {
    return service.getClassMaterials(enrolledClass.id);
  }

  // If not enrolled in a class, return empty list
  return [];
});

// Fallback provider untuk development - return semua materi
final allMaterialsProvider = FutureProvider<List<LearningMaterial>>((ref) async {
  final service = ref.watch(materialServiceProvider);
  return service.getMaterials();
});

// Single material provider.
// autoDispose: membawa progres per-siswa (learning_path_status, skor). Tanpa
// autoDispose, cache-nya bertahan setelah ganti akun sehingga siswa baru bisa
// melihat status "selesai" milik siswa sebelumnya. Dibuang saat layar ditutup.
final materialProvider = FutureProvider.autoDispose.family<LearningMaterial?, int>((ref, id) async {
  final service = ref.watch(materialServiceProvider);
  return service.getMaterial(id);
});

// Questions provider
final questionsProvider = FutureProvider.family<List<Question>, ({int materialId, String type})>((ref, params) async {
  final service = ref.watch(materialServiceProvider);
  return service.getQuestions(params.materialId, params.type);
});

// PULSE statements provider
final pulseStatementsProvider = FutureProvider.family<List<PulseStatement>, int>((ref, materialId) async {
  final service = ref.watch(materialServiceProvider);
  return service.getPulseStatements(materialId);
});

// Learning Board provider (Fase 3).
// autoDispose: membawa progres node per-siswa. Sama seperti [materialProvider],
// cache harus dibuang agar tidak bocor antar akun siswa.
final learningBoardProvider = FutureProvider.autoDispose.family<List<LearningNode>, int>((ref, materialId) async {
  final service = ref.watch(materialServiceProvider);
  return service.getLearningBoard(materialId);
});

// Complete node provider - AsyncNotifier so UI can call it imperatively
class CompleteNodeNotifier extends AsyncNotifier<NodeCompleteResult?> {
  @override
  Future<NodeCompleteResult?> build() async => null;

  Future<NodeCompleteResult> complete({
    required int materialId,
    required int nodeId,
    required Map<String, dynamic> submittedAnswer,
    bool? isCorrect,
    int? score,
  }) async {
    state = const AsyncLoading();
    try {
      final service = ref.read(materialServiceProvider);
      final result = await service.completeNode(
        materialId: materialId,
        nodeId: nodeId,
        submittedAnswer: submittedAnswer,
        isCorrect: isCorrect,
        score: score,
      );
      state = AsyncData(result);
      // Invalidate board so it re-fetches updated progress
      ref.invalidate(learningBoardProvider(materialId));
      ref.invalidate(materialProvider(materialId));
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final completeNodeProvider = AsyncNotifierProvider<CompleteNodeNotifier, NodeCompleteResult?>(
  CompleteNodeNotifier.new,
);

// Progress provider
final studentProgressProvider = FutureProvider<List<StudentProgress>>((ref) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  final user = ref.watch(currentUserProvider);
  final studentId = user?.id ?? 1; // Fallback to 1 for mock compatibility
  return analyticsService.getProgress(studentId);
});

// Pulse scores provider
final pulseScoresProvider = FutureProvider<PulseScores>((ref) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  final user = ref.watch(currentUserProvider);
  final studentId = user?.id ?? 1; // Fallback to 1 for mock compatibility
  return analyticsService.getPulseScores(studentId);
});
