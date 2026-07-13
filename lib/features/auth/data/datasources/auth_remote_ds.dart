import 'package:auth_frontend/core/errors/api_exception.dart';
import 'package:auth_frontend/core/errors/unauthenticated_exception.dart';
import 'package:auth_frontend/core/errors/unauthorized_exception.dart';
import 'package:auth_frontend/features/auth/data/models/login_response.dart';
import 'package:auth_frontend/features/auth/data/models/refresh_response.dart';
import 'package:auth_frontend/features/auth/data/models/signup_response.dart';
import 'package:auth_frontend/features/auth/domain/entities/user.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class AuthRemoteDs {
  AuthRemoteDs({required this.client, required this.baseUrl});
  final String baseUrl;
  final Dio client;

  // Login
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.post(
        '$baseUrl/login',
        data: {'email': email, 'password': password},
      );

      final loginResponse = LoginResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      return loginResponse;
    } on DioException catch (e) {
      throw ApiException(e.response?.data['message'] ?? 'Something went wrong');
    }
  }

  // Sign up
  Future<SignupResponse> signUp({
    required String email,
    required String username,
    required String hobby,
    required String password,
  }) async {
    try {
      final response = await client.post(
        '$baseUrl/signup',
        data: {
          'email': email,
          'username': username,
          'hobby': hobby,
          'password': password,
        },
      );

      return SignupResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(e.response?.data['message'] ?? 'Something went wrong');
    }
  }

  // refresh
  Future<RefreshResponse> refresh({required String refreshToken}) async {
    try {
      final response = await client.post(
        '$baseUrl/refresh',
        data: {'refreshToken': refreshToken},
      );

      return RefreshResponse.fromJson(
        json: response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const UnauthenticatedException(); // session ended
      }

      throw ApiException(e.response?.data['message'] ?? 'Something went wrong');
    }
  }

  // logout
  Future<void> logout({
    required String refreshToken,
    required String accessToken,
  }) async {
    try {
      await client.post(
        '$baseUrl/logout',
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const UnauthorizedException(); // To refresh access_token
      }

      final message = e.response?.data?['message'];

      throw ApiException(
        message is List
            ? message.first.toString()
            : message?.toString() ?? 'Something went wrong',
      );
    }
  }

  // Get me
  Future<UserProfile> getMe({required String accessToken}) async {
    try {
      final response = await client.get(
        '$baseUrl/me',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      return UserProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const UnauthorizedException(); // To refresh access_token
      }

      throw ApiException(e.response?.data['message'] ?? 'Something went wrong');
    }
  }

  // change - password
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String accessToken,
  }) async {
    try {
      await client.patch(
        '$baseUrl/change-password',
        data: {'oldPassword': oldPassword, 'newPassword': newPassword},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const UnauthorizedException(); // To refresh access_token
      }

      final message = e.response?.data?['message'];

      throw ApiException(
        message is List
            ? message.first.toString()
            : message?.toString() ?? 'Something went wrong',
      );
    }
  }

  Future<void> forgotPassword({required String email}) async {
    try {
      await client.post('$baseUrl/forgot-password', data: {"email": email});
    } on DioException catch (e) {
      debugPrint(e.toString());
      final message = e.response?.data?['message'];

      throw ApiException(
        message is List
            ? message.first.toString()
            : message?.toString() ?? 'Something went wrong',
      );
    }
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await client.post(
        '$baseUrl/reset-password',
        data: {"token": token, "newPassword": newPassword},
      );
    } on DioException catch (e) {
      debugPrint(e.response?.data);
      final message = e.response?.data?['message'];

      throw ApiException(
        message is List
            ? message.first.toString()
            : message?.toString() ?? 'Something went wrong',
      );
    }
  }
}
