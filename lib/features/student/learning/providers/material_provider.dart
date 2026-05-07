import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/services/mock_models.dart';
import '../../../../shared/services/mock_services.dart';

// Material filter state
class MaterialFilter {
  final String? gradeCategory;
  final int? gradeLevel;

  const MaterialFilter({this.gradeCategory, this.gradeLevel});

  MaterialFilter copyWith({String? gradeCategory, int? gradeLevel}) {
    return MaterialFilter(
      gradeCategory: gradeCategory ?? this.gradeCategory,
      gradeLevel: gradeLevel ?? this.gradeLevel,
    );
  }
}

// Material filter notifier (Riverpod 3.x pattern)
class MaterialFilterNotifier extends Notifier<MaterialFilter> {
  @override
  MaterialFilter build() {
    return const MaterialFilter();
  }

  void setGradeCategory(String? category) {
    state = MaterialFilter(gradeCategory: category);
  }

  void clear() {
    state = const MaterialFilter();
  }
}

final materialFilterProvider =
    NotifierProvider<MaterialFilterNotifier, MaterialFilter>(
        MaterialFilterNotifier.new);

// Materials list provider
final materialsProvider = FutureProvider<List<LearningMaterial>>((ref) async {
  final filter = ref.watch(materialFilterProvider);
  final service = MockMaterialService();
  return service.getMaterials(
    gradeCategory: filter.gradeCategory,
    gradeLevel: filter.gradeLevel,
  );
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
