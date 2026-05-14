import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/services/mock_models.dart';
import '../../../../shared/services/mock_services.dart';

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

// Activity list provider
final activityListProvider = FutureProvider<List<ActivityLog>>((ref) async {
  final service = MockActivityService();
  return service.getActivities(1); // studentId = 1 for mock
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
  final service = MockActivityService();
  return service.createActivity(
    studentId: 1,
    title: params.title,
    category: params.category,
    location: params.location,
    activityDate: params.activityDate,
    photoUrl: params.photoUrl,
  );
});