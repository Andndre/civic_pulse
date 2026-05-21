import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mock_services.dart';
import 'real_services.dart';

export 'mock_models.dart';
export 'mock_data.dart';
export 'mock_services.dart';
export 'real_services.dart';

// Set to false to use Laravel REST API backend, true for local mock data.
const bool useMockData = false;

final materialServiceProvider = Provider<MaterialServiceInterface>((ref) {
  if (useMockData) {
    return MockMaterialService();
  }
  return RealMaterialService();
});

final classServiceProvider = Provider<ClassServiceInterface>((ref) {
  if (useMockData) {
    return MockClassService();
  }
  return RealClassService();
});

final activityServiceProvider = Provider<ActivityServiceInterface>((ref) {
  if (useMockData) {
    return MockActivityService();
  }
  return RealActivityService();
});

final analyticsServiceProvider = Provider<AnalyticsServiceInterface>((ref) {
  if (useMockData) {
    return MockAnalyticsService();
  }
  return RealAnalyticsService();
});

final teacherServiceProvider = Provider<TeacherServiceInterface>((ref) {
  if (useMockData) {
    return MockTeacherService();
  }
  return RealTeacherService();
});
