import 'data_models.dart';

// =============================================================================
// SERVICE INTERFACES
// =============================================================================

abstract class MaterialServiceInterface {
  Future<List<LearningMaterial>> getMaterials({String? gradeCategory, int? gradeLevel});
  Future<LearningMaterial?> getMaterial(int id);
  Future<List<Question>> getQuestions(int materialId, String type);
  Future<List<PulseStatement>> getPulseStatements(int materialId);
  Future<Map<String, dynamic>> submitTestResponse({
    required int materialId,
    required String type,
    required List<Map<String, dynamic>> answers,
  });
  Future<Map<String, dynamic>> submitPulseResponse({
    required int materialId,
    required List<Map<String, dynamic>> responses,
  });
}

abstract class ClassServiceInterface {
  Future<List<StudentClass>> getStudentClasses(int studentId);
  Future<String?> joinClass(String classCode);
}

abstract class ActivityServiceInterface {
  Future<List<ActivityLog>> getActivities(int studentId);
  Future<ActivityLog?> getActivity(int activityId);
  Future<ActivityLog> createActivity({
    required int studentId,
    required String title,
    required String category,
    required String location,
    required DateTime activityDate,
    String? photoPath,
  });
}

abstract class AnalyticsServiceInterface {
  Future<PulseScores> getPulseScores(int studentId);
  Future<List<StudentProgress>> getProgress(int studentId);
}

abstract class TeacherServiceInterface {
  Future<List<TeacherClass>> getTeacherClasses(int teacherId);
  Future<TeacherClass?> getClassDetail(int classId);
  Future<List<ClassStudent>> getClassStudents(int classId);
  Future<List<AnecdotalNote>> getAnecdotalNotes(int studentId);
  Future<AnecdotalNote> createAnecdotalNote({
    required int studentId,
    required String content,
    required String dimension,
  });
  Future<void> deleteAnecdotalNote(int noteId);
  Future<String> createClass({
    required String name,
    required String gradeCategory,
    required int gradeLevel,
    int? homeroomTeacherId,
  });
  Future<void> deleteClass(int classId);
}
