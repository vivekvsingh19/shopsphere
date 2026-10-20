import 'dart:io';

import 'package:dio/dio.dart';

import 'app_error.dart';

/// Converts [DioException] and generic [Exception]s into typed [AppError].
abstract final class ErrorHandler {
  static AppError handle(Object error) {
    if (error is AppError) return error;

    if (error is DioException) {
      return _handleDio(error);
    }

    if (error is SocketException) {
      return const NetworkError();
    }

    return UnknownError(message: error.toString());
  }

  static AppError _handleDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const TimeoutError();

      case DioExceptionType.connectionError:
        return const NetworkError();

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final message = _extractMessage(e.response);
        return switch (statusCode) {
          401 || 403 => AuthError(message: message.isNotEmpty ? message : 'Authentication failed.'),
          404 => NotFoundError(message: message.isNotEmpty ? message : 'Resource not found.'),
          >= 500 => ServerError(statusCode: statusCode, message: message.isNotEmpty ? message : 'Server error. Please try again.'),
          _ => ServerError(statusCode: statusCode, message: message),
        };

      case DioExceptionType.cancel:
        return const UnknownError(message: 'Request was cancelled.');

      case DioExceptionType.unknown:
        if (e.error is SocketException) return const NetworkError();
        return UnknownError(message: e.message ?? 'Unknown error.');

      case DioExceptionType.badCertificate:
        return const UnknownError(message: 'Certificate error.');
    }
  }

  static String _extractMessage(Response<dynamic>? response) {
    try {
      final data = response?.data;
      if (data is Map<String, dynamic>) {
        return (data['message'] as String?) ?? '';
      }
    } catch (_) {}
    return '';
  }
}
