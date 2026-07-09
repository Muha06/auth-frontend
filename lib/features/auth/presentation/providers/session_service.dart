import 'package:auth_frontend/features/auth/presentation/providers/wiring_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final hasValidSessionProvider = FutureProvider<bool>((ref) async {
  final sessionService = ref.watch(sessionServiceProvider);
  return sessionService.hasValidSession();
});
