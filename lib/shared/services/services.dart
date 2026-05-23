import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'service_interfaces.dart';
import 'real_services.dart';

export 'data_models.dart';
export 'service_interfaces.dart';
export 'real_services.dart';

final materialServiceProvider = Provider<MaterialServiceInterface>((ref) {
  return RealMaterialService();
});

final classServiceProvider = Provider<ClassServiceInterface>((ref) {
  return RealClassService();
});

final activityServiceProvider = Provider<ActivityServiceInterface>((ref) {
  return RealActivityService();
});

final analyticsServiceProvider = Provider<AnalyticsServiceInterface>((ref) {
  return RealAnalyticsService();
});

final teacherServiceProvider = Provider<TeacherServiceInterface>((ref) {
  return RealTeacherService();
});
