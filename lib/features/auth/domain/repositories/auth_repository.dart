import '../../domain/entities/user.dart';

/// Abstract repository interface for authentication.
/// Domain layer depends on this; data layer implements it.
abstract class AuthRepository {
  /// Authenticates with [username] and [password].
  /// Returns the authenticated [User] or throws [AppError].
  Future<User> login(String username, String password);

  /// Fetches the currently authenticated user profile.
  /// Throws [AppError] if token is invalid or expired.
  Future<User> getCurrentUser();

  /// Clears all stored session data.
  Future<void> logout();

  /// Whether a valid session token exists locally.
  Future<bool> hasValidSession();
}
