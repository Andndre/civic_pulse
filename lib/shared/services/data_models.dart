import 'dart:convert';

class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
  });

  bool get isStudent => role == 'student';
  bool get isTeacher => role == 'teacher';
  bool get isAdmin => role == 'admin';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'student',
      avatarUrl: _resolvePhotoUrl(
        json['avatar_url'] as String? ?? json['avatar'] as String?,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'avatar_url': avatarUrl,
    };
  }
}

class AuthResponse {
  final String token;
  final User user;
  final String? classCode;

  const AuthResponse({required this.token, required this.user, this.classCode});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return AuthResponse(
      token: data['token'] as String? ?? '',
      user: User.fromJson(data['user'] as Map<String, dynamic>? ?? {}),
      classCode: data['class_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'user': user.toJson(), 'class_code': classCode};
  }
}

class LearningMaterial {
  final int id;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final String? fileUrl;
  final String? audioUrl;
  final String gradeCategory;
  final int gradeLevel;
  final int? estimatedDuration;
  final int orderIndex;
  final String status;
  final int? preTestScore;
  final int? postTestScore;
  // Learning Board fields (Fase 3)
  final String activityType; // 'classic_pdf' | 'learning_board'
  final String boardStatus; // 'not_started' | 'in_progress' | 'completed'
  final String socialEngagementStatus; // 'not_submitted' | 'pending_review' | 'finalized'
  final String ebookStatus; // 'locked' | 'available' | 'completed'

  const LearningMaterial({
    required this.id,
    required this.title,
    this.description,
    this.thumbnailUrl,
    this.fileUrl,
    this.audioUrl,
    required this.gradeCategory,
    required this.gradeLevel,
    this.estimatedDuration,
    required this.orderIndex,
    required this.status,
    this.preTestScore,
    this.postTestScore,
    this.activityType = 'classic_pdf',
    this.boardStatus = 'not_started',
    this.socialEngagementStatus = 'not_submitted',
    this.ebookStatus = 'locked',
  });

  bool get isLearningBoard => activityType == 'learning_board';

  factory LearningMaterial.fromJson(Map<String, dynamic> json) {
    final studentScore = json['student_score'] as Map<String, dynamic>?;
    final pathStatus = json['learning_path_status'] as Map<String, dynamic>?;
    return LearningMaterial(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      thumbnailUrl:
          json['thumbnail_url'] as String? ?? json['thumbnail'] as String?,
      fileUrl: _resolvePhotoUrl(json['file_url'] as String?),
      audioUrl: _resolvePhotoUrl(json['audio_url'] as String?),
      gradeCategory: json['grade_category'] as String? ?? 'SMP',
      gradeLevel: _parseGradeLevel(json['grade_level'] ?? json['grade']),
      estimatedDuration:
          json['estimated_duration_minutes'] as int? ??
          json['estimated_duration'] as int?,
      orderIndex: json['order_index'] as int? ?? json['order'] as int? ?? 1,
      status: json['status'] as String? ?? 'locked',
      preTestScore: studentScore?['pre_test_score'] as int?,
      postTestScore: studentScore?['post_test_score'] as int?,
      activityType: json['activity_type'] as String? ?? 'classic_pdf',
      boardStatus: pathStatus?['board'] as String? ?? json['board_status'] as String? ?? 'not_started',
      socialEngagementStatus: pathStatus?['social_engagement'] as String? ?? json['social_engagement_status'] as String? ?? 'not_submitted',
      ebookStatus: pathStatus?['ebook'] as String? ?? json['ebook_status'] as String? ?? 'locked',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'file_url': fileUrl,
      'audio_url': audioUrl,
      'grade_category': gradeCategory,
      'grade_level': gradeLevel,
      'estimated_duration_minutes': estimatedDuration,
      'order_index': orderIndex,
      'status': status,
      'pre_test_score': preTestScore,
      'post_test_score': postTestScore,
      'activity_type': activityType,
      'board_status': boardStatus,
      'social_engagement_status': socialEngagementStatus,
      'ebook_status': ebookStatus,
    };
  }
}

class Question {
  final int id;
  final int materialId;
  final String type; // 'pre' or 'post'
  final int questionNumber;
  final String content;
  final Map<String, String> options;
  final String correctAnswer;

  const Question({
    required this.id,
    required this.materialId,
    required this.type,
    required this.questionNumber,
    required this.content,
    required this.options,
    required this.correctAnswer,
  });

