import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import '../models/budget.dart';
import '../../features/transactions/services/transaction_service.dart';
import '../../features/auth/services/user_service.dart';
import '../../features/budget/services/budget_service.dart';

class TransactionsNotifier extends StateNotifier<AsyncValue<List<Transaction>>> {
  final TransactionService _service;

  TransactionsNotifier(this._service) : super(const AsyncValue.loading()) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    state = const AsyncValue.loading();
    try {
      final transactions = await _service.getAllTransactions();
      state = AsyncValue.data(transactions);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addTransaction({
    required double amount,
    required String category,
    required DateTime date,
    String? notes,
    required String paymentMethod,
  }) async {
    try {
      final newTransaction = await _service.addTransaction(
        amount: amount,
        category: category,
        date: date,
        notes: notes,
        paymentMethod: paymentMethod,
      );
      state = state.whenData((transactions) => [...transactions, newTransaction]);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _service.updateTransaction(transaction);
      state = state.whenData((transactions) =>
        transactions.map((t) => t.id == transaction.id ? transaction : t).toList());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _service.deleteTransaction(id);
      state = state.whenData((transactions) =>
        transactions.where((t) => t.id != id).toList());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

class UserNotifier extends StateNotifier<AsyncValue<User?>> {
  final UserService _service;

  UserNotifier(this._service) : super(const AsyncValue.loading()) {
    loadUser();
  }

  Future<void> loadUser() async {
    state = const AsyncValue.loading();
    try {
      final user = await _service.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createOrUpdateUser({
    required String name,
    String? avatarPath,
  }) async {
    try {
      final updatedUser = await _service.createOrUpdateUser(name: name, avatarPath: avatarPath);
      state = AsyncValue.data(updatedUser);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

class BudgetNotifier extends StateNotifier<AsyncValue<Budget?>> {
  final BudgetService _service;

  BudgetNotifier(this._service) : super(const AsyncValue.loading()) {
    loadCurrentBudget();
  }

  Future<void> loadCurrentBudget([DateTime? month]) async {
    state = const AsyncValue.loading();
    try {
      final budget = await _service.getCurrentMonthBudget(month ?? DateTime.now());
      state = AsyncValue.data(budget);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> setMonthlyBudget(double amount, DateTime month) async {
    try {
      final updatedBudget = await _service.setMonthlyBudget(amount, month);
      state = AsyncValue.data(updatedBudget);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}