import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'core/themes/app_theme.dart';
import 'core/providers/providers.dart';
import 'features/dashboard/widgets/dashboard_screen.dart';
import 'features/transactions/widgets/add_transaction_screen.dart';
import 'features/transactions/widgets/transactions_list_screen.dart';
import 'features/analytics/widgets/analytics_screen.dart';
import 'features/budget/widgets/budget_screen.dart';
import 'features/auth/widgets/profile_screen.dart';
import 'features/auth/widgets/sign_in_screen.dart';
import 'features/auth/widgets/sign_up_screen.dart';
import 'features/auth/providers/auth_providers.dart';

/// Bridges Riverpod auth state into a [ChangeNotifier] that GoRouter can
/// listen to via [refreshListenable]. This ensures the GoRouter instance is
/// created ONCE and only its redirect logic is re-evaluated on auth changes.
class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  // Set to true if auth state hasn't resolved within 15 seconds.
  // Prevents the loading screen from being shown indefinitely.
  bool _authTimedOut = false;

  _RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<fb.User?>>(authStateProvider, (prev, next) {
      // When a user just signed in, invalidate stale data providers so they
      // reload with the correct userId.
      final wasSignedOut = prev?.asData?.value == null;
      final isSignedIn = next.asData?.value != null;
      if (wasSignedOut && isSignedIn) {
        _ref.invalidate(transactionsProvider);
        _ref.invalidate(budgetProvider);
        _ref.invalidate(userProvider);
      }
      notifyListeners();
    });

    // Safety valve: if Firebase auth hasn't emitted within 15 s (e.g. because
    // Firebase could not be initialised), stop showing the loading screen and
    // fall through to sign-in so the user isn't stuck forever.
    Future.delayed(const Duration(seconds: 15), () {
      final authAsync = _ref.read(authStateProvider);
      if (authAsync.isLoading) {
        _authTimedOut = true;
        notifyListeners();
      }
    });
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authAsync = _ref.read(authStateProvider);
    final loc = state.matchedLocation;

    // While Firebase determines auth state, show the loading screen —
    // unless we have timed out waiting for it.
    if (authAsync.isLoading && !_authTimedOut) {
      return loc == '/loading' ? null : '/loading';
    }

    // Firebase auth error (bad credentials, network failure) or timeout:
    // treat as signed-out and send the user to sign-in.
    if (authAsync.hasError || _authTimedOut) {
      if (loc == '/sign-in' || loc == '/sign-up') return null;
      return '/sign-in';
    }

    final signedIn = authAsync.asData?.value != null;
    final onAuthPage = loc == '/sign-in' || loc == '/sign-up';
    final onLoadingPage = loc == '/loading';

    if (signedIn && (onAuthPage || onLoadingPage)) return '/';
    if (!signedIn && !onAuthPage) return '/sign-in';
    return null;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  return GoRouter(
    initialLocation: '/loading',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/loading',
        builder: (context, state) => const _LoadingScreen(),
      ),
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
  );
});

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Expense Tracker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}