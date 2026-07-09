import 'package:auth_frontend/core/errors/server_exception.dart';
import 'package:auth_frontend/core/errors/unauthorized_exception.dart';
import 'package:auth_frontend/features/auth/data/models/login_response.dart';
import 'package:auth_frontend/features/auth/data/models/refresh_response.dart';
import 'package:auth_frontend/features/auth/data/models/signup_response.dart';
import 'package:auth_frontend/features/auth/domain/entities/user.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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
      debugPrint(e.response?.data.toString());
      rethrow;
    } catch (e) {
      debugPrint("error login ${e.toString()}");
      rethrow;
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
      debugPrint(response.toString());

      return SignupResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint("Error signing up ${e.response}");
      rethrow;
    } catch (e) {
      debugPrint("Unexpected error $e");
      rethrow;
    }
  }

  // refresh
  Future<RefreshResponse> refresh({required String refreshToken}) async {
    try {
      final response = await client.post(
        '$baseUrl/refresh',
        data: {'refreshToken': refreshToken},
      );

      debugPrint(response.toString());

      return RefreshResponse.fromJson(
        json: response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      debugPrint("Error refreshing token ${e.response}");
      switch (e.response?.statusCode) {
        case 401:
          throw const UnauthorizedException(); // Session ended

        case 500:
          throw const ServerException();

        default:
          rethrow;
      }
    } catch (e) {
      debugPrint("Unexpected error $e");
      rethrow;
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
      debugPrint("Error logging out ${e.response}");
    } catch (e) {
      debugPrint("Something went wrong $e");
      rethrow;
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
        throw const UnauthorizedException();
      }

      debugPrint("Error getting me ${e.response}");

      rethrow;
    } catch (e) {
      debugPrint("Something went wrong $e");
      rethrow;
    }
  }
}
