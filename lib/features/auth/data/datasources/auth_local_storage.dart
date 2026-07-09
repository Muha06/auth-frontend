import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthLocalStorage {
  AuthLocalStorage();

  static const _storage = FlutterSecureStorage();

  static const _refreshTokenKey = 'refresh_token';

  Future<void> storeRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);

    debugPrint("cache wrote $token");
  }

  Future<String?> getRefreshToken() async {
    final token = await _storage.read(key: _refreshTokenKey);

    if (token != null) debugPrint("cache hit $token");

    return token;
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
    debugPrint("deleted cached refresh_token");
  }
}
