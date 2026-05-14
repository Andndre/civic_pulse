import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mock_models.dart';
import 'mock_data.dart';
import '../../features/auth/data/models/auth_models.dart' as auth_models;

/// Mock Auth Service - swap with real API in production
class MockAuthService {
  Future<auth_models.AuthResponse> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (email == 'andi@email.com' && password == 'password123') {
      return auth_models.AuthResponse(
        token: MockData.validStudentToken,
        user: auth_models.User(
          id: MockData.studentUser.id,
          name: MockData.studentUser.name,
          email: MockData.studentUser.email,
          role: auth_models.UserRole.student,
          isActive: true,
          createdAt: DateTime.now(),
        ),
      );
    }

    if (email == 'siti@email.com' && password == 'password123') {
      return auth_models.AuthResponse(
        token: MockData.validTeacherToken,
        user: auth_models.User(
          id: MockData.teacherUser.id,
          name: MockData.teacherUser.name,
          email: MockData.teacherUser.email,
          role: auth_models.UserRole.teacher,
          isActive: true,
          createdAt: DateTime.now(),
        ),
        classCode: 'VIIA2024',
      );
    }

    throw Exception('Email atau password salah');
  }

  Future<auth_models.AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final userRole = role == 'teacher'
        ? auth_models.UserRole.teacher
        : auth_models.UserRole.student;

    return auth_models.AuthResponse(
      token: 'mock_register_token_${DateTime.now().millisecondsSinceEpoch}',
      user: auth_models.User(
        id: 100,
        name: name,
        email: email,
        role: userRole,
        isActive: true,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}

/// Mock Material Service
class MockMaterialService {
  Future<List<LearningMaterial>> getMaterials({
    String? gradeCategory,
    int? gradeLevel,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    var materials = MockData.materials;

    if (gradeCategory != null) {
      materials =
          materials.where((m) => m.gradeCategory == gradeCategory).toList();
    }

    if (gradeLevel != null) {
      materials = materials.where((m) => m.gradeLevel == gradeLevel).toList();
    }

    return materials;
  }

  Future<LearningMaterial?> getMaterial(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return MockData.materials.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<Question>> getQuestions(int materialId, String type) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return MockData.sampleQuestions
        .where((q) => q.materialId == materialId && q.type == type)
        .toList();
  }

  Future<List<PulseStatement>> getPulseStatements(int materialId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return MockData.pulseStatements
        .where((s) => s.materialId == materialId)
        .toList();
  }
}

/// Mock Class Service
class MockClassService {
  Future<List<StudentClass>> getStudentClasses(int studentId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return MockData.studentClasses;
  }

  Future<String?> joinClass(String classCode) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Accept any 6+ character code
    if (classCode.length >= 6) {
      return classCode;
    }
    throw Exception('Kode kelas tidak valid');
  }
}

/// Mock Activity Service
class MockActivityService {
  Future<List<ActivityLog>> getActivities(int studentId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return MockData.activityLogs
        .where((a) => a.studentId == studentId)
        .toList();
  }

  Future<ActivityLog> createActivity({
    required int studentId,
    required String title,
    required String category,
    required String location,
    required DateTime activityDate,
    String? photoUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return ActivityLog(
      id: DateTime.now().millisecondsSinceEpoch,
      studentId: studentId,
      title: title,
      category: category,
      location: location,
      activityDate: activityDate,
      photoUrl: photoUrl,
    );
  }
}

/// Mock Analytics Service
class MockAnalyticsService {
  Future<PulseScores> getPulseScores(int studentId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockData.samplePulseScores;
  }

  Future<List<StudentProgress>> getProgress(int studentId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return MockData.materials.map((m) {
      return StudentProgress(
        studentId: studentId,
        materialId: m.id,
        preTestStatus: 'completed',
        preTestScore: 70 + (m.id * 5).toInt(),
        ebookStatus: 'completed',
        postTestStatus: 'completed',
        postTestScore: 75 + (m.id * 5).toInt(),
        pulseStatus: 'completed',
      );
    }).toList();
  }
}

/// Mock Teacher Service
class MockTeacherService {
  Future<List<TeacherClass>> getTeacherClasses(int teacherId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Return mock teacher classes
    return [
      TeacherClass(
        id: 1,
        name: 'Kelas VII-A',
        gradeCategory: 'SMP',
        gradeLevel: 7,
        classCode: 'VIIA2024',
        studentCount: 32,
        completedMaterials: 2,
        totalMaterials: 3,
        averagePulse: 3.6,
      ),
      TeacherClass(
        id: 2,
        name: 'Kelas VIII-B',
        gradeCategory: 'SMP',
        gradeLevel: 8,
        classCode: 'VIIIB2024',
        studentCount: 28,
        completedMaterials: 1,
        totalMaterials: 3,
        averagePulse: 3.4,
      ),
    ];
  }

  Future<List<ClassStudent>> getClassStudents(int classId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Return mock students for the class
    return [
      ClassStudent(
        id: 1,
        name: 'Andi Pratama',
        email: 'andi@email.com',
        participation: 3.5,
        understanding: 4.0,
        learning: 3.8,
        socialEngagement: 3.2,
        status: 'active',
      ),
      ClassStudent(
        id: 2,
        name: 'Siti Nurhaliza',
        email: 'siti@email.com',
        participation: 4.0,
        understanding: 3.5,
        learning: 4.2,
        socialEngagement: 3.8,
        status: 'active',
      ),
      ClassStudent(
        id: 3,
        name: 'Budi Santoso',
        email: 'budi@email.com',
        participation: 2.8,
        understanding: 3.2,
        learning: 3.0,
        socialEngagement: 2.5,
        status: 'active',
      ),
      ClassStudent(
        id: 4,
        name: 'Dewi Lestari',
        email: 'dewi@email.com',
        participation: 3.8,
        understanding: 4.1,
        learning: 3.9,
        socialEngagement: 4.0,
        status: 'active',
      ),
      ClassStudent(
        id: 5,
        name: 'Rizki Ramadhan',
        email: 'rizki@email.com',
        participation: 3.2,
        understanding: 3.5,
        learning: 3.4,
        socialEngagement: 3.0,
        status: 'active',
      ),
    ];
  }

  Future<List<AnecdotalNote>> getAnecdotalNotes(int studentId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      AnecdotalNote(
        id: 1,
        teacherId: 2,
        studentId: studentId,
        content: 'Siswa aktif bertanya dalam diskusi kelompok tentang toleransi antar umat beragama.',
        dimension: 'participation',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      AnecdotalNote(
        id: 2,
        teacherId: 2,
        studentId: studentId,
        content: 'Memahami konsep keberagaman budaya dengan baik. Bisa memberikan contoh dari lingkungan sekitar.',
        dimension: 'understanding',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  Future<AnecdotalNote> createAnecdotalNote({
    required int studentId,
    required String content,
    required String dimension,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return AnecdotalNote(
      id: DateTime.now().millisecondsSinceEpoch,
      teacherId: 2,
      studentId: studentId,
      content: content,
      dimension: dimension,
      createdAt: DateTime.now(),
    );
  }

  Future<void> deleteAnecdotalNote(int noteId) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<String> createClass({
    required String name,
    required String gradeCategory,
    required int gradeLevel,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final code = '${gradeCategory.substring(0, 2)}${gradeLevel}${name.replaceAll(' ', '').substring(0, 2).toUpperCase()}${DateTime.now().year}';
    return code;
  }

  Future<void> deleteClass(int classId) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }
}

// Service Providers
final mockAuthServiceProvider = Provider<MockAuthService>((ref) {
  return MockAuthService();
});

final mockMaterialServiceProvider = Provider<MockMaterialService>((ref) {
  return MockMaterialService();
});

final mockClassServiceProvider = Provider<MockClassService>((ref) {
  return MockClassService();
});

final mockActivityServiceProvider = Provider<MockActivityService>((ref) {
  return MockActivityService();
});

final mockAnalyticsServiceProvider = Provider<MockAnalyticsService>((ref) {
  return MockAnalyticsService();
});
