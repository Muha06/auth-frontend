import 'package:auth_frontend/features/auth/domain/entities/user.dart';
import 'package:auth_frontend/features/auth/presentation/providers/access_token.dart';
import 'package:auth_frontend/features/auth/presentation/providers/wiring_providers.dart';
import 'package:riverpod/riverpod.dart';
import 'package:auth_frontend/features/auth/data/repos/auth_repository.dart';

class AuthState {
  final bool isLoading;
  final String? error;

  const AuthState({this.isLoading = false, this.error});

  AuthState copyWith({bool? isLoading, String? error}) {
    return AuthState(isLoading: isLoading ?? this.isLoading, error: error);
  }
}

class AuthNotifier extends Notifier<AuthState> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  AuthState build() {
    return const AuthState();
  }

  Future<void> login({required String email, required String password}) async {
    state = const AuthState(isLoading: true);

    try {
      final loginResponse = await _repository.login(
        email: email,
        password: password,
      );

      // cache access token
      ref
          .read(accessTokenProvider.notifier)
          .setToken(loginResponse.accessToken);

      state = const AuthState();
    } catch (e) {
      state = AuthState(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> signup({
    required String email,
    required String username,
    required String hobby,
    required String password,
  }) async {
    state = const AuthState(isLoading: true);

    try {
      final signupResponse = await _repository.signup(
        email: email,
        username: username,
        hobby: hobby,
        password: password,
      );

      // cache access token
      ref
          .read(accessTokenProvider.notifier)
          .setToken(signupResponse.accessToken);

      state = const AuthState();
    } catch (e) {
      state = AuthState(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> refresh() async {
    final tokens = await _repository.refresh();

    // cache access token
    ref.read(accessTokenProvider.notifier).setToken(tokens.accessToken);
  }

  Future<void> logout() async {
    final accessToken = ref.read(accessTokenProvider);

    try {
      await _repository.logout(
        accessToken: accessToken,
        onTokenRefreshed: (token) =>
            ref.read(accessTokenProvider.notifier).setToken(token),
      );
    } finally {
      // Always clear it.
      ref.read(accessTokenProvider.notifier).clear();
    }
  }

  Future<UserProfile> getMe() async {
    final accessToken = ref.read(accessTokenProvider); // For authorization

    return await _repository.getMe(
      accessToken: accessToken,
      onTokenRefreshed: (token) =>
          ref.read(accessTokenProvider.notifier).setToken(token),
    );
  }
}

final authProvider = NotifierProvider(() => AuthNotifier());
