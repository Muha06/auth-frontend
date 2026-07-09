import 'package:auth_frontend/features/auth/data/datasources/auth_remote_ds.dart';
import 'package:auth_frontend/features/auth/data/models/login_response.dart';
import 'package:auth_frontend/features/auth/data/models/refresh_response.dart';
import 'package:auth_frontend/features/auth/data/models/signup_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Integration test for the app functionality

  late AuthRemoteDs remote;

  setUp(() {
    remote = AuthRemoteDs(baseUrl: 'http://localhost:3000/auth', client: Dio());
  });

  const String email = 'test3@gmail.com';
  const String username = 'testUsername3';
  const String hobby = 'eating';
  const String password = '123456';

  // login test
  test('login', () async {
    final response = await remote.login(email: email, password: password);
    expect(response, isA<LoginResponse>());
  });

  test('signup', () async {
    final response = await remote.signUp(
      email: email,
      username: username,
      hobby: hobby,
      password: password,
    );

    expect(response, isA<SignupResponse>());
  });

  test('refresh', () async {
    final response = await remote.refresh(
      refreshToken:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0OGRlMzFiOC0yNjlmLTQ1ZmYtYTg0Yy1jODRmMWRmNmRhZjAiLCJlbWFpbCI6InRlc3QzQGdtYWlsLmNvbSIsInR5cGUiOiJyZWZyZXNoIiwiaWF0IjoxNzgzNTIxODY4LCJleHAiOjE3ODQxMjY2Njh9.PylLAhO0hAR0v97MwlbyOaIzNphTmKzWNMORAHy7cuo',
    );

    expect(response, isA<RefreshResponse>());
  });
  test('logout', () async {
    await remote.logout(refreshToken: '', accessToken: '');
  });
}