  factory Question.fromJson(
    Map<String, dynamic> json, {
    int? materialId,
    String? type,
  }) {
    final Map<String, String> parsedOptions = {};
    if (json['options'] is Map) {
      (json['options'] as Map).forEach((key, value) {
        parsedOptions[key.toString()] = value.toString();
      });
    }
    return Question(
      id: json['id'] as int? ?? 0,
      materialId: json['material_id'] as int? ?? materialId ?? 0,
      type: json['type'] as String? ?? type ?? 'pre',
      questionNumber:
          json['question_number'] as int? ?? json['number'] as int? ?? 1,
      content: json['content'] as String? ?? '',
      options: parsedOptions,
      correctAnswer:
          json['correct_answer'] as String? ??
          json['correctAnswer'] as String? ??
          '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'material_id': materialId,
      'type': type,
      'question_number': questionNumber,
      'content': content,
      'options': options,
      'correct_answer': correctAnswer,
    };
  }
}

class PulseStatement {
  final int id;
  final int materialId;
  final String dimension;
  final String statement;
  final int orderIndex;
  final int? score;

  const PulseStatement({
    required this.id,
    required this.materialId,
    required this.dimension,
    required this.statement,
    required this.orderIndex,
    this.score,
  });

  factory PulseStatement.fromJson(
    Map<String, dynamic> json, {
    int? materialId,
  }) {
    return PulseStatement(
      id: json['id'] as int? ?? 0,
      materialId: json['material_id'] as int? ?? materialId ?? 0,
      dimension: json['dimension'] as String? ?? 'participation',
      statement: json['statement'] as String? ?? '',
      orderIndex: json['order_index'] as int? ?? json['id'] as int? ?? 1,
      score: json['score'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'material_id': materialId,
      'dimension': dimension,
      'statement': statement,
      'order_index': orderIndex,
      'score': score,
    };
  }
}

class StudentClass {
  final int id;
  final String name;
  final String gradeCategory;
  final int gradeLevel;
  final String classCode;
  final int teacherId;
  final String teacherName;

  const StudentClass({
    required this.id,
    required this.name,
    required this.gradeCategory,
    required this.gradeLevel,
    required this.classCode,
    required this.teacherId,
    required this.teacherName,
  });

  factory StudentClass.fromJson(Map<String, dynamic> json) {
    final teacherJson = json['teacher'] as Map<String, dynamic>?;
    return StudentClass(
      id: json['id'] as int? ?? json['class_id'] as int? ?? 0,
      name: json['name'] as String? ?? json['class_name'] as String? ?? '',
      gradeCategory: json['grade_category'] as String? ?? 'SMP',
      gradeLevel: _parseGradeLevel(json['grade_level'] ?? json['grade']),
      classCode: json['class_code'] as String? ?? '',
      teacherId: teacherJson != null
          ? teacherJson['id'] as int? ?? 0
          : json['teacher_id'] as int? ?? 0,
      teacherName: teacherJson != null
          ? teacherJson['name'] as String? ?? ''
          : json['teacher_name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'grade_category': gradeCategory,
      'grade_level': gradeLevel,
      'class_code': classCode,
      'teacher_id': teacherId,
      'teacher_name': teacherName,
    };
  }
}

class ActivityLog {
  final int id;
  final int studentId;
  final String? studentName;
  final String title;
  final String category;
  final String location;
  final String description;
  final DateTime activityDate;
  final String? photoUrl;
  // Social Challenge fields (Fase 3)
  final int? materialId;
  final int? nodeId;
  final String? reviewStatus; // 'pending' | 'approved' | 'rejected'
  final int? teacherScore; // 1-5

  const ActivityLog({
    required this.id,
    required this.studentId,
    this.studentName,
    required this.title,
    required this.category,
    required this.location,
    this.description = '',
    required this.activityDate,
    this.photoUrl,
    this.materialId,
    this.nodeId,
    this.reviewStatus,
    this.teacherScore,
  });

  bool get isSocialChallenge => materialId != null;
  bool get isPendingReview => reviewStatus == 'pending';

