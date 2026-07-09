import 'package:auth_frontend/features/auth/data/models/user_hive_model.dart';
import 'package:auth_frontend/features/auth/presentation/pages/auth_page.dart';
import 'package:auth_frontend/features/auth/presentation/pages/home_page.dart';
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

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, ref) {
    final session = ref.watch(hasValidSessionProvider);
    return MaterialApp(
      title: 'Auth frontend',
      debugShowCheckedModeBanner: false,
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
