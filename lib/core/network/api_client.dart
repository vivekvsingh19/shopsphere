import 'package:dio/dio.dart';

import '../storage/secure_storage.dart';
import 'interceptors.dart';

const _baseUrl = 'https://dummyjson.com';
const _connectTimeout = Duration(seconds: 15);
const _receiveTimeout = Duration(seconds: 30);

/// Factory that creates a fully configured [Dio] instance.
Dio createDio(
  SecureStorageService storage,
  Future<void> Function() onUnauthenticated,
) {
  final dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: _connectTimeout,
      receiveTimeout: _receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.addAll([
    LoggingInterceptor(),
    AuthInterceptor(storage, onUnauthenticated),
  ]);

  return dio;
}
