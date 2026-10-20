import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../storage/secure_storage.dart';

/// Injects the Bearer token from [SecureStorageService] into every request
/// and handles 401 by clearing the session.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage, this._onUnauthenticated);

  final SecureStorageService _storage;
  final Future<void> Function() _onUnauthenticated;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Token expired — clear session and notify app.
      await _storage.clearTokens();
      await _onUnauthenticated();
    }
    handler.next(err);
  }
}

/// Debug-only request/response logger.
/// Never runs in release mode; never logs Authorization header values.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final safeHeaders = Map<String, dynamic>.from(options.headers)
        ..remove('Authorization'); // Never log tokens
      debugPrint('→ ${options.method} ${options.uri}');
      debugPrint('  Headers: $safeHeaders');
      if (options.data != null) {
        final safeData = _sanitizeBody(options.data);
        debugPrint('  Body: $safeData');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      debugPrint('← ${response.statusCode} ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('✗ ${err.type} ${err.requestOptions.uri}: ${err.message}');
    }
    handler.next(err);
  }

  /// Remove sensitive fields before logging.
  dynamic _sanitizeBody(dynamic body) {
    if (body is Map<String, dynamic>) {
      return Map<String, dynamic>.from(body)
        ..remove('password')
        ..remove('token')
        ..remove('refreshToken');
    }
    return body;
  }
}
