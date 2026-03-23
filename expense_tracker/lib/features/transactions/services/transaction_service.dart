import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/transaction.dart' as local;
import '../../../core/services/firestore_service.dart';
import '../../../core/services/hive_service.dart';

class TransactionService {
  final HiveService _hive = HiveService();
  final FirestoreService _firestore = FirestoreService();
  final Connectivity _connectivity = Connectivity();

  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? AppConstants.defaultUserId;

  Future<bool> get isOnline async {
    final status = await _connectivity.checkConnectivity();
    return status != ConnectivityResult.none;
  }

  Future<List<local.Transaction>> getAllTransactions() async {
    final box = HiveService().transactionsBox;
    return box.values.where((t) => t.userId == currentUserId).cast<local.Transaction>().toList();
  }

  Future<List<local.Transaction>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    final all = await getAllTransactions();
    return all.where((t) => t.date.isAfter(start.subtract(const Duration(days: 1))) && t.date.isBefore(end.add(const Duration(days: 1)))).toList();
  }

  Future<List<local.Transaction>> getTransactionsByCategory(String category) async {
    final all = await getAllTransactions();
    return all.where((t) => t.category == category).toList();
  }

  Future<local.Transaction?> getTransactionById(String id) async {
    final box = HiveService().transactionsBox;
    return box.get(id);
  }

  Future<void> addTransaction({
    required double amount,
    required String category,
    required DateTime date,
    String? notes,
    required String paymentMethod,
  }) async {
    final transaction = local.Transaction(
      id: const Uuid().v4(),
      amount: amount,
      category: category,
      date: date,
      notes: notes,
      paymentMethod: paymentMethod,
      userId: currentUserId,
    );

    final box = _hive.transactionsBox;
    await box.put(transaction.id, transaction);

    if (await isOnline) {
      await _firestore.addExpense(currentUserId, transaction);
      await _hive.removeUnsyncedExpense(transaction.id);
    } else {
      await _hive.addUnsyncedExpense(transaction);
    }
  }

  Future<void> updateTransaction(local.Transaction transaction) async {
    final box = _hive.transactionsBox;
    await box.put(transaction.id, transaction);

    if (await isOnline) {
      await _firestore.addExpense(currentUserId, transaction);
      await _hive.removeUnsyncedExpense(transaction.id);
    } else {
      await _hive.addUnsyncedExpense(transaction);
    }
  }

  Future<void> deleteTransaction(String id) async {
    final box = _hive.transactionsBox;
    await box.delete(id);
    final expensesRef = _firestore.usersCollection.doc(currentUserId).collection('expenses');
    await expensesRef.doc(id).delete().catchError((_) {});
  }

  Future<void> syncFromCloud() async {
    if (!await isOnline) return;

    final cloudExpenses = await _firestore.getUserExpenses(currentUserId);
    final box = _hive.transactionsBox;
    for (var expense in cloudExpenses) {
      await box.put(expense.id, expense);
    }

    final unsynced = await _hive.getUnsyncedExpenses(currentUserId);
    for (var expense in unsynced) {
      try {
        await _firestore.addExpense(currentUserId, expense);
        await _hive.removeUnsyncedExpense(expense.id);
      } catch (_) {
        // keep in unsynced for retry
      }
    }
  }

  Future<double> getTotalSpent() async {
    final transactions = await getAllTransactions();
    return transactions.fold<double>(0.0, (double sum, local.Transaction t) => sum + t.amount);
  }

  Future<double> getMonthlySpent(DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);
    final transactions = await getTransactionsByDateRange(start, end);
    return transactions.fold<double>(0.0, (double sum, local.Transaction t) => sum + t.amount);
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