import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import '../../features/transactions/services/transaction_service.dart';
import '../../features/auth/services/user_service.dart';
import '../../features/budget/services/budget_service.dart';
import 'notifiers.dart';
import '../../core/models/transaction.dart';
import '../../core/models/user.dart';
import '../../core/models/budget.dart';

// Database
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

// Services
final transactionServiceProvider = Provider<TransactionService>((ref) {
  return TransactionService();
});

final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

final budgetServiceProvider = Provider<BudgetService>((ref) {
  return BudgetService();
});

// State Notifiers
final transactionsProvider = StateNotifierProvider<TransactionsNotifier, AsyncValue<List<Transaction>>>((ref) {
  final service = ref.watch(transactionServiceProvider);
  return TransactionsNotifier(service);
});

final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<User?>>((ref) {
  final service = ref.watch(userServiceProvider);
  return UserNotifier(service);
});

final budgetProvider = StateNotifierProvider<BudgetNotifier, AsyncValue<Budget?>>((ref) {
  final service = ref.watch(budgetServiceProvider);
  return BudgetNotifier(service);
});

// Computed providers
final totalSpentProvider = Provider<AsyncValue<double>>((ref) {
  return ref.watch(transactionsProvider).whenData((transactions) {
    return transactions.fold(0.0, (sum, t) => sum + t.amount);
  });
});

final categorySpendingProvider = Provider<AsyncValue<Map<String, double>>>((ref) {
  return ref.watch(transactionsProvider).whenData((transactions) {
    final Map<String, double> spending = {};
    for (final transaction in transactions) {
      spending[transaction.category] = (spending[transaction.category] ?? 0) + transaction.amount;
    }
    return spending;
  });
});

final monthlySpentProvider = Provider.family<AsyncValue<double>, DateTime>((ref, month) {
  return ref.watch(transactionsProvider).whenData((transactions) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);
    final monthlyTransactions = transactions.where((t) =>
      t.date.isAfter(start.subtract(const Duration(days: 1))) &&
      t.date.isBefore(end.add(const Duration(days: 1)))
    ).toList();
    return monthlyTransactions.fold(0.0, (sum, t) => sum + t.amount);
  });
});