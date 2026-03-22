import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/themes/app_theme.dart';
import 'features/dashboard/widgets/dashboard_screen.dart';
import 'features/transactions/widgets/add_transaction_screen.dart';
import 'features/transactions/widgets/transactions_list_screen.dart';
import 'features/analytics/widgets/analytics_screen.dart';
import 'features/budget/widgets/budget_screen.dart';
import 'features/auth/widgets/profile_screen.dart';
import 'features/debug/widgets/debug_screen.dart';

final _router = GoRouter(
  initialLocation: '/debug', // Start with debug screen to test basic functionality
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/debug',
      builder: (context, state) => const DebugScreen(),
    ),
    GoRoute(
      path: '/add-transaction',
      builder: (context, state) => const AddTransactionScreen(),
    ),
    GoRoute(
      path: '/transactions',
      builder: (context, state) => const TransactionsListScreen(),
    ),
    GoRoute(
      path: '/analytics',
      builder: (context, state) => const AnalyticsScreen(),
    ),
    GoRoute(
      path: '/budget',
      builder: (context, state) => const BudgetScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  Widget build(BuildContext context) {
    try {
      return MaterialApp.router(
        title: 'Smart Expense Tracker',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      );
    } catch (e, stackTrace) {
      debugPrint('App build error: $e');
      debugPrint('Stack trace: $stackTrace');
      // Fallback UI in case of build errors
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Expense Tracker')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('App Error: $e'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}