import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/services/services.dart';
import '../../auth/presentation/providers/auth_provider.dart';

// Student classes provider
final studentClassesProvider = FutureProvider<List<StudentClass>>((ref) async {
  final service = ref.watch(classServiceProvider);
  final user = ref.watch(currentUserProvider);
  final studentId = user?.id ?? 1; // Fallback to 1 for mock compatibility
  return service.getStudentClasses(studentId);
});

// Activities provider
final activitiesProvider = FutureProvider<List<ActivityLog>>((ref) async {
  final service = ref.watch(activityServiceProvider);
  final user = ref.watch(currentUserProvider);
  final studentId = user?.id ?? 1; // Fallback to 1 for mock compatibility
  return service.getActivities(studentId);
});
