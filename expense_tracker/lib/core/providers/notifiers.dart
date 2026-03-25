import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import '../models/budget.dart';
import '../../features/transactions/services/transaction_service.dart';
import '../../features/auth/services/user_service.dart';
import '../../features/budget/services/budget_service.dart';

class TransactionsNotifier extends StateNotifier<AsyncValue<List<Transaction>>> {
  final TransactionService _service;
  StreamSubscription<List<Transaction>>? _sub;

  TransactionsNotifier(this._service) : super(const AsyncValue.loading()) {
    _subscribe();
  }

  void _subscribe() {
    _sub?.cancel();
    _sub = _service.streamTransactions().listen(
      (transactions) => state = AsyncValue.data(transactions),
      onError: (e, stack) => state = AsyncValue.error(e, stack),
    );
  }

  Future<void> addTransaction({
    required double amount,
    required String category,
    required DateTime date,
    String? notes,
    required String paymentMethod,
  }) async {
    final transaction = Transaction(
      id: const Uuid().v4(),
      amount: amount,
      category: category,
      date: date,
      notes: notes,
      paymentMethod: paymentMethod,
      userId: _service.currentUserId,
    );
    await _service.addTransaction(transaction);
    // Stream will automatically update state
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _service.updateTransaction(transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await _service.deleteTransaction(id);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
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
      final existing = state.value;
      final user = User(
        id: _service.currentUserId,
        email: existing?.email ?? '',
        username: name,
        name: name,
        avatarPath: avatarPath,
        createdAt: existing?.createdAt ?? DateTime.now(),
      );

      await _service.createOrUpdateUser(user: user);
      state = AsyncValue.data(user);
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
      final existing = await _service.getCurrentMonthBudget(month);
      final budget = Budget(
        id: existing?.id ?? const Uuid().v4(),
        amount: amount,
        month: DateTime(month.year, month.month, 1),
        userId: _service.currentUserId,
      );

      await _service.setMonthlyBudget(amount, month);
      state = AsyncValue.data(budget);
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
      final existing = state.value;
      final user = User(
        id: _service.currentUserId,
        email: existing?.email ?? '',
        username: name,
        name: name,
        avatarPath: avatarPath,
        createdAt: existing?.createdAt ?? DateTime.now(),
      );

      await _service.createOrUpdateUser(user: user);
      state = AsyncValue.data(user);
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
      final existing = await _service.getCurrentMonthBudget(month);
      final budget = Budget(
        id: existing?.id ?? const Uuid().v4(),
        amount: amount,
        month: DateTime(month.year, month.month, 1),
        userId: _service.currentUserId,
      );

      await _service.setMonthlyBudget(amount, month);
      state = AsyncValue.data(budget);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}