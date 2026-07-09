import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  ApiConstants._();

  // Base URL - change this to your Laravel API URL
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api/v1';
    }
    return Platform.isAndroid
        ? 'http://192.168.2.93:8000/api/v1'
        : 'http://localhost:8000/api/v1';
  }

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String user = '/auth/me';

  static const String classes = '/classes';
  static const String joinClass = '/classes/join';

  static const String materials = '/materials';
  static const String students = '/students';

  static const String activities = '/activities';

  static const String dashboardStats = '/dashboard/stats';
  static const String dashboardUsers = '/dashboard/users';
  static const String dashboardAnalytics = '/dashboard/analytics';
}
