import 'package:auth_frontend/core/helpers/navigation.dart';
import 'package:auth_frontend/core/helpers/snackbars.dart';
import 'package:auth_frontend/features/auth/presentation/pages/auth_page.dart';
import 'package:auth_frontend/features/auth/presentation/providers/auth_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => const _UserSettingsSheet(),
              );
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(children: [UserCard()]),
      ),
    );
  }
}

class _UserSettingsSheet extends ConsumerWidget {
  const _UserSettingsSheet();

  @override
  Widget build(BuildContext context, ref) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.4, // starts at 40%
      minChildSize: 0.3, // can't go below 30%
      maxChildSize: 0.9, // up to 90%
      builder: (context, controller) {
        return ListView(
          controller: controller,
          children: [
            ActionTile(
              title: 'Refresh Profile',
              onTap: () => ref.read(profileProvider.notifier).refreshProfile(),
            ),

            ActionTile(
              title: 'Logout',
              onTap: () async {
                try {
                  await ref.read(authProvider.notifier).logout();
                  AppNavigator.pushReplacement(context, const AuthPage());
                } catch (e) {
                  AppSnackBar.error(context, "Failed to logout.");
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class ActionTile extends StatelessWidget {
  const ActionTile({
    super.key,
    required this.title,
    required this.onTap,
    this.leading,
    this.trailing,
  });

  final String title;
  final VoidCallback onTap;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: Text(title),
      trailing:
          trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 18),
      onTap: onTap,
    );
  }
}

class UserCard extends ConsumerWidget {
  const UserCard({super.key});
  @override
  Widget build(BuildContext context, ref) {
    final userProfile = ref.watch(profileProvider);

    return userProfile.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          error.toString(),
          style: const TextStyle(color: Colors.red),
        ),
      ),
      data: (user) {
        debugPrint("ui ${user.username}");

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 32,
                  child: Text(
                    user.username[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(user.email),
                      const SizedBox(height: 6),
                      Text("Hobby: ${user.hobby}"),
                      const SizedBox(height: 12),
                      Text(
                        "Joined ${user.createdAt.toLocal().toString().split(' ').first}",
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