  factory ActivityLog.fromJson(Map<String, dynamic> json, {int? studentId}) {
    String getCategoryFromType(String? type) {
      if (type == null) return 'participation';
      switch (type) {
        case 'sports':
          return 'participation';
        case 'arts':
          return 'understanding';
        case 'competition':
          return 'learning';
        case 'volunteer':
          return 'social_engagement';
        case 'participation':
        case 'understanding':
        case 'learning':
        case 'social_engagement':
          return type;
        default:
          return 'participation';
      }
    }

    final rawCategory = json['category'] as String? ?? json['type'] as String?;

    int parseId(dynamic val) {
      if (val is int) return val;
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return ActivityLog(
      id: parseId(json['id']),
      studentId:
          parseId((json['student'] as Map?)?['id']) != 0
              ? parseId((json['student'] as Map?)?['id'])
              : parseId(json['student_id']) != 0
                  ? parseId(json['student_id'])
                  : studentId ?? 0,
      studentName: (json['student'] as Map?)?['name'] as String?,
      title: json['title'] as String? ?? '',
      category: getCategoryFromType(rawCategory),
      location: json['location'] as String? ?? 'sekolah',
      description: json['description'] as String? ?? '',
      activityDate: DateTime.parse(
        json['date'] as String? ??
            json['activity_date'] as String? ??
            DateTime.now().toIso8601String(),
      ),
      photoUrl: _resolvePhotoUrl(
        json['evidence_url'] as String? ??
            json['photo_url'] as String? ??
            json['photo'] as String?,
      ),
      materialId: json['material_id'] as int?,
      nodeId: json['node_id'] as int?,
      reviewStatus: json['review_status'] as String?,
      teacherScore: json['teacher_score'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'student_name': studentName,
      'title': title,
      'category': category,
      'location': location,
      'description': description,
      'activity_date': activityDate.toIso8601String(),
      'photo_url': photoUrl,
      'material_id': materialId,
      'node_id': nodeId,
      'review_status': reviewStatus,
      'teacher_score': teacherScore,
    };
  }
}

class PulseScores {
  final double participation;
  final double understanding;
  final double learning;
  final double socialEngagement;

  const PulseScores({
    required this.participation,
    required this.understanding,
    required this.learning,
    required this.socialEngagement,
  });

  double get overall =>
      (participation + understanding + learning + socialEngagement) / 4;

  factory PulseScores.fromJson(Map<String, dynamic> json) {
    return PulseScores(
      participation: (json['participation'] as num?)?.toDouble() ?? 0.0,
      understanding: (json['understanding'] as num?)?.toDouble() ?? 0.0,
      learning: (json['learning'] as num?)?.toDouble() ?? 0.0,
      socialEngagement:
          (json['social_engagement'] as num?)?.toDouble() ??
          json['socialEngagement'] as double? ??
          0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participation': participation,
      'understanding': understanding,
      'learning': learning,
      'social_engagement': socialEngagement,
    };
  }
}

class StudentProgress {
  final int studentId;
  final int materialId;
  final String preTestStatus;
  final int? preTestScore;
  final String ebookStatus;
  final String postTestStatus;
  final int? postTestScore;
  final String pulseStatus;
  final int? pulseScore;

  const StudentProgress({
    required this.studentId,
    required this.materialId,
    required this.preTestStatus,
    this.preTestScore,
    required this.ebookStatus,
    required this.postTestStatus,
    this.postTestScore,
    required this.pulseStatus,
    this.pulseScore,
  });

  factory StudentProgress.fromJson(Map<String, dynamic> json, int studentId) {
    final pathStatus =
        json['learning_path_status'] as Map<String, dynamic>? ?? {};
    final studentScore = json['student_score'] as Map<String, dynamic>? ?? {};
    return StudentProgress(
      studentId: studentId,
      materialId: json['id'] as int? ?? json['material_id'] as int? ?? 0,
      preTestStatus: pathStatus['pre_test'] as String? ?? 'locked',
      preTestScore: studentScore['pre_test_score'] as int?,
      ebookStatus: pathStatus['ebook'] as String? ?? 'locked',
      postTestStatus: pathStatus['post_test'] as String? ?? 'locked',
      postTestScore: studentScore['post_test_score'] as int?,
      pulseStatus: pathStatus['pulse'] as String? ?? 'locked',
      pulseScore: studentScore['pulse_score'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'material_id': materialId,
      'pre_test_status': preTestStatus,
      'pre_test_score': preTestScore,
      'ebook_status': ebookStatus,
      'post_test_status': postTestStatus,
      'post_test_score': postTestScore,
      'pulse_status': pulseStatus,
      'pulse_score': pulseScore,
    };
  }
}

// Teacher models
class TeacherClass {
  final int id;
  final String name;
  final String gradeCategory;
  final int gradeLevel;
  final String classCode;
  final int studentCount;
  final int completedMaterials;
  final int totalMaterials;
  final double averagePulse;

  const TeacherClass({
    required this.id,
    required this.name,
    required this.gradeCategory,
    required this.gradeLevel,
    required this.classCode,
    required this.studentCount,
    required this.completedMaterials,
    required this.totalMaterials,
    required this.averagePulse,
  });

  factory TeacherClass.fromJson(Map<String, dynamic> json) {
    final pulseAvgObj = json['pulse_avg'] as Map<String, dynamic>?;
    double avgPulse = 0.0;
    if (pulseAvgObj != null) {
      final part = (pulseAvgObj['participation'] as num?)?.toDouble() ?? 0.0;
      final und = (pulseAvgObj['understanding'] as num?)?.toDouble() ?? 0.0;
      final lr = (pulseAvgObj['learning'] as num?)?.toDouble() ?? 0.0;
      final se = (pulseAvgObj['social_engagement'] as num?)?.toDouble() ?? 0.0;
      avgPulse = (part + und + lr + se) / 4;
    }
    return TeacherClass(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      gradeCategory: json['grade_category'] as String? ?? 'SMP',
      gradeLevel: _parseGradeLevel(json['grade_level'] ?? json['grade']),
      classCode: json['class_code'] as String? ?? '',
      studentCount: json['student_count'] as int? ?? 0,
      completedMaterials:
          (json['materials_completed_avg'] as num?)?.toInt() ?? 0,
      totalMaterials: 3,
      averagePulse: avgPulse,
    );
  }

  factory TeacherClass.fromListJson(Map<String, dynamic> json) {
    return TeacherClass.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'grade_category': gradeCategory,
      'grade_level': gradeLevel,
      'class_code': classCode,
      'student_count': studentCount,
      'completed_materials': completedMaterials,
      'total_materials': totalMaterials,
      'average_pulse': averagePulse,
    };
  }
}

class ClassStudent {
  final int id;
  final String name;
  final String email;
  final String? avatarUrl;
  final double participation;
  final double understanding;
  final double learning;
  final double socialEngagement;
  final String status; // active, inactive

  const ClassStudent({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.participation,
    required this.understanding,
    required this.learning,
    required this.socialEngagement,
    required this.status,
  });

  double get overallPulse =>
      (participation + understanding + learning + socialEngagement) / 4;

  factory ClassStudent.fromJson(Map<String, dynamic> json) {
    final scores = json['scores'] as Map<String, dynamic>? ?? {};
    double getVal(String key) {
      final scoreObj = scores[key];
      if (scoreObj is Map) {
        return (scoreObj['value'] as num?)?.toDouble() ?? 0.0;
      }
      return 0.0;
    }

    return ClassStudent(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? json['avatar'] as String?,
      participation: getVal('participation'),
      understanding: getVal('understanding'),
      learning: getVal('learning'),
      socialEngagement: getVal('social_engagement'),
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'participation': participation,
      'understanding': understanding,
      'learning': learning,
      'social_engagement': socialEngagement,
      'status': status,
    };
  }
}

class AnecdotalNote {
  final int id;
  final int teacherId;
  final int studentId;
  final String content;
  final String
  dimension; // participation, understanding, learning, social_engagement
  final DateTime createdAt;

  const AnecdotalNote({
    required this.id,
    required this.teacherId,
    required this.studentId,
    required this.content,
    required this.dimension,
    required this.createdAt,
  });

  factory AnecdotalNote.fromJson(Map<String, dynamic> json, int studentId) {
    return AnecdotalNote(
      id: json['id'] as int? ?? 0,
      teacherId:
          (json['created_by'] as Map<String, dynamic>?)?['id'] as int? ??
          json['teacher_id'] as int? ??
          0,
      studentId: studentId,
      content: json['content'] as String? ?? '',
      dimension:
          json['category'] as String? ??
          json['dimension'] as String? ??
          'participation',
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacher_id': teacherId,
      'student_id': studentId,
      'content': content,
      'dimension': dimension,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// =============================================================================
// LEARNING BOARD MODELS (Fase 3)
// =============================================================================

class LearningNode {
  final int id;
  final int materialId;
  final int orderIndex;
  final String nodeType; // 'content' | 'challenge' | 'social_task'
  final String? title;
  final String? body;
  final String? imageUrl;
  // For challenge nodes:
  final String? gameType; // 'multiple_choice' | 'matching' | 'sorting' | 'true_false_swipe'
  final Map<String, dynamic>? payload;
  // Progress (filled after fetching board with progress)
  final bool isCompleted;
  final Map<String, dynamic>? submittedAnswer;
  final bool? isCorrect;

  const LearningNode({
    required this.id,
    required this.materialId,
    required this.orderIndex,
    required this.nodeType,
    this.title,
    this.body,
    this.imageUrl,
    this.gameType,
    this.payload,
    this.isCompleted = false,
    this.submittedAnswer,
    this.isCorrect,
  });

  bool get isContent => nodeType == 'content';
  bool get isChallenge => nodeType == 'challenge';
  bool get isSocialTask => nodeType == 'social_task';

  factory LearningNode.fromJson(Map<String, dynamic> json) {
    final progressJson = json['progress'] as Map<String, dynamic>?;
    
    Map<String, dynamic>? parsedPayload;
    if (json['payload'] != null) {
      if (json['payload'] is String) {
        try {
          parsedPayload = jsonDecode(json['payload'] as String) as Map<String, dynamic>?;
        } catch (_) {}
      } else if (json['payload'] is Map) {
        parsedPayload = Map<String, dynamic>.from(json['payload'] as Map);
      }
    }

    Map<String, dynamic>? parsedSubmittedAnswer;
    if (progressJson?['submitted_answer'] != null) {
      if (progressJson!['submitted_answer'] is String) {
        try {
          parsedSubmittedAnswer = jsonDecode(progressJson['submitted_answer'] as String) as Map<String, dynamic>?;
        } catch (_) {}
      } else if (progressJson['submitted_answer'] is Map) {
        parsedSubmittedAnswer = Map<String, dynamic>.from(progressJson['submitted_answer'] as Map);
      }
    } else if (json['submitted_answer'] != null) {
      if (json['submitted_answer'] is String) {
        try {
          parsedSubmittedAnswer = jsonDecode(json['submitted_answer'] as String) as Map<String, dynamic>?;
        } catch (_) {}
      } else if (json['submitted_answer'] is Map) {
        parsedSubmittedAnswer = Map<String, dynamic>.from(json['submitted_answer'] as Map);
      }
    }

    return LearningNode(
      id: json['id'] as int? ?? 0,
      materialId: json['material_id'] as int? ?? 0,
      orderIndex: json['order_index'] as int? ?? 0,
      nodeType: json['node_type'] as String? ?? 'content',
      title: json['title'] as String?,
      body: json['body'] as String?,
      imageUrl: _resolvePhotoUrl(json['image_url'] as String?),
      gameType: json['game_type'] as String?,
      payload: parsedPayload,
      isCompleted: progressJson?['status'] != null || json['is_completed'] == true,
      submittedAnswer: parsedSubmittedAnswer,
      isCorrect: progressJson?['is_correct'] as bool? ?? json['is_correct'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'material_id': materialId,
      'order_index': orderIndex,
      'node_type': nodeType,
      'title': title,
      'body': body,
      'image_url': imageUrl,
      'game_type': gameType,
      'payload': payload,
      'is_completed': isCompleted,
    };
  }
}

class NodeCompleteResult {
  final int nodeId;
  final bool isCorrect;
  final int boardProgressPercent;

  const NodeCompleteResult({
    required this.nodeId,
    required this.isCorrect,
    required this.boardProgressPercent,
  });

  factory NodeCompleteResult.fromJson(Map<String, dynamic> json) {
    return NodeCompleteResult(
      nodeId: json['node_id'] as int? ?? 0,
      isCorrect: json['is_correct'] as bool? ?? false,
      boardProgressPercent: json['board_progress_percent'] as int? ?? 0,
    );
  }
}

// Roman numeral & generic grade parsing helper
int _parseGradeLevel(dynamic level) {
  if (level is int) return level;
  if (level is String) {
    final clean = level.trim().toUpperCase();
    if (clean == 'VII') return 7;
    if (clean == 'VIII') return 8;
    if (clean == 'IX') return 9;
    if (clean == 'X') return 10;
    if (clean == 'XI') return 11;
    if (clean == 'XII') return 12;
    final parsed = int.tryParse(clean);
    if (parsed != null) return parsed;
  }
  return 7; // Default fallback
}

String? _resolvePhotoUrl(String? url) {
  if (url == null || url.isEmpty) return null;
  if (url.startsWith('/')) {
    return 'http://192.168.2.93:8000$url';
  }
  // Replace localhost/127.0.0.1 variants (with or without port) to the WiFi IP
  var resolved = url
      .replaceAll('localhost:8000', '192.168.2.93:8000')
      .replaceAll('127.0.0.1:8000', '192.168.2.93:8000');
  // Handle case where APP_URL=http://localhost (no port) — asset() generates
  // URLs like http://localhost/storage/... which are unreachable from Android.
  // Use regex to replace 'localhost' only when NOT already followed by ':8000'.
  resolved = resolved
      .replaceAll(RegExp(r'localhost(?!:\d)'), '192.168.2.93:8000')
      .replaceAll(RegExp(r'127\.0\.0\.1(?!:\d)'), '192.168.2.93:8000');
  return resolved;
}
