import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/transaction.dart';
import '../../../core/services/database_service.dart';

class TransactionService {
  final DatabaseService _db = DatabaseService();

  Future<List<Transaction>> getAllTransactions() async {
    final box = _db.transactionsBox;
    return box.values.where((t) => t.userId == AppConstants.defaultUserId).toList();
  }

  Future<List<Transaction>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    final all = await getAllTransactions();
    return all.where((t) => t.date.isAfter(start.subtract(const Duration(days: 1))) && t.date.isBefore(end.add(const Duration(days: 1)))).toList();
  }

  Future<List<Transaction>> getTransactionsByCategory(String category) async {
    final all = await getAllTransactions();
    return all.where((t) => t.category == category).toList();
  }

  Future<Transaction?> getTransactionById(String id) async {
    final box = _db.transactionsBox;
    return box.get(id);
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
      userId: AppConstants.defaultUserId,
    );

    final box = _db.transactionsBox;
    await box.put(transaction.id, transaction);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final box = _db.transactionsBox;
    await box.put(transaction.id, transaction);
  }

  Future<void> deleteTransaction(String id) async {
    final box = _db.transactionsBox;
    await box.delete(id);
  }

  Future<double> getTotalSpent() async {
    final transactions = await getAllTransactions();
    return transactions.fold(0.0, (sum, t) => sum + t.amount);
  }

  Future<double> getMonthlySpent(DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);
    final transactions = await getTransactionsByDateRange(start, end);
    return transactions.fold(0.0, (sum, t) => sum + t.amount);
  }

  Future<Map<String, double>> getCategorySpending() async {
    final transactions = await getAllTransactions();
    final Map<String, double> categorySpending = {};

    for (final transaction in transactions) {
      categorySpending[transaction.category] = (categorySpending[transaction.category] ?? 0) + transaction.amount;
    }

    return categorySpending;
  }
}