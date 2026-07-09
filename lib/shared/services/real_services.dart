import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/network/network.dart';
import 'data_models.dart';
import 'service_interfaces.dart';

// =============================================================================
// REAL API IMPLEMENTATIONS
// =============================================================================

class RealMaterialService implements MaterialServiceInterface {
  final ApiClient _client;

  RealMaterialService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  @override
  Future<List<LearningMaterial>> getMaterials({
    String? gradeCategory,
    int? gradeLevel,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (gradeCategory != null) {
        queryParams['grade_category'] = gradeCategory;
      }
      if (gradeLevel != null) {
        queryParams['grade_level'] = gradeLevel;
      }

      final response = await _client.get(
        ApiConstants.materials,
        queryParameters: queryParams,
      );

      final data = response.data;
      final List<dynamic> list;
      if (data is Map && data.containsKey('data')) {
        list = data['data'] as List<dynamic>;
      } else if (data is List) {
        list = data;
      } else {
        list = [];
      }

      return list
          .map((m) => LearningMaterial.fromJson(m as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<LearningMaterial?> getMaterial(int id) async {
    try {
      final response = await _client.get('${ApiConstants.materials}/$id');
      final data = response.data;
      final Map<String, dynamic> item =
          (data is Map && data.containsKey('data')) ? data['data'] : data;
      return LearningMaterial.fromJson(item);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<Question>> getQuestions(int materialId, String type) async {
    try {
      final response = await _client.get(
        '${ApiConstants.materials}/$materialId/questions',
        queryParameters: {'type': type},
      );

      final data = response.data;
      final List<dynamic> list;
      if (data is Map && data.containsKey('data')) {
        list = data['data'] as List<dynamic>;
      } else if (data is List) {
        list = data;
      } else {
        list = [];
      }

      return list
          .map((q) => Question.fromJson(q as Map<String, dynamic>,
              materialId: materialId, type: type))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<PulseStatement>> getPulseStatements(int materialId) async {
    try {
      final response = await _client.get(
        '${ApiConstants.materials}/$materialId/pulse-statements',
      );

      final data = response.data;
      final List<dynamic> list;
      if (data is Map && data.containsKey('data')) {
        list = data['data'] as List<dynamic>;
      } else if (data is List) {
        list = data;
      } else {
        list = [];
      }

      return list
          .map((s) => PulseStatement.fromJson(s as Map<String, dynamic>,
              materialId: materialId))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> submitTestResponse({
    required int materialId,
    required String type,
    required List<Map<String, dynamic>> answers,
  }) async {
    try {
      final response = await _client.post(
        '${ApiConstants.materials}/$materialId/test-response',
        data: {
          'type': type,
          'answers': answers,
        },
      );
      final data = response.data;
      return (data is Map && data.containsKey('data')) ? data['data'] : data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> submitPulseResponse({
    required int materialId,
    required List<Map<String, dynamic>> responses,
  }) async {
    try {
      final response = await _client.post(
        '${ApiConstants.materials}/$materialId/pulse-response',
        data: {
          'responses': responses,
        },
      );
      final data = response.data;
      return (data is Map && data.containsKey('data')) ? data['data'] : data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<LearningNode>> getLearningBoard(int materialId) async {
    try {
      final response = await _client.get(
        '${ApiConstants.materials}/$materialId/learning-board',
      );
      final data = response.data;
      final boardData = (data is Map && data.containsKey('data')) ? data['data'] : data;
      final List<dynamic> nodes = (boardData is Map && boardData.containsKey('nodes'))
          ? boardData['nodes'] as List<dynamic>
          : (boardData is List ? boardData : []);
      return nodes
          .map((n) => LearningNode.fromJson(n as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<NodeCompleteResult> completeNode({
    required int materialId,
    required int nodeId,
    required Map<String, dynamic> submittedAnswer,
    bool? isCorrect,
    int? score,
  }) async {
    try {
      final requestData = <String, dynamic>{
        'submitted_answer': submittedAnswer,
      };
      if (isCorrect != null) {
        requestData['is_correct'] = isCorrect;
      }
      if (score != null) {
        requestData['score'] = score;
      }
      final response = await _client.post(
        '${ApiConstants.materials}/$materialId/learning-board/nodes/$nodeId/complete',
        data: requestData,
      );
      final data = response.data;
      final resultData = (data is Map && data.containsKey('data')) ? data['data'] : data;
      return NodeCompleteResult.fromJson(resultData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> submitSocialTask({
    required int materialId,
    required int nodeId,
    required String caption,
    String? photoPath,
  }) async {
    try {
      final formData = <String, dynamic>{'caption': caption};
      if (photoPath != null) {
        formData['photo'] = await MultipartFile.fromFile(photoPath);
      }
      final response = await _client.post(
        '${ApiConstants.materials}/$materialId/learning-board/nodes/$nodeId/social-task',
        data: FormData.fromMap(formData),
      );
      final data = response.data;
      return (data is Map && data.containsKey('data')) ? data['data'] : data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> completeMedia(int materialId) async {
    try {
      await _client.post(
        '${ApiConstants.materials}/$materialId/complete-media',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<LearningMaterial>> getClassMaterials(int classId) async {
    try {
      final response = await _client.get('/classes/$classId/materials');
      final data = response.data;
      final List<dynamic> list;
      if (data is Map && data.containsKey('data')) {
        list = data['data'] as List<dynamic>;
      } else if (data is List) {
        list = data;
      } else {
        list = [];
      }
      return list
          .map((m) => LearningMaterial.fromJson(m as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<LearningMaterial> addClassMaterial({
    required int classId,
    required String title,
    String? description,
    String? filePath,
    String? audioPath,
    int? templateId,
  }) async {
    try {
      final Map<String, dynamic> fields = {
        'title': title,
        'description': description ?? '',
        'activity_type': 'learning_board',
      };
      if (templateId != null) {
        fields['template_id'] = templateId;
      }

      if (filePath != null) {
        fields['file'] = await MultipartFile.fromFile(filePath);
      }
      if (audioPath != null) {
        fields['audio'] = await MultipartFile.fromFile(audioPath);
      }

      final formData = FormData.fromMap(fields);

      final response = await _client.post(
        '/classes/$classId/materials',
        data: formData,
      );
      final data = response.data;
      final resultData = (data is Map && data.containsKey('data')) ? data['data'] : data;
      return LearningMaterial.fromJson(resultData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<LearningMaterial> updateClassMaterial(
    int materialId, {
    required String title,
    String? description,
    String? filePath,
    String? audioPath,
  }) async {
    try {
      final Map<String, dynamic> fields = {
        'title': title,
        'description': description ?? '',
        '_method': 'PATCH',
      };

      if (filePath != null) {
        fields['file'] = await MultipartFile.fromFile(filePath);
      }
      if (audioPath != null) {
        fields['audio'] = await MultipartFile.fromFile(audioPath);
      }

      final formData = FormData.fromMap(fields);

      // We use POST with _method=PATCH because PHP doesn't parse multipart form data natively in PUT/PATCH requests
      final response = await _client.post(
        '${ApiConstants.materials}/$materialId',
        data: formData,
      );
      final data = response.data;
      final resultData = (data is Map && data.containsKey('data')) ? data['data'] : data;
      return LearningMaterial.fromJson(resultData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> deleteClassMaterial(int materialId) async {
    try {
      await _client.delete('${ApiConstants.materials}/$materialId');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Question> createQuestion({
    required int materialId,
    required String type,
    required String questionText,
    required List<String> options,
    required String correctAnswer,
  }) async {
    try {
      final response = await _client.post(
        '/questions',
        data: {
          'learning_material_id': materialId,
          'type': type,
          'question_text': questionText,
          'options': options,
          'correct_answer': correctAnswer,
        },
      );
      final data = response.data;
      final resultData = (data is Map && data.containsKey('data')) ? data['data'] : data;
      return Question.fromJson(resultData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Question> updateQuestion(
    int questionId, {
    String? questionText,
    List<String>? options,
    String? correctAnswer,
  }) async {
    try {
      final Map<String, dynamic> dataPayload = {};
      if (questionText != null) dataPayload['question_text'] = questionText;
      if (options != null) dataPayload['options'] = options;
      if (correctAnswer != null) dataPayload['correct_answer'] = correctAnswer;

      final response = await _client.patch(
        '/questions/$questionId',
        data: dataPayload,
      );
      final data = response.data;
      final resultData = (data is Map && data.containsKey('data')) ? data['data'] : data;
      return Question.fromJson(resultData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> deleteQuestion(int questionId) async {
    try {
      await _client.delete('/questions/$questionId');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

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
    try {
      final response = await _client.post(
        '/learning-nodes',
        data: {
          'learning_material_id': materialId,
          'node_type': nodeType,
          'title': title,
          'body': body,
          'game_type': gameType,
          'payload': payload,
          'order_index': orderIndex ?? 0,
        },
      );
      final data = response.data;
      final resultData = (data is Map && data.containsKey('data')) ? data['data'] : data;
      return LearningNode.fromJson(resultData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
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
    try {
      final Map<String, dynamic> dataPayload = {};
      if (nodeType != null) dataPayload['node_type'] = nodeType;
      if (title != null) dataPayload['title'] = title;
      if (body != null) dataPayload['body'] = body;
      if (gameType != null) dataPayload['game_type'] = gameType;
      if (payload != null) dataPayload['payload'] = payload;
      if (orderIndex != null) dataPayload['order_index'] = orderIndex;

      final response = await _client.patch(
        '/learning-nodes/$nodeId',
        data: dataPayload,
      );
      final data = response.data;
      final resultData = (data is Map && data.containsKey('data')) ? data['data'] : data;
      return LearningNode.fromJson(resultData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> deleteLearningNode(int nodeId) async {
    try {
      await _client.delete('/learning-nodes/$nodeId');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMaterialTemplates() async {
    try {
      final response = await _client.get('/material-templates');
      final data = response.data;
      final List<dynamic> list;
      if (data is Map && data.containsKey('data')) {
        list = data['data'] as List<dynamic>;
      } else if (data is List) {
        list = data;
      } else {
        list = [];
      }
      return list.map((t) => Map<String, dynamic>.from(t as Map)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<LearningMaterial> importMaterialTemplate({
    required int classId,
    required int templateId,
  }) async {
    try {
      final response = await _client.post(
        '/classes/$classId/materials/import-template',
        data: {
          'template_id': templateId,
        },
      );
      final data = response.data;
      final resultData = (data is Map && data.containsKey('data')) ? data['data'] : data;
      return LearningMaterial.fromJson(resultData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<LearningMaterial> duplicateMaterial({
    required int materialId,
    required int targetClassId,
  }) async {
    try {
      final response = await _client.post(
        '${ApiConstants.materials}/$materialId/duplicate',
        data: {
          'class_id': targetClassId,
        },
      );
      final data = response.data;
      final resultData = (data is Map && data.containsKey('data')) ? data['data'] : data;
      return LearningMaterial.fromJson(resultData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

class RealClassService implements ClassServiceInterface {
  final ApiClient _client;

  RealClassService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  @override
  Future<List<StudentClass>> getStudentClasses(int studentId) async {
    try {
      final response = await _client.get('${ApiConstants.students}/$studentId');
      final data = response.data;
      final studentData = (data is Map && data.containsKey('data')) ? data['data'] : data;

      if (studentData is Map && studentData.containsKey('classes')) {
        final List<dynamic> classesList = studentData['classes'] as List<dynamic>;
        return classesList
            .map((c) => StudentClass.fromJson(c as Map<String, dynamic>))
            .toList();
      }

      if (studentData is Map && studentData.containsKey('class')) {
        final classData = studentData['class'];
        if (classData != null) {
          return [StudentClass.fromJson(classData as Map<String, dynamic>)];
        }
      }

      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<String?> joinClass(String classCode) async {
    try {
      debugPrint('[JOIN CLASS] Sending POST ${ApiConstants.joinClass} with class_code: $classCode');
      final response = await _client.post(
        ApiConstants.joinClass,
        data: {'class_code': classCode},
      );
      debugPrint('[JOIN CLASS] Response status: ${response.statusCode}');
      debugPrint('[JOIN CLASS] Response data: ${response.data}');
      final data = response.data;
      final resData = (data is Map && data.containsKey('data')) ? data['data'] : data;
      return resData['class_code'] as String? ?? classCode;
    } on DioException catch (e) {
      debugPrint('[JOIN CLASS] DioException: ${e.type} - ${e.response?.statusCode}');
      debugPrint('[JOIN CLASS] Error response: ${e.response?.data}');

      // If the /classes/join endpoint is not implemented (404/405),
      // fall back to finding the class by code and updating student record
      final statusCode = e.response?.statusCode;
      if (statusCode == 404 || statusCode == 405) {
        debugPrint('[JOIN CLASS] Endpoint not available, trying fallback...');
        return _joinClassFallback(classCode);
      }

      throw ApiException.fromDioException(e);
    }
  }

  /// Fallback: find the class by its code, then assign the student to it
  /// by updating the student's class_id via PATCH /students/{id}
  Future<String?> _joinClassFallback(String classCode) async {
    try {
      // Step 1: Search for the class by code
      debugPrint('[JOIN CLASS FALLBACK] Searching for class with code: $classCode');
      final classesResponse = await _client.get(
        ApiConstants.classes,
        queryParameters: {'search': classCode},
      );
      final classesData = classesResponse.data;
      final List<dynamic> classList;
      if (classesData is Map && classesData.containsKey('data')) {
        classList = classesData['data'] as List<dynamic>;
      } else if (classesData is List) {
        classList = classesData;
      } else {
        classList = [];
      }

      // Find the class with matching class_code
      Map<String, dynamic>? targetClass;
      for (final c in classList) {
        if (c is Map<String, dynamic> && c['class_code'] == classCode) {
          targetClass = c;
          break;
        }
      }

      if (targetClass == null) {
        debugPrint('[JOIN CLASS FALLBACK] Class not found with code: $classCode');
        throw ApiException(
          message: 'Kode kelas tidak ditemukan',
          statusCode: 404,
        );
      }

      final classId = targetClass['id'] as int;
      debugPrint('[JOIN CLASS FALLBACK] Found class ID: $classId for code: $classCode');

      // Step 2: Get the current authenticated user to find the student ID
      final userResponse = await _client.get(ApiConstants.user);
      final userData = userResponse.data;
      final userInfo = (userData is Map && userData.containsKey('data'))
          ? userData['data']
          : userData;
      final studentId = userInfo['id'] as int;
      debugPrint('[JOIN CLASS FALLBACK] Student ID: $studentId');

      // Step 3: Update the student's class_id
      await _client.patch(
        '${ApiConstants.students}/$studentId',
        data: {'class_id': classId},
      );
      debugPrint('[JOIN CLASS FALLBACK] Successfully assigned student $studentId to class $classId');

      return classCode;
    } on DioException catch (e) {
      debugPrint('[JOIN CLASS FALLBACK] Failed: ${e.type} - ${e.response?.statusCode}');
      debugPrint('[JOIN CLASS FALLBACK] Error: ${e.response?.data}');
      throw ApiException.fromDioException(e);
    }
  }
}

class RealActivityService implements ActivityServiceInterface {
  final ApiClient _client;

  RealActivityService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  @override
  Future<List<ActivityLog>> getActivities(int studentId) async {
    try {
      final response = await _client.get(
        ApiConstants.activities,
        queryParameters: {
          'filter[student_id]': studentId,
        },
      );
      final data = response.data;
      final List<dynamic> list;
      if (data is Map && data.containsKey('data')) {
        list = data['data'] as List<dynamic>;
      } else if (data is List) {
        list = data;
      } else {
        list = [];
      }

      return list
          .map((a) => ActivityLog.fromJson(a as Map<String, dynamic>, studentId: studentId))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<ActivityLog?> getActivity(int activityId) async {
    try {
      final response = await _client.get('${ApiConstants.activities}/$activityId');
      final data = response.data;
      final Map<String, dynamic> item =
          (data is Map && data.containsKey('data')) ? data['data'] as Map<String, dynamic> : data as Map<String, dynamic>;
      return ActivityLog.fromJson(item);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<ActivityLog> createActivity({
    required int studentId,
    required String title,
    required String category,
    required String location,
    required DateTime activityDate,
    String? photoPath,
  }) async {
    try {
      String mappedType;
      switch (category) {
        case 'participation':
          mappedType = 'sports';
          break;
        case 'understanding':
          mappedType = 'arts';
          break;
        case 'learning':
          mappedType = 'competition';
          break;
        case 'social_engagement':
          mappedType = 'volunteer';
          break;
        default:
          mappedType = 'other';
      }

      final Map<String, dynamic> fields = {
        'student_id': studentId,
        'title': title,
        'type': mappedType,
        'location': location,
        'date': activityDate.toIso8601String().split('T')[0],
      };

      final Response response;
      if (photoPath != null && photoPath.isNotEmpty) {
        final formData = FormData.fromMap({
          ...fields,
          'evidence_file': await MultipartFile.fromFile(
            photoPath,
            filename: photoPath.split('/').last,
          ),
        });
        response = await _client.uploadFile(ApiConstants.activities, data: formData);
      } else {
        response = await _client.post(ApiConstants.activities, data: fields);
      }

      final data = response.data;
      final Map<String, dynamic> item =
          (data is Map && data.containsKey('data')) ? data['data'] : data;
      return ActivityLog.fromJson(item, studentId: studentId);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<ActivityLog> updateActivity({
    required int activityId,
    required String title,
    required String category,
    required String location,
    required DateTime activityDate,
    String? photoPath,
  }) async {
    try {
      String mappedType;
      switch (category) {
        case 'participation':
          mappedType = 'sports';
          break;
        case 'understanding':
          mappedType = 'arts';
          break;
        case 'learning':
          mappedType = 'competition';
          break;
        case 'social_engagement':
          mappedType = 'volunteer';
          break;
        default:
          mappedType = 'other';
      }

      final Map<String, dynamic> fields = {
        'title': title,
        'type': mappedType,
        'location': location,
        'date': activityDate.toIso8601String().split('T')[0],
      };

      final Response response;
      if (photoPath != null && photoPath.isNotEmpty) {
        final formData = FormData.fromMap({
          ...fields,
          '_method': 'PATCH',
          'evidence_file': await MultipartFile.fromFile(
            photoPath,
            filename: photoPath.split('/').last,
          ),
        });
        response = await _client.uploadFile('${ApiConstants.activities}/$activityId', data: formData);
      } else {
        response = await _client.patch('${ApiConstants.activities}/$activityId', data: fields);
      }

      final data = response.data;
      final Map<String, dynamic> item =
          (data is Map && data.containsKey('data')) ? data['data'] : data;
      return ActivityLog.fromJson(item);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> deleteActivity(int activityId) async {
    try {
      await _client.delete('${ApiConstants.activities}/$activityId');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

class RealAnalyticsService implements AnalyticsServiceInterface {
  final ApiClient _client;

  RealAnalyticsService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  @override
  Future<PulseScores> getPulseScores(int studentId) async {
    try {
      final response = await _client.get(ApiConstants.dashboardAnalytics);
      final data = response.data;
      final Map<String, dynamic> stats =
          (data is Map && data.containsKey('data')) ? data['data'] : data;

      if (stats.containsKey('pulse_scores')) {
        return PulseScores.fromJson(stats['pulse_scores'] as Map<String, dynamic>);
      }
      return PulseScores.fromJson(stats);
    } on DioException catch (e) {
      // If analytics endpoint returns 404 or error, return default zero scores
      if (e.response?.statusCode == 404 || e.response?.statusCode == 403) {
        return const PulseScores(
          participation: 0.0,
          understanding: 0.0,
          learning: 0.0,
          socialEngagement: 0.0,
        );
      }
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<StudentProgress>> getProgress(int studentId) async {
    try {
      final response = await _client.get(ApiConstants.materials);
      final data = response.data;
      final List<dynamic> list;
      if (data is Map && data.containsKey('data')) {
        list = data['data'] as List<dynamic>;
      } else if (data is List) {
        list = data;
      } else {
        list = [];
      }

      return list
          .map((m) => StudentProgress.fromJson(m as Map<String, dynamic>, studentId))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

class RealTeacherService implements TeacherServiceInterface {
  final ApiClient _client;

  RealTeacherService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  @override
  Future<List<TeacherClass>> getTeacherClasses(int teacherId) async {
    try {
      final response = await _client.get(
        ApiConstants.classes,
        queryParameters: {'filter[homeroom_teacher_id]': teacherId},
      );
      final data = response.data;
      final List<dynamic> list;
      if (data is Map && data.containsKey('data')) {
        list = data['data'] as List<dynamic>;
      } else if (data is List) {
        list = data;
      } else {
        list = [];
      }

      return list
          .map((c) => TeacherClass.fromListJson(c as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<TeacherClass?> getClassDetail(int classId) async {
    try {
      final response = await _client.get('${ApiConstants.classes}/$classId');
      final data = response.data;
      final Map<String, dynamic> item =
          (data is Map && data.containsKey('data')) ? data['data'] : data;
      return TeacherClass.fromJson(item);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<ClassStudent>> getClassStudents(int classId) async {
    try {
      final String path = '/dashboard/teacher/classes/$classId/recapitulation';
      try {
        final response = await _client.get(path);
        final data = response.data;
        final List<dynamic> list;
        if (data is Map && data.containsKey('data')) {
          final resData = data['data'];
          if (resData is List) {
            list = resData;
          } else if (resData is Map && resData.containsKey('students')) {
            list = resData['students'] as List<dynamic>;
          } else {
            list = [];
          }
        } else if (data is List) {
          list = data;
        } else {
          list = [];
        }
        return list
            .map((s) => ClassStudent.fromJson(s as Map<String, dynamic>))
            .toList();
      } catch (_) {
        try {
          final response = await _client.get('${ApiConstants.classes}/$classId/students');
          final data = response.data;
          final List<dynamic> list;
          if (data is Map && data.containsKey('data')) {
            list = data['data'] as List<dynamic>;
          } else if (data is List) {
            list = data;
          } else {
            list = [];
          }
          return list
              .map((s) => ClassStudent.fromJson(s as Map<String, dynamic>))
              .toList();
        } catch (_) {
          final response = await _client.get(
            ApiConstants.students,
            queryParameters: {'filter[class_id]': classId},
          );
          final data = response.data;
          final List<dynamic> list;
          if (data is Map && data.containsKey('data')) {
            list = data['data'] as List<dynamic>;
          } else if (data is List) {
            list = data;
          } else {
            list = [];
          }
          return list
              .map((s) => ClassStudent.fromJson(s as Map<String, dynamic>))
              .toList();
        }
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<AnecdotalNote>> getAnecdotalNotes(int studentId) async {
    try {
      final String path = '${ApiConstants.students}/$studentId/anecdotal-notes';
      try {
        final response = await _client.get(path);
        final data = response.data;
        final List<dynamic> list;
        if (data is Map && data.containsKey('data')) {
          list = data['data'] as List<dynamic>;
        } else if (data is List) {
          list = data;
        } else {
          list = [];
        }
        return list
            .map((n) => AnecdotalNote.fromJson(n as Map<String, dynamic>, studentId))
            .toList();
      } catch (_) {
        final response = await _client.get('${ApiConstants.students}/$studentId');
        final data = response.data;
        final studentData = (data is Map && data.containsKey('data')) ? data['data'] : data;
        if (studentData is Map && studentData.containsKey('anecdotal_notes')) {
          final List<dynamic> notesList = studentData['anecdotal_notes'] as List<dynamic>;
          return notesList
              .map((n) => AnecdotalNote.fromJson(n as Map<String, dynamic>, studentId))
              .toList();
        }
        return [];
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<AnecdotalNote> createAnecdotalNote({
    required int studentId,
    required String content,
    required String dimension,
  }) async {
    try {
      final response = await _client.post(
        '${ApiConstants.students}/$studentId/anecdotal-notes',
        data: {
          'content': content,
          'category': dimension,
        },
      );
      final data = response.data;
      final Map<String, dynamic> item =
          (data is Map && data.containsKey('data')) ? data['data'] : data;
      return AnecdotalNote.fromJson(item, studentId);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> deleteAnecdotalNote(int noteId) async {
    try {
      await _client.delete('/anecdotal-notes/$noteId');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<String> createClass({
    required String name,
    required String gradeCategory,
    required int gradeLevel,
    int? homeroomTeacherId,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.classes,
        data: {
          'name': name,
          'grade': gradeLevel,
          'grade_category': gradeCategory,
          'grade_level': gradeLevel,
          'homeroom_teacher_id': homeroomTeacherId,
        },
      );
      final data = response.data;
      final resData = (data is Map && data.containsKey('data')) ? data['data'] : data;
      return resData['class_code'] as String? ?? '';
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> deleteClass(int classId) async {
    try {
      await _client.delete('${ApiConstants.classes}/$classId');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getStudentPulseScores(int studentId) async {
    try {
      final response = await _client.get(
        '${ApiConstants.students}/$studentId/pulse-scores',
      );
      final data = response.data;
      return (data is Map && data.containsKey('data'))
          ? data['data'] as Map<String, dynamic>
          : data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return {
          'pulse_scores': {
            'participation': 0.0,
            'understanding': 0.0,
            'learning': 0.0,
            'social_engagement': 0.0,
          },
          'test_scores': [],
        };
      }
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getTeacherStats() async {
    try {
      final response = await _client.get('/teachers/me/stats');
      final data = response.data;
      return (data is Map && data.containsKey('data'))
          ? data['data'] as Map<String, dynamic>
          : data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return {
          'classes_count': 0,
          'students_count': 0,
          'anecdotal_notes_count': 0,
        };
      }
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<ActivityLog>> getPendingSocialChallenges() async {
    try {
      final response = await _client.get(
        '/teacher/social-challenges',
        queryParameters: {'status': 'pending'},
      );
      final data = response.data;
      final List<dynamic> list;
      if (data is Map && data.containsKey('data')) {
        list = data['data'] as List<dynamic>;
      } else if (data is List) {
        list = data;
      } else {
        list = [];
      }
      return list
          .map((item) => ActivityLog.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> reviewSocialChallenge({
    required int activityId,
    required String status,
    required int score,
    String? note,
  }) async {
    try {
      final response = await _client.post(
        '/activities/$activityId/review',
        data: {
          'review_status': status,
          'teacher_score': score,
          if (note != null) 'note': note,
        },
      );
      final data = response.data;
      return (data is Map && data.containsKey('data'))
          ? data['data'] as Map<String, dynamic>
          : data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
