import 'package:auth_frontend/core/services/deep_links_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deepLinkServiceProvider = Provider((ref) {
  final service = DeepLinkService();

  ref.onDispose(service.dispose);

  return service;
});
