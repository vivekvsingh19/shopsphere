import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/app_error.dart';
import 'package:shopsphere/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:shopsphere/features/auth/data/models/auth_models.dart';
import 'package:shopsphere/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:shopsphere/core/storage/secure_storage.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}
class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late MockAuthRemoteDataSource mockDataSource;
  late MockSecureStorageService mockStorage;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockAuthRemoteDataSource();
    mockStorage = MockSecureStorageService();
    repository = AuthRepositoryImpl(mockDataSource, mockStorage);
  });

  const tAuthResponse = AuthResponse(
    accessToken: 'access-token-123',
    refreshToken: 'refresh-token-456',
    id: 1,
    username: 'emilys',
    email: 'emily@test.com',
    firstName: 'Emily',
    lastName: 'Johnson',
    gender: 'female',
    image: 'https://example.com/avatar.jpg',
  );

  group('AuthRepositoryImpl.login', () {
    test('T33: returns User on successful login', () async {
      when(() => mockDataSource.login('emilys', 'emilyspass'))
          .thenAnswer((_) async => tAuthResponse);
      when(() => mockStorage.saveTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          )).thenAnswer((_) async {});

      final user = await repository.login('emilys', 'emilyspass');

      expect(user.username, 'emilys');
      expect(user.accessToken, 'access-token-123');
      expect(user.fullName, 'Emily Johnson');
    });

    test('T34: saves tokens to secure storage after successful login', () async {
      when(() => mockDataSource.login('emilys', 'emilyspass'))
          .thenAnswer((_) async => tAuthResponse);
      when(() => mockStorage.saveTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          )).thenAnswer((_) async {});

      await repository.login('emilys', 'emilyspass');

      verify(() => mockStorage.saveTokens(
            accessToken: 'access-token-123',
            refreshToken: 'refresh-token-456',
          )).called(1);
    });

    test('T35: throws AuthError on invalid credentials (401)', () async {
      when(() => mockDataSource.login('bad', 'wrong'))
          .thenThrow(const AuthError(message: 'Invalid credentials'));

      expect(
        () => repository.login('bad', 'wrong'),
        throwsA(isA<AuthError>()),
      );
    });

    test('T36: throws NetworkError on connection failure', () async {
      when(() => mockDataSource.login(any(), any()))
          .thenThrow(const NetworkError());

      expect(
        () => repository.login('emilys', 'emilyspass'),
        throwsA(isA<NetworkError>()),
      );
    });
  });

  group('AuthRepositoryImpl.hasValidSession', () {
    test('T37: returns true when access token exists', () async {
      when(() => mockStorage.hasValidSession()).thenAnswer((_) async => true);

      final result = await repository.hasValidSession();
      expect(result, isTrue);
    });

    test('T38: returns false when no token stored', () async {
      when(() => mockStorage.hasValidSession()).thenAnswer((_) async => false);

      final result = await repository.hasValidSession();
      expect(result, isFalse);
    });
  });
}
