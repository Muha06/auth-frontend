import 'package:auth_frontend/features/auth/data/models/login_response.dart';
import 'package:auth_frontend/features/auth/domain/entities/user.dart';

class SignupResponse extends LoginResponse {
  SignupResponse({
    required super.accessToken,
    required super.refreshToken,
    required super.user,
  });

  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    return SignupResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      user: UserProfile.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
