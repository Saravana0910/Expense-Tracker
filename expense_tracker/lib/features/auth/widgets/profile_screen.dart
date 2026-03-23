import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await ref.read(authServiceProvider).signOut();
                if (context.mounted) {
                  context.go('/sign-in');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logout failed: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: currentUserAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (user) {
          if (user == null) {
            return Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/sign-in');
                },
                child: const Text('Not signed in? Tap to login'),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 50,
                  child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U'),
                ),
                const SizedBox(height: 16),
                Text('Name: ${user.name}', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('Username: ${user.username}', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 8),
                Text('Email: ${user.email}', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 8),
                Text('Joined: ${user.createdAt.toLocal()}'.split('.').first, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          );
        },
      ),
    );
  }
}
