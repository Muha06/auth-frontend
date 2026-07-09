import 'package:auth_frontend/features/auth/data/datasources/auth_local_storage.dart';
import 'package:flutter/rendering.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class SessionService {
  final AuthLocalStorage localStorage;

  SessionService({required this.localStorage});

  Future<bool> hasValidSession() async {
    // find refreshtoken in storage
    final token = await localStorage.getRefreshToken();

    if (token == null) { 
      return false;
    }

    // check expiry
    try {
      final isExpired = JwtDecoder.isExpired(token);

      if (isExpired) {
        await localStorage.deleteRefreshToken();
        debugPrint("Expired");

        return false;
      }
    } catch (e) {
      await localStorage.deleteRefreshToken();
      debugPrint("Expired");

      return false;
    }

    return true;
  }
}
