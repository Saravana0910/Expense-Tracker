import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import '../models/user.dart' as local;
import '../models/transaction.dart' as local;
import '../models/budget.dart' as local;
import '../utils/retry_with_backoff.dart';

class FirestoreService {
  final fs.FirebaseFirestore _firestore = fs.FirebaseFirestore.instance;

  fs.CollectionReference get usersCollection => _firestore.collection('users');

  Future<void> setUser(local.User user) async {
    await RetryHelper.retry(
      operation: () => usersCollection.doc(user.id).set(user.toMap()),
      maxRetries: 3,
      initialDelayMs: 100,
    );
  }

  Future<local.User?> getUser(String uid) async {
    return await RetryHelper.retry(
      operation: () async {
        final snapshot = await usersCollection.doc(uid).get();
        if (!snapshot.exists) return null;
        final data = snapshot.data() as Map<String, dynamic>?;
        if (data == null) return null;
        return local.User.fromMap(data);
      },
      maxRetries: 4,
      initialDelayMs: 200,
      maxDelayMs: 8000,
    );
  }

  Future<void> addExpense(String userId, local.Transaction expense) async {
    await RetryHelper.retry(
      operation: () async {
        final expenses = usersCollection.doc(userId).collection('expenses');
        await expenses.doc(expense.id).set(expense.toMap());
      },
      maxRetries: 3,
      initialDelayMs: 100,
    );
  }

  Future<void> deleteExpense(String userId, String expenseId) async {
    await usersCollection.doc(userId).collection('expenses').doc(expenseId).delete();
  }

  Future<List<local.Transaction>> getUserExpenses(String userId) async {
    return await RetryHelper.retry(
      operation: () async {
        final snapshot = await usersCollection
            .doc(userId)
            .collection('expenses')
            .orderBy('date', descending: true)
            .get();
        return snapshot.docs.map((d) => local.Transaction.fromMap(d.data())).toList();
      },
      maxRetries: 3,
      initialDelayMs: 100,
    );
  }

  Stream<List<local.Transaction>> streamUserExpenses(String userId) {
    return usersCollection
        .doc(userId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map((query) => query.docs
            .map((doc) => local.Transaction.fromMap(doc.data()))
            .toList());
  }

  // ── Budget ─────────────────────────────────────────────────────────────────

  Future<void> setBudget(local.Budget budget) async {
    await usersCollection
        .doc(budget.userId)
        .collection('budgets')
        .doc(budget.id)
        .set(budget.toMap());
  }

  Future<local.Budget?> getBudgetForMonth(String userId, DateTime month) async {
    final start = fs.Timestamp.fromDate(DateTime(month.year, month.month, 1).toUtc());
    final end = fs.Timestamp.fromDate(DateTime(month.year, month.month + 1, 1).toUtc());
    final snapshot = await usersCollection
        .doc(userId)
        .collection('budgets')
        .where('month', isGreaterThanOrEqualTo: start)
        .where('month', isLessThan: end)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return local.Budget.fromMap(snapshot.docs.first.data());
  }
}
