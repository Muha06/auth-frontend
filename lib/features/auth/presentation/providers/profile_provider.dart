import 'package:auth_frontend/features/auth/domain/entities/user.dart';
import 'package:auth_frontend/features/auth/presentation/providers/auth_notifier.dart';
import 'package:auth_frontend/features/auth/presentation/providers/wiring_providers.dart';
import 'package:riverpod/riverpod.dart';

final profileProvider = AsyncNotifierProvider<UserProfileProvider, UserProfile>(
  UserProfileProvider.new,
);

class UserProfileProvider extends AsyncNotifier<UserProfile> {
  @override
  Future<UserProfile> build() async {
    final localDs = ref.read(userProfileLocalDsProvider);

    final profile = localDs.getCached();

    if (profile == null) {
      throw Exception('No cached user profile found.');
    }

    return profile.toEntity();
  }

  Future<void> refreshProfile() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      return await ref.read(authProvider.notifier).getMe();
    });
  }
}
