/// Typed failure hierarchy for ShopSphere.
/// All repository methods return [AppError] on failure.
sealed class AppError implements Exception {
  const AppError();

  /// Human-readable message suitable for display in UI.
  String get displayMessage;
}

/// Device has no internet connectivity or the host is unreachable.
class NetworkError extends AppError {
  const NetworkError({
    this.message = 'No internet connection. Please check your network.',
  });
  final String message;

  @override
  String get displayMessage => message;

  @override
  String toString() => 'NetworkError: $message';
}

/// The server responded with a non-success HTTP status code.
class ServerError extends AppError {
  const ServerError({required this.statusCode, required this.message});
  final int statusCode;
  final String message;

  @override
  String get displayMessage => message.isNotEmpty
      ? message
      : 'Server error (HTTP $statusCode). Please try again.';

  @override
  String toString() => 'ServerError($statusCode): $message';
}

/// HTTP 401 or 403 — authentication/authorisation failure.
class AuthError extends AppError {
  const AuthError({this.message = 'Session expired. Please log in again.'});
  final String message;

  @override
  String get displayMessage => message;

  @override
  String toString() => 'AuthError: $message';
}

/// HTTP 404 — requested resource does not exist.
class NotFoundError extends AppError {
  const NotFoundError({this.message = 'The requested resource was not found.'});
  final String message;

  @override
  String get displayMessage => message;

  @override
  String toString() => 'NotFoundError: $message';
}

/// Request timed out.
class TimeoutError extends AppError {
  const TimeoutError({this.message = 'Request timed out. Please try again.'});
  final String message;

  @override
  String get displayMessage => message;

  @override
  String toString() => 'TimeoutError: $message';
}

/// Unexpected / unclassified failure.
class UnknownError extends AppError {
  const UnknownError({this.message = 'An unexpected error occurred.'});
  final String message;

  @override
  String get displayMessage => message;

  @override
  String toString() => 'UnknownError: $message';
}
