import 'dart:async';

import 'package:app_links/app_links.dart';

class DeepLinkService {
  DeepLinkService() : _appLinks = AppLinks();

  final AppLinks _appLinks;

  StreamSubscription<Uri>? _subscription;

  /// Called when the app was launched from a deep link.
  Future<Uri?> getInitialLink() async {
    return _appLinks.getInitialLink();
  }

  /// Listen for links while the app is already running.
  void startListening({
    required void Function(Uri uri) onLink,
    void Function(Object error)? onError,
  }) {
    _subscription?.cancel();

    _subscription = _appLinks.uriLinkStream.listen(onLink, onError: onError);
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
  }
}
