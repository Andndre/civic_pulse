import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/services/services.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Activity filter state
class ActivityFilter {
  final String? category;

  const ActivityFilter({this.category});

  ActivityFilter copyWith({String? category}) {
    return ActivityFilter(category: category ?? this.category);
  }
}

// Activity filter notifier
class ActivityFilterNotifier extends Notifier<ActivityFilter> {
  @override
  ActivityFilter build() {
    return const ActivityFilter();
  }

  void setCategory(String? category) {
    state = ActivityFilter(category: category);
  }

  void clear() {
    state = const ActivityFilter();
  }
}

final activityFilterProvider =
    NotifierProvider<ActivityFilterNotifier, ActivityFilter>(
        ActivityFilterNotifier.new);

// Student activities provider by student ID
final studentActivitiesProvider = FutureProvider.family<List<ActivityLog>, int>((ref, studentId) async {
  final service = ref.watch(activityServiceProvider);
  return service.getActivities(studentId);
});

// Activity list provider
final activityListProvider = FutureProvider<List<ActivityLog>>((ref) async {
  final user = ref.watch(currentUserProvider);
  final studentId = user?.id ?? 1; // Fallback to 1 for mock compatibility
  return ref.watch(studentActivitiesProvider(studentId).future);
});

// Single activity provider
final activityProvider = FutureProvider.family<ActivityLog?, int>((ref, id) async {
  final activities = await ref.watch(activityListProvider.future);
  try {
    return activities.firstWhere((a) => a.id == id);
  } catch (_) {
    return null;
  }
});

// Create activity params
class CreateActivityParams {
  final String title;
  final String category;
  final String location;
  final DateTime activityDate;
  final String? photoUrl;

  const CreateActivityParams({
    required this.title,
    required this.category,
    required this.location,
    required this.activityDate,
    this.photoUrl,
  });
}

// Create activity provider
final createActivityProvider = FutureProvider.family<ActivityLog, CreateActivityParams>((ref, params) async {
  final service = ref.watch(activityServiceProvider);
  final user = ref.watch(currentUserProvider);
  final studentId = user?.id ?? 1; // Fallback to 1 for mock compatibility
  return service.createActivity(
    studentId: studentId,
    title: params.title,
    category: params.category,
    location: params.location,
    activityDate: params.activityDate,
    photoPath: params.photoUrl,
  );
});