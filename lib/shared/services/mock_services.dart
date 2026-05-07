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
