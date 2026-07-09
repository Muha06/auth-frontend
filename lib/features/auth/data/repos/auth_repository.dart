import 'package:auth_frontend/core/errors/unauthenticated_exception.dart';
import 'package:auth_frontend/core/errors/unauthorized_exception.dart';
import 'package:auth_frontend/features/auth/data/datasources/auth_local_storage.dart';
import 'package:auth_frontend/features/auth/data/datasources/auth_remote_ds.dart';
import 'package:auth_frontend/features/auth/data/datasources/user_local_ds.dart';
import 'package:auth_frontend/features/auth/data/models/login_response.dart';
import 'package:auth_frontend/features/auth/data/models/refresh_response.dart';
import 'package:auth_frontend/features/auth/data/models/signup_response.dart';
import 'package:auth_frontend/features/auth/domain/entities/user.dart';
import 'package:flutter/material.dart';

class AuthRepository {
  AuthRepository({
    required this.localStorage,
    required this.remoteDs,
    required this.userProfileLocalDs,
  });
  final AuthRemoteDs remoteDs;
  final AuthLocalStorage localStorage;
  final UserProfileLocalDs userProfileLocalDs;

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final loginResponse = await remoteDs.login(
      email: email,
      password: password,
    );

    await localStorage.storeRefreshToken(loginResponse.refreshToken);

    await userProfileLocalDs.cache(
      loginResponse.user.toHiveModel(),
    ); // Cache user profile

    return loginResponse;
  }

  Future<SignupResponse> signup({
    required String email,
    required String username,
    required String hobby,
    required String password,
  }) async {
    final signupResponse = await remoteDs.signUp(
      email: email,
      username: username,
      hobby: hobby,
      password: password,
    );

    await localStorage.storeRefreshToken(
      signupResponse.refreshToken,
    ); // Store refresh token

    await userProfileLocalDs.cache(
      signupResponse.user.toHiveModel(),
    ); // Cache user profile

    return signupResponse;
  }

  Future<RefreshResponse> refresh() async {
    final refreshToken = await localStorage.getRefreshToken();

    if (refreshToken == null) {
      throw const UnauthenticatedException();
    }

    try {
      final response = await remoteDs.refresh(refreshToken: refreshToken);

      await localStorage.storeRefreshToken(response.refreshToken);

      return response;
    } on UnauthorizedException catch (_) {
      await localStorage.deleteRefreshToken();

      throw const UnauthenticatedException();
    }
  }

 Future<void> logout({
    String? accessToken,
    required void Function(String token) onTokenRefreshed,
  }) async {
    if (accessToken == null) {
      accessToken = await _refreshIfNeeded();
      onTokenRefreshed(accessToken);
    }

    final refreshToken = await localStorage.getRefreshToken();

    if (refreshToken == null) {
      await userProfileLocalDs.clear(); // clear profile cache
      return;
    }

    try {
      await remoteDs.logout(
        refreshToken: refreshToken,
        accessToken: accessToken,
      );
    } finally {
      // Always clear local data, even if the API fails.
      await localStorage.deleteRefreshToken();
      await userProfileLocalDs.clear();
    }
  }

  Future<UserProfile> getMe({
    String? accessToken,
    required void Function(String token) onTokenRefreshed,
  }) async {
    if (accessToken == null) {
      final token = await _refreshIfNeeded();
      accessToken = token;
      onTokenRefreshed(token); // pass to provider to store
    }

    try {
      final user = await remoteDs.getMe(accessToken: accessToken);
      debugPrint(user.username.toString());

      await userProfileLocalDs.cache(user.toHiveModel()); // Cache user profile

      return user;
    } on UnauthorizedException catch (_) {
      // accesstoken expired
      accessToken = await _refreshIfNeeded();
      onTokenRefreshed(accessToken);

      final user = await remoteDs.getMe(accessToken: accessToken);

      await userProfileLocalDs.cache(user.toHiveModel());

      return user;
    }
  }

  Future<String> _refreshIfNeeded() async {
    debugPrint("Refreshing access_token");
    final response = await refresh();

    return response.accessToken;
  }
}
