import 'package:auth_frontend/features/auth/data/datasources/auth_local_storage.dart';
import 'package:auth_frontend/features/auth/data/datasources/auth_remote_ds.dart';
import 'package:auth_frontend/features/auth/data/datasources/user_local_ds.dart';
import 'package:auth_frontend/features/auth/data/models/user_hive_model.dart';
import 'package:auth_frontend/features/auth/data/repos/auth_repository.dart';
import 'package:auth_frontend/features/auth/domain/usecases/session_service.dart';
import 'package:dio/dio.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:riverpod/riverpod.dart';

final dioClientProvider = Provider((ref) {
  return Dio();
});

final authRemoteProvider = Provider<AuthRemoteDs>((ref) {
  final client = ref.read(dioClientProvider);
  const String baseUrl = 'https://auth-backend-ruvv.onrender.com/auth';

  return AuthRemoteDs(client: client, baseUrl: baseUrl);
});

final authLocalStorageProvider = Provider<AuthLocalStorage>((ref) {
  return AuthLocalStorage();
});

final userboxProvider = Provider((ref) {
  return Hive.box<UserProfileHive>('user_profile');
});

final userProfileLocalDsProvider = Provider<UserProfileLocalDs>((ref) {
  final box = ref.read(userboxProvider);
  return UserProfileLocalDs(box);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final localStorage = ref.read(authLocalStorageProvider);
  final remoteDs = ref.read(authRemoteProvider);
  final userProfileLocalDs = ref.read(userProfileLocalDsProvider);

  return AuthRepository(
    localStorage: localStorage,
    remoteDs: remoteDs,
    userProfileLocalDs: userProfileLocalDs,
  );
});

final sessionServiceProvider = Provider<SessionService>((ref) {
  return SessionService(localStorage: ref.watch(authLocalStorageProvider));
});
