/// Domain entity representing an authenticated user.
/// Completely independent of Flutter and HTTP.
class User {
  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.accessToken,
    required this.refreshToken,
    this.image,
    this.phone,
    this.gender,
  });

  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String accessToken;
  final String refreshToken;
  final String? image;
  final String? phone;
  final String? gender;

  String get fullName => '$firstName $lastName';

  @override
  String toString() => 'User($id, $username)';
}
