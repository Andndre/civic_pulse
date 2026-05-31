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
  final String gradeCategory;
  final int gradeLevel;
  final int? estimatedDuration;
  final int orderIndex;
  final String status;

  const LearningMaterial({
    required this.id,
    required this.title,
    this.description,
    this.thumbnailUrl,
    this.fileUrl,
    required this.gradeCategory,
    required this.gradeLevel,
    this.estimatedDuration,
    required this.orderIndex,
    required this.status,
  });

  factory LearningMaterial.fromJson(Map<String, dynamic> json) {
    return LearningMaterial(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      thumbnailUrl:
          json['thumbnail_url'] as String? ?? json['thumbnail'] as String?,
      fileUrl: _resolvePhotoUrl(json['file_url'] as String?),
      gradeCategory: json['grade_category'] as String? ?? 'SMP',
      gradeLevel: _parseGradeLevel(json['grade_level'] ?? json['grade']),
      estimatedDuration:
          json['estimated_duration_minutes'] as int? ??
          json['estimated_duration'] as int?,
      orderIndex: json['order_index'] as int? ?? json['order'] as int? ?? 1,
      status: json['status'] as String? ?? 'locked',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'file_url': fileUrl,
      'grade_category': gradeCategory,
      'grade_level': gradeLevel,
      'estimated_duration_minutes': estimatedDuration,
      'order_index': orderIndex,
      'status': status,
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

  const PulseStatement({
    required this.id,
    required this.materialId,
    required this.dimension,
    required this.statement,
    required this.orderIndex,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'material_id': materialId,
      'dimension': dimension,
      'statement': statement,
      'order_index': orderIndex,
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
  final String title;
  final String category;
  final String location;
  final DateTime activityDate;
  final String? photoUrl;

  const ActivityLog({
    required this.id,
    required this.studentId,
    required this.title,
    required this.category,
    required this.location,
    required this.activityDate,
    this.photoUrl,
  });

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
      title: json['title'] as String? ?? '',
      category: getCategoryFromType(rawCategory),
      location: json['location'] as String? ?? 'sekolah',
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'title': title,
      'category': category,
      'location': location,
      'activity_date': activityDate.toIso8601String(),
      'photo_url': photoUrl,
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

  const StudentProgress({
    required this.studentId,
    required this.materialId,
    required this.preTestStatus,
    this.preTestScore,
    required this.ebookStatus,
    required this.postTestStatus,
    this.postTestScore,
    required this.pulseStatus,
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
  return url
      .replaceAll('localhost:8000', '192.168.2.93:8000')
      .replaceAll('127.0.0.1:8000', '192.168.2.93:8000');
}
