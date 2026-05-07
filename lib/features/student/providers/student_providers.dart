import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/services/mock_models.dart';
import '../../../../shared/services/mock_services.dart';

// Student classes provider
final studentClassesProvider = FutureProvider<List<StudentClass>>((ref) async {
  final service = MockClassService();
  return service.getStudentClasses(1); // studentId = 1 for mock
});

// Activities provider
final activitiesProvider = FutureProvider<List<ActivityLog>>((ref) async {
  final service = MockActivityService();
  return service.getActivities(1); // studentId = 1 for mock
});
