import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';

class AccessTokenNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setToken(String token) {
    debugPrint("Storing access_token");
    state = token;
  }

  void clear() {
    debugPrint("clearing access_token");
    state = null;
  }
}

final accessTokenProvider = NotifierProvider<AccessTokenNotifier, String?>(
  () => AccessTokenNotifier(),
);
