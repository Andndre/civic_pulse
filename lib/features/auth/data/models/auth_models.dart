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

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.isActive = true,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: _parseRole(json['role']),
      avatarUrl: json['avatar'] as String? ?? json['avatar_url'] as String?,
      isActive: json['is_active'] as bool? ?? json['status'] == 'active' ?? true,
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
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
  List<Object?> get props => [id, email, role];
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
