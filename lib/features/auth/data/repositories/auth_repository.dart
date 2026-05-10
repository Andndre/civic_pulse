import 'package:dio/dio.dart';
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
}

class AuthRepository implements AuthRepositoryInterface {
  final ApiClient _client;

  AuthRepository({ApiClient? client}) : _client = client ?? ApiClient.instance;

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
      final response = await _client.post(
        ApiConstants.joinClass,
        data: ClassJoinRequest(classCode: classCode).toJson(),
      );
      return response.data['class_code'] as String?;
    } on DioException catch (e) {
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
