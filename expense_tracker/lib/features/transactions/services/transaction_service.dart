import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/models/transaction.dart' as local;
import '../../../core/services/firestore_service.dart';

class TransactionService {
  final FirestoreService _firestore = FirestoreService();

  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<List<local.Transaction>> getAllTransactions() async {
    if (currentUserId.isEmpty) return [];
    return _firestore.getUserExpenses(currentUserId);
  }

  Future<List<local.Transaction>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    final all = await getAllTransactions();
    return all.where((t) =>
      !t.date.isBefore(start) && !t.date.isAfter(end)
    ).toList();
  }

  Future<List<local.Transaction>> getTransactionsByCategory(String category) async {
    final all = await getAllTransactions();
    return all.where((t) => t.category == category).toList();
  }

  Future<local.Transaction?> getTransactionById(String id) async {
    final all = await getAllTransactions();
    try {
      return all.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addTransaction(local.Transaction transaction) async {
    await _firestore.addExpense(currentUserId, transaction);
  }

  Future<void> updateTransaction(local.Transaction transaction) async {
    await _firestore.addExpense(currentUserId, transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await _firestore.deleteExpense(currentUserId, id);
  }

  Future<double> getTotalSpent() async {
    final transactions = await getAllTransactions();
    return transactions.fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  Future<double> getMonthlySpent(DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    final transactions = await getTransactionsByDateRange(start, end);
    return transactions.fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  Future<Map<String, double>> getCategorySpending() async {
    final transactions = await getAllTransactions();
    final Map<String, double> categorySpending = {};
    for (final t in transactions) {
      categorySpending[t.category] = (categorySpending[t.category] ?? 0) + t.amount;
    }
    return categorySpending;
  }
}