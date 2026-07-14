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
  // Learning Board (Fase 3)
  Future<List<LearningNode>> getLearningBoard(int materialId);
  Future<NodeCompleteResult> completeNode({
    required int materialId,
    required int nodeId,
    required Map<String, dynamic> submittedAnswer,
    bool? isCorrect,
    int? score,
  });
  Future<Map<String, dynamic>> submitSocialTask({
    required int materialId,
    required int nodeId,
    required String caption,
    String? photoPath,
  });
  Future<void> completeMedia(int materialId);
  Future<List<LearningMaterial>> getClassMaterials(int classId);
  Future<LearningMaterial> addClassMaterial({
    required int classId,
    required String title,
    String? description,
    String? filePath,
    String? audioPath,
    int? templateId,
  });
  Future<LearningMaterial> updateClassMaterial(
    int materialId, {
    required String title,
    String? description,
    String? filePath,
    String? audioPath,
  });
  Future<void> deleteClassMaterial(int materialId);
  Future<List<Map<String, dynamic>>> getMaterialTemplates();
  Future<LearningMaterial> importMaterialTemplate({
    required int classId,
    required int templateId,
  });
  Future<LearningMaterial> duplicateMaterial({
    required int materialId,
    required int targetClassId,
  });

  // Question CRUD for Teacher
  Future<Question> createQuestion({
    required int materialId,
    required String type,
    required String questionText,
    required List<String> options,
    required String correctAnswer,
  });
  Future<Question> updateQuestion(
    int questionId, {
    String? questionText,
    List<String>? options,
    String? correctAnswer,
  });
  Future<void> deleteQuestion(int questionId);

  // Learning Node CRUD for Teacher
  Future<LearningNode> createLearningNode({
    required int materialId,
    required String nodeType,
    required String title,
    required String body,
    String? gameType,
    Map<String, dynamic>? payload,
    int? orderIndex,
  });
  Future<LearningNode> updateLearningNode(
    int nodeId, {
    String? nodeType,
    String? title,
    String? body,
    String? gameType,
    Map<String, dynamic>? payload,
    int? orderIndex,
  });
  Future<void> deleteLearningNode(int nodeId);
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
  Future<ActivityLog> updateActivity({
    required int activityId,
    required String title,
    required String category,
    required String location,
    required DateTime activityDate,
    String? photoPath,
  });
  Future<void> deleteActivity(int activityId);
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
  Future<void> deleteAnecdotalNote(int studentId, int noteId);
  Future<String> createClass({
    required String name,
    required String gradeCategory,
    required int gradeLevel,
    int? homeroomTeacherId,
  });
  Future<void> deleteClass(int classId);
  /// Ambil skor PULSE + test scores untuk siswa tertentu (untuk tampilan guru)
  Future<Map<String, dynamic>> getStudentPulseScores(int studentId);
  /// Ambil statistik kelas, siswa, dan catatan anekdot untuk guru saat ini
  Future<Map<String, dynamic>> getTeacherStats();
  // Tantangan Sosial Review (Fase 4)
  Future<List<ActivityLog>> getPendingSocialChallenges();
  Future<Map<String, dynamic>> reviewSocialChallenge({
    required int activityId,
    required String status, // 'approved' | 'rejected'
    required int score, // 1-5
    String? note,
  });
}

