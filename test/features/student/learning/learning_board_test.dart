import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:civic_pulse/shared/services/services.dart';
import 'package:civic_pulse/features/student/learning/providers/material_provider.dart';
import 'package:civic_pulse/features/teacher/home/providers/teacher_provider.dart';

// Mock Material Service
class MockMaterialService implements MaterialServiceInterface {
  final List<LearningNode> mockNodes;

  MockMaterialService({required this.mockNodes});

  @override
  Future<List<LearningMaterial>> getMaterials({String? gradeCategory, int? gradeLevel}) async => [];

  @override
  Future<LearningMaterial?> getMaterial(int id) async => null;

  @override
  Future<List<Question>> getQuestions(int materialId, String type) async => [];

  @override
  Future<List<PulseStatement>> getPulseStatements(int materialId) async => [];

  @override
  Future<Map<String, dynamic>> submitTestResponse({
    required int materialId,
    required String type,
    required List<Map<String, dynamic>> answers,
  }) async => {};

  @override
  Future<Map<String, dynamic>> submitPulseResponse({
    required int materialId,
    required List<Map<String, dynamic>> responses,
  }) async => {};

  @override
  Future<List<LearningNode>> getLearningBoard(int materialId) async {
    return mockNodes;
  }

  @override
  Future<NodeCompleteResult> completeNode({
    required int materialId,
    required int nodeId,
    required Map<String, dynamic> submittedAnswer,
    bool? isCorrect,
    int? score,
  }) async {
    return NodeCompleteResult(
      nodeId: nodeId,
      isCorrect: isCorrect ?? true,
      boardProgressPercent: 50,
    );
  }

  @override
  Future<Map<String, dynamic>> submitSocialTask({
    required int materialId,
    required int nodeId,
    required String caption,
    String? photoPath,
  }) async {
    return {'status': 'pending'};
  }

  @override
  Future<void> completeMedia(int materialId) async {}

  @override
  Future<List<LearningMaterial>> getClassMaterials(int classId) async => [];

  @override
  Future<LearningMaterial> addClassMaterial({
    required int classId,
    required String title,
    String? description,
    String? filePath,
    String? audioPath,
    int? templateId,
  }) async {
    return LearningMaterial(
      id: 1,
      title: title,
      description: description,
      fileUrl: filePath,
      audioUrl: audioPath,
      gradeCategory: 'SMA',
      gradeLevel: 10,
      orderIndex: 1,
      status: 'active',
      activityType: 'learning_board',
      boardStatus: 'not_started',
      socialEngagementStatus: 'not_submitted',
    );
  }

  @override
  Future<LearningMaterial> updateClassMaterial(
    int materialId, {
    required String title,
    String? description,
    String? filePath,
    String? audioPath,
  }) async {
    return LearningMaterial(
      id: materialId,
      title: title,
      description: description,
      fileUrl: filePath,
      audioUrl: audioPath,
      gradeCategory: 'SMA',
      gradeLevel: 10,
      orderIndex: 1,
      status: 'active',
      activityType: 'learning_board',
      boardStatus: 'not_started',
      socialEngagementStatus: 'not_submitted',
    );
  }

  @override
  Future<void> deleteClassMaterial(int materialId) async {}

  @override
  Future<List<Map<String, dynamic>>> getMaterialTemplates() async => [];

  @override
  Future<LearningMaterial> importMaterialTemplate({
    required int classId,
    required int templateId,
  }) async {
    return const LearningMaterial(
      id: 1,
      title: 'Imported',
      gradeCategory: 'SMA',
      gradeLevel: 10,
      orderIndex: 1,
      status: 'active',
      activityType: 'learning_board',
      boardStatus: 'not_started',
      socialEngagementStatus: 'not_submitted',
    );
  }

  @override
  Future<LearningMaterial> duplicateMaterial({
    required int materialId,
    required int targetClassId,
  }) async {
    return const LearningMaterial(
      id: 1,
      title: 'Duplicated',
      gradeCategory: 'SMA',
      gradeLevel: 10,
      orderIndex: 1,
      status: 'active',
      activityType: 'learning_board',
      boardStatus: 'not_started',
      socialEngagementStatus: 'not_submitted',
    );
  }

  // Question CRUD mocks
  @override
  Future<Question> createQuestion({
    required int materialId,
    required String type,
    required String questionText,
    required List<String> options,
    required String correctAnswer,
  }) async {
    return Question(
      id: 1,
      materialId: materialId,
      type: type,
      questionNumber: 1,
      content: questionText,
      options: {
        'A': options[0],
        'B': options[1],
        'C': options[2],
        'D': options[3],
      },
      correctAnswer: correctAnswer,
    );
  }

  @override
  Future<Question> updateQuestion(
    int questionId, {
    String? questionText,
    List<String>? options,
    String? correctAnswer,
  }) async {
    return Question(
      id: questionId,
      materialId: 1,
      type: 'pre_test',
      questionNumber: 1,
      content: questionText ?? '',
      options: const {'A': 'Opt A'},
      correctAnswer: correctAnswer ?? 'A',
    );
  }

  @override
  Future<void> deleteQuestion(int questionId) async {}

  // Learning Node CRUD mocks
  @override
  Future<LearningNode> createLearningNode({
    required int materialId,
    required String nodeType,
    required String title,
    required String body,
    String? gameType,
    Map<String, dynamic>? payload,
    int? orderIndex,
  }) async {
    return LearningNode(
      id: 1,
      materialId: materialId,
      nodeType: nodeType,
      title: title,
      body: body,
      gameType: gameType,
      payload: payload,
      orderIndex: orderIndex ?? 1,
    );
  }

