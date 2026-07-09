import 'package:auth_frontend/features/auth/data/models/user_hive_model.dart';
import 'package:hive_ce/hive.dart';

class UserProfileLocalDs {
  final Box<UserProfileHive> box;

  UserProfileLocalDs(this.box);

  Future<void> cache(UserProfileHive profile) async {
    await box.put('profile', profile);
  }

  UserProfileHive? getCached() {
    return box.get('profile');
  }

  Future<void> clear() async {
    await box.clear();
  }

  Future<void> replace(UserProfileHive profile) async {
    await clear();

    await cache(profile);
  }
}
