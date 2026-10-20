import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/auth/data/models/auth_models.dart';

void main() {
  group('AuthResponse', () {
    late Map<String, dynamic> authJson;

    setUp(() {
      final file = File('test/fixtures/auth_response.json');
      authJson = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    });

    test('T11: parses auth response JSON correctly', () {
      final response = AuthResponse.fromJson(authJson);

      expect(response.id, 1);
      expect(response.username, 'emilys');
      expect(response.email, 'emily.johnson@x.dummyjson.com');
      expect(response.firstName, 'Emily');
      expect(response.lastName, 'Johnson');
      expect(response.accessToken, isNotEmpty);
      expect(response.refreshToken, isNotEmpty);
    });

    test('T12: nullable image field is parsed correctly', () {
      final response = AuthResponse.fromJson(authJson);

      expect(response.image, isNotNull);
      expect(response.image, contains('dummyjson.com'));
    });

    test('T13: missing optional image field defaults to null', () {
      final json = Map<String, dynamic>.from(authJson)..remove('image');
      final response = AuthResponse.fromJson(json);

      expect(response.image, isNull);
    });
  });

  group('LoginRequest', () {
    test('T14: serialises to JSON correctly', () {
      const request = LoginRequest(username: 'emilys', password: 'emilyspass');
      final json = request.toJson();

      expect(json['username'], 'emilys');
      expect(json['password'], 'emilyspass');
    });
  });
}