  @override
  Future<LearningNode> updateLearningNode(
    int nodeId, {
    String? nodeType,
    String? title,
    String? body,
    String? gameType,
    Map<String, dynamic>? payload,
    int? orderIndex,
  }) async {
    return LearningNode(
      id: nodeId,
      materialId: 1,
      nodeType: nodeType ?? 'content',
      title: title,
      body: body,
      gameType: gameType,
      payload: payload,
      orderIndex: orderIndex ?? 1,
    );
  }

  @override
  Future<void> deleteLearningNode(int nodeId) async {}
}

// Mock Teacher Service
class MockTeacherService implements TeacherServiceInterface {
  final List<ActivityLog> mockPending;

  MockTeacherService({required this.mockPending});

  @override
  Future<List<TeacherClass>> getTeacherClasses(int teacherId) async => [];

  @override
  Future<TeacherClass?> getClassDetail(int classId) async => null;

  @override
  Future<List<ClassStudent>> getClassStudents(int classId) async => [];

  @override
  Future<List<AnecdotalNote>> getAnecdotalNotes(int studentId) async => [];

  @override
  Future<AnecdotalNote> createAnecdotalNote({
    required int studentId,
    required String content,
    required String dimension,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAnecdotalNote(int noteId) async {}

  @override
  Future<String> createClass({
    required String name,
    required String gradeCategory,
    required int gradeLevel,
    int? homeroomTeacherId,
  }) async => '';

  @override
  Future<void> deleteClass(int classId) async {}

  @override
  Future<Map<String, dynamic>> getStudentPulseScores(int studentId) async => {};

  @override
  Future<Map<String, dynamic>> getTeacherStats() async => {};

  @override
  Future<List<ActivityLog>> getPendingSocialChallenges() async {
    return mockPending;
  }

  @override
  Future<Map<String, dynamic>> reviewSocialChallenge({
    required int activityId,
    required String status,
    required int score,
    String? note,
  }) async {
    return {'status': status, 'score': score};
  }
}

void main() {
  group('LearningNode & NodeCompleteResult JSON Parsing Tests', () {
    test('LearningNode content type parsing', () {
      final json = {
        'id': 1,
        'material_id': 10,
        'order_index': 1,
        'node_type': 'content',
        'title': 'Pengenalan Toleransi',
        'body': 'Toleransi adalah...',
        'image_url': 'http://example.com/img.jpg',
        'progress': {'status': 'viewed'},
      };

      final node = LearningNode.fromJson(json);

      expect(node.id, 1);
      expect(node.materialId, 10);
      expect(node.orderIndex, 1);
      expect(node.isContent, true);
      expect(node.isChallenge, false);
      expect(node.isSocialTask, false);
      expect(node.title, 'Pengenalan Toleransi');
      expect(node.body, 'Toleransi adalah...');
      expect(node.imageUrl, 'http://example.com/img.jpg');
      expect(node.isCompleted, true);
    });

    test('LearningNode challenge type parsing', () {
      final json = {
        'id': 2,
        'material_id': 10,
        'order_index': 2,
        'node_type': 'challenge',
        'game_type': 'sorting',
        'payload': {
          'categories': ['Toleran', 'Intoleran'],
        },
      };

      final node = LearningNode.fromJson(json);

      expect(node.isChallenge, true);
      expect(node.gameType, 'sorting');
      expect(node.payload?['categories'], ['Toleran', 'Intoleran']);
      expect(node.isCompleted, false);
    });

    test('NodeCompleteResult parsing', () {
      final json = {
        'node_id': 5,
        'is_correct': true,
        'board_progress_percent': 65,
      };

      final result = NodeCompleteResult.fromJson(json);

      expect(result.nodeId, 5);
      expect(result.isCorrect, true);
      expect(result.boardProgressPercent, 65);
    });
  });

  group('Riverpod Providers Tests', () {
    test('learningBoardProvider loads data correctly from service', () async {
      final mockNode = LearningNode(
        id: 1,
        materialId: 10,
        orderIndex: 1,
        nodeType: 'content',
        title: 'Materi',
      );

      final container = ProviderContainer(
        overrides: [
          materialServiceProvider.overrideWithValue(
            MockMaterialService(mockNodes: [mockNode]),
          ),
        ],
      );

      addTearDown(container.dispose);

      final board = await container.read(learningBoardProvider(10).future);
      expect(board.length, 1);
      expect(board.first.title, 'Materi');
      expect(board.first.id, 1);
    });

    test('pendingSocialChallengesProvider loads data correctly from service', () async {
      final mockLog = ActivityLog(
        id: 100,
        studentId: 5,
        title: 'Aktivitas Toleransi',
        category: 'social_engagement',
        location: 'Rumah ibadah',
        activityDate: DateTime.now(),
      );

      final container = ProviderContainer(
        overrides: [
          teacherServiceProvider.overrideWithValue(
            MockTeacherService(mockPending: [mockLog]),
          ),
        ],
      );

      addTearDown(container.dispose);

      final list = await container.read(pendingSocialChallengesProvider.future);
      expect(list.length, 1);
      expect(list.first.id, 100);
      expect(list.first.category, 'social_engagement');
    });
  });
}
