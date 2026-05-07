import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;
  final DioException? originalException;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
    this.originalException,
  });

  factory ApiException.fromDioException(DioException e) {
    String message;
    int? statusCode = e.response?.statusCode;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Request timeout. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Server not responding. Please try again later.';
        break;
      case DioExceptionType.badResponse:
        message = _parseErrorMessage(e.response?.data) ??
            'Server error (${e.response?.statusCode})';
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled.';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection. Please check your network.';
        break;
      case DioExceptionType.unknown:
      default:
        message = 'Something went wrong. Please try again.';
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      data: e.response?.data,
      originalException: e,
    );
  }

  static String? _parseErrorMessage(dynamic data) {
    if (data == null) return null;
    if (data is String) return data;
    if (data is Map) {
      if (data.containsKey('message')) return data['message'];
      if (data.containsKey('error')) return data['error'];
      // Laravel validation errors
      if (data.containsKey('errors')) {
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final firstKey = errors.keys.first;
          final firstError = errors[firstKey];
          if (firstError is List && firstError.isNotEmpty) {
            return firstError[0];
          }
        }
      }
    }
    return null;
  }

  @override
  String toString() => message;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isValidationError => statusCode == 422;
}
