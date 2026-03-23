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
import 'features/auth/widgets/sign_in_screen.dart';
import 'features/auth/widgets/sign_up_screen.dart';
import 'features/auth/providers/auth_providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/sign-in',
    routes: [
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardScreen(),
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
    redirect: (context, state) {
      final signedIn = authState.asData?.value != null;
      final loggingIn = state.matchedLocation == '/sign-in' || state.matchedLocation == '/sign-up';

      if (!signedIn && !loggingIn) return '/sign-in';
      if (signedIn && loggingIn) return '/';
      return null;
    },
  );
});


class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Smart Expense Tracker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}