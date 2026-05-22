import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/network.dart';
import '../models/auth_models.dart';

abstract class AuthRepositoryInterface {
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthResponse> register(RegisterRequest request);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<String?> joinClass(String classCode);
  Future<String?> createClass({
    required String name,
    required String gradeCategory,
    required int gradeLevel,
  });
  Future<User> updateStudentProfile(int studentId, Map<String, dynamic> data);
}

class AuthRepository implements AuthRepositoryInterface {
  final ApiClient _client;

  AuthRepository({ApiClient? client}) : _client = client ?? ApiClient.instance;

  @override
  Future<User> updateStudentProfile(int studentId, Map<String, dynamic> data) async {
    try {
      final response = await _client.patch(
        '${ApiConstants.students}/$studentId',
        data: data,
      );
      
      final responseData = response.data;
      final Map<String, dynamic> userMap = 
          (responseData is Map && responseData.containsKey('data'))
              ? responseData['data'] as Map<String, dynamic>
              : responseData as Map<String, dynamic>;
      
      try {
        return User.fromJson(userMap);
      } catch (e) {
        final freshUser = await getCurrentUser();
        if (freshUser != null) return freshUser;
        rethrow;
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _client.post(
        ApiConstants.login,
        data: request.toJson(),
      );

      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _client.post(
        ApiConstants.register,
        data: request.toJson(),
      );

      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _client.post(ApiConstants.logout);
    } on DioException catch (e) {
      // Logout should not throw - clear local state regardless
      throw ApiException.fromDioException(e);
    } finally {
      await _client.clearToken();
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final response = await _client.get(ApiConstants.user);
      return User.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return null;
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<String?> joinClass(String classCode) async {
    try {
      debugPrint('[AUTH JOIN CLASS] Sending POST ${ApiConstants.joinClass} with class_code: $classCode');
      final response = await _client.post(
        ApiConstants.joinClass,
        data: ClassJoinRequest(classCode: classCode).toJson(),
      );
      debugPrint('[AUTH JOIN CLASS] Response: ${response.data}');
      final data = response.data;
      final resData = (data is Map && data.containsKey('data')) ? data['data'] : data;
      return resData['class_code'] as String? ?? classCode;
    } on DioException catch (e) {
      debugPrint('[AUTH JOIN CLASS] Error: ${e.type} - ${e.response?.statusCode}');
      debugPrint('[AUTH JOIN CLASS] Error data: ${e.response?.data}');

      // If the /classes/join endpoint is not implemented (404/405),
      // fall back to finding the class by code and updating student record
      final statusCode = e.response?.statusCode;
      if (statusCode == 404 || statusCode == 405) {
        debugPrint('[AUTH JOIN CLASS] Endpoint not available, trying fallback...');
        return _joinClassFallback(classCode);
      }

      throw ApiException.fromDioException(e);
    }
  }

  /// Fallback: find the class by its code, then assign the student to it
  Future<String?> _joinClassFallback(String classCode) async {
    try {
      // Step 1: Search for the class by code
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

      // Find the matching class
      Map<String, dynamic>? targetClass;
      for (final c in classList) {
        if (c is Map<String, dynamic> && c['class_code'] == classCode) {
          targetClass = c;
          break;
        }
      }

      if (targetClass == null) {
        throw ApiException(
          message: 'Kode kelas tidak ditemukan',
          statusCode: 404,
        );
      }

      final classId = targetClass['id'] as int;
      debugPrint('[AUTH JOIN CLASS FALLBACK] Found class ID: $classId');

      // Step 2: Get current user info
      final userResponse = await _client.get(ApiConstants.user);
      final userData = userResponse.data;
      final userInfo = (userData is Map && userData.containsKey('data'))
          ? userData['data']
          : userData;
      final studentId = userInfo['id'] as int;

      // Step 3: Update student's class_id
      await _client.patch(
        '${ApiConstants.students}/$studentId',
        data: {'class_id': classId},
      );
      debugPrint('[AUTH JOIN CLASS FALLBACK] Success! Student $studentId -> Class $classId');

      return classCode;
    } on DioException catch (e) {
      debugPrint('[AUTH JOIN CLASS FALLBACK] Error: ${e.response?.data}');
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<String?> createClass({
    required String name,
    required String gradeCategory,
    required int gradeLevel,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.classes,
        data: {
          'name': name,
          'grade': gradeLevel,
          'grade_category': gradeCategory,
          'grade_level': gradeLevel,
        },
      );
      return response.data['class_code'] as String?;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
