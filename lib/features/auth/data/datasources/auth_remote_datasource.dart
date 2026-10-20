import 'package:dio/dio.dart';

import '../../data/models/auth_models.dart';

/// Remote data source — all DummyJSON auth endpoints.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);
  final Dio _dio;

  Future<AuthResponse> login(String username, String password) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: LoginRequest(username: username, password: password).toJson(),
    );
    return AuthResponse.fromJson(response.data!);
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _dio.get<Map<String, dynamic>>('/auth/me');
    return UserModel.fromJson(response.data!);
  }
}
