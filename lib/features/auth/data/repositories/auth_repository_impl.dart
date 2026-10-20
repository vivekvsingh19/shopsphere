import '../../../../core/error/error_handler.dart';
import '../../../../core/storage/secure_storage.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_models.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._storage);

  final AuthRemoteDataSource _remote;
  final SecureStorageService _storage;

  @override
  Future<User> login(String username, String password) async {
    try {
      final response = await _remote.login(username, password);
      await _storage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      return User(
        id: response.id,
        username: response.username,
        email: response.email,
        firstName: response.firstName,
        lastName: response.lastName,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        image: response.image,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<User> getCurrentUser() async {
    try {
      final userModel = await _remote.getCurrentUser();
      final accessToken = await _storage.getAccessToken() ?? '';
      final refreshToken = await _storage.getRefreshToken() ?? '';
      return User(
        id: userModel.id,
        username: userModel.username,
        email: userModel.email,
        firstName: userModel.firstName,
        lastName: userModel.lastName,
        accessToken: accessToken,
        refreshToken: refreshToken,
        image: userModel.image,
        phone: userModel.phone,
        gender: userModel.gender,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> logout() => _storage.clearTokens();

  @override
  Future<bool> hasValidSession() => _storage.hasValidSession();
}
