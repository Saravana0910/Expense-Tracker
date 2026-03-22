import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DebugScreen extends ConsumerWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Info'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Debug Information',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('If you see this screen, basic Flutter setup is working!'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go to Dashboard'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/add-transaction'),
              child: const Text('Go to Add Transaction'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/transactions'),
              child: const Text('Go to Transactions'),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade100,
              child: const Text(
                'Check device logs for any error messages.\n'
                'If the main screens show black, there might be an issue with:\n'
                '1. Database initialization\n'
                '2. Provider setup\n'
                '3. Theme configuration\n'
                '4. Screen rendering',
                style: TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}