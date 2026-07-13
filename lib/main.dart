import 'package:auth_frontend/core/keys/app_keys.dart';
import 'package:auth_frontend/core/providers/deep_link_provider.dart';
import 'package:auth_frontend/features/auth/data/models/user_hive_model.dart';
import 'package:auth_frontend/features/auth/presentation/pages/auth_page.dart';
import 'package:auth_frontend/features/auth/presentation/pages/home_page.dart';
import 'package:auth_frontend/features/auth/presentation/pages/reset_password.dart';
import 'package:auth_frontend/features/auth/presentation/providers/session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_ce_flutter/adapters.dart';

void main() async {
  await Hive.initFlutter();

  Hive.registerAdapter(UserProfileHiveAdapter());

  await Hive.openBox<UserProfileHive>('user_profile');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();

    final deepLinks = ref.read(deepLinkServiceProvider);

    // Handle cold start
    deepLinks.getInitialLink().then((uri) {
      if (uri != null) {
        debugPrint("Uri: $uri");
        _handleUri(uri);
      }
    });

    // Handle app already open
    deepLinks.startListening(onLink: _handleUri);
  }

  void _handleUri(Uri uri) {
    switch (uri.host) {
      case 'reset-password':
        final token = uri.queryParameters['token'];

        if (token == null) return;
        debugPrint("token: $token");

        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => ResetPasswordPage(token: token)),
        );

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(hasValidSessionProvider);
    return MaterialApp(
      title: 'Auth frontend',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: session.when(
        data: (isValid) {
          return isValid ? const HomePage() : const AuthPage();
        },
        loading: () =>
            const Scaffold(body: Center(child: CupertinoActivityIndicator())),
        error: (_, _) => const AuthPage(),
      ),
    );
  }
}
