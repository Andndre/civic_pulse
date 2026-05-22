import 'package:equatable/equatable.dart';

enum UserRole { admin, teacher, student }

class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final UserRole role;
  final String? avatarUrl;
  final bool isActive;
  final DateTime createdAt;
  final String? dateOfBirth;
  final String? parentName;
  final String? parentPhone;
  final String? phone;
  final String? address;
  final String? gender;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.isActive = true,
    required this.createdAt,
    this.dateOfBirth,
    this.parentName,
    this.parentPhone,
    this.phone,
    this.address,
    this.gender,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Check if user object is nested inside 'data'
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return User(
      id: data['id'] as int,
      name: data['name'] as String,
      email: data['email'] as String,
      role: _parseRole(data['role']),
      avatarUrl: data['avatar'] as String? ?? data['avatar_url'] as String?,
      isActive: data['is_active'] as bool? ?? (data['status'] != null ? data['status'] == 'active' : true),
      createdAt: DateTime.parse(
        data['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      dateOfBirth: data['date_of_birth'] as String?,
      parentName: data['parent_name'] as String?,
      parentPhone: data['parent_phone'] as String?,
      phone: data['phone'] as String?,
      address: data['address'] as String?,
      gender: data['gender'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'avatar_url': avatarUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'date_of_birth': dateOfBirth,
      'parent_name': parentName,
      'parent_phone': parentPhone,
      'phone': phone,
      'address': address,
      'gender': gender,
    };
  }

  static UserRole _parseRole(String? role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'teacher':
        return UserRole.teacher;
      case 'student':
      default:
        return UserRole.student;
    }
  }

  bool get isStudent => role == UserRole.student;
  bool get isTeacher => role == UserRole.teacher;
  bool get isAdmin => role == UserRole.admin;

  @override
  List<Object?> get props => [
        id,
        email,
        role,
        avatarUrl,
        isActive,
        createdAt,
        dateOfBirth,
        parentName,
        parentPhone,
        phone,
        address,
        gender,
      ];
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

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Laravel wraps response in 'data' object
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return AuthResponse(
      token: data['token'] as String,
      user: User.fromJson(data['user'] as Map<String, dynamic>),
      classCode: data['class_code'] as String?,
    );
  }
}

class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String role;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
      'role': role,
    };
  }
}

class ClassJoinRequest {
  final String classCode;

  const ClassJoinRequest({required this.classCode});

  Map<String, dynamic> toJson() {
    return {'class_code': classCode};
  }
}
