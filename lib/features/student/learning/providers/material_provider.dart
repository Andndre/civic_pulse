import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/services/mock_models.dart';
import '../../../../shared/services/mock_services.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Materials list provider - filter by student's enrolled class
final materialsProvider = FutureProvider<List<LearningMaterial>>((ref) async {
  final service = MockMaterialService();
  final classService = MockClassService();

  // Get current user from auth state
  final authState = ref.read(authNotifierProvider);
  final user = authState.user;

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

  // If no enrolled class, return empty list
  if (enrolledClass == null) {
    return [];
  }

  return service.getMaterials(
    gradeCategory: enrolledClass.gradeCategory,
    gradeLevel: enrolledClass.gradeLevel,
  );
});

// Fallback provider untuk development - return semua materi
final allMaterialsProvider = FutureProvider<List<LearningMaterial>>((ref) async {
  final service = MockMaterialService();
  return service.getMaterials();
});

// Single material provider
final materialProvider = FutureProvider.family<LearningMaterial?, int>((ref, id) async {
  final service = MockMaterialService();
  return service.getMaterial(id);
});

// Questions provider
final questionsProvider = FutureProvider.family<List<Question>, ({int materialId, String type})>((ref, params) async {
  final service = MockMaterialService();
  return service.getQuestions(params.materialId, params.type);
});

// PULSE statements provider
final pulseStatementsProvider = FutureProvider.family<List<PulseStatement>, int>((ref, materialId) async {
  final service = MockMaterialService();
  return service.getPulseStatements(materialId);
});

// Progress provider
final studentProgressProvider = FutureProvider<List<StudentProgress>>((ref) async {
  final analyticsService = MockAnalyticsService();
  return analyticsService.getProgress(1); // studentId = 1 for mock
});

// Pulse scores provider
final pulseScoresProvider = FutureProvider<PulseScores>((ref) async {
  final analyticsService = MockAnalyticsService();
  return analyticsService.getPulseScores(1);
});
