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
}

class AuthResponse {
  final String token;
  final User user;
  final String? classCode;

  const AuthResponse({
    required this.token,
    required this.user,
    this.classCode,
  });
}

class LearningMaterial {
  final int id;
  final String title;
  final String? description;
  final String? thumbnailUrl;
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
    required this.gradeCategory,
    required this.gradeLevel,
    this.estimatedDuration,
    required this.orderIndex,
    required this.status,
  });
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
}
