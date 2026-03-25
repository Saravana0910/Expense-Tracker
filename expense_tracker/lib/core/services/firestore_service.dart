import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import '../models/user.dart' as local;
import '../models/transaction.dart' as local;
import '../models/budget.dart';

class FirestoreService {
  final fs.FirebaseFirestore _firestore = fs.FirebaseFirestore.instance;

  fs.CollectionReference get usersCollection => _firestore.collection('users');

  // ── User ─────────────────────────────────────────────────────────────────

  Future<void> setUser(local.User user) async {
    await usersCollection.doc(user.id).set(user.toMap());
  }

  Future<local.User?> getUser(String uid) async {
    final snapshot = await usersCollection.doc(uid).get();
    if (!snapshot.exists) return null;
    final data = snapshot.data() as Map<String, dynamic>?;
    if (data == null) return null;
    return local.User.fromMap(data);
  }

  // ── Transactions ──────────────────────────────────────────────────────────

  Future<void> addExpense(String userId, local.Transaction expense) async {
    final expenses = usersCollection.doc(userId).collection('expenses');
    await expenses.doc(expense.id).set(expense.toMap());
  }

  Future<void> deleteExpense(String userId, String expenseId) async {
    await usersCollection
        .doc(userId)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }

  Future<List<local.Transaction>> getUserExpenses(String userId) async {
    final snapshot =
        await usersCollection.doc(userId).collection('expenses').get();
    return snapshot.docs
        .map((d) => local.Transaction.fromMap(d.data()))
        .toList();
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

  // ── Budgets ───────────────────────────────────────────────────────────────

  Future<void> setBudget(Budget budget) async {
    await usersCollection
        .doc(budget.userId)
        .collection('budgets')
        .doc(budget.id)
        .set(budget.toMap());
  }

  Future<Budget?> getBudgetForMonth(
      String userId, int year, int month) async {
    final snapshot = await usersCollection
        .doc(userId)
        .collection('budgets')
        .where('userId', isEqualTo: userId)
        .get();

    final all = snapshot.docs.map((d) => Budget.fromMap(d.data())).toList();
    try {
      return all.firstWhere(
          (b) => b.month.year == year && b.month.month == month);
    } catch (_) {
      return null;
    }
  }

  Future<List<Budget>> getAllBudgets(String userId) async {
    final snapshot =
        await usersCollection.doc(userId).collection('budgets').get();
    return snapshot.docs.map((d) => Budget.fromMap(d.data())).toList();
  }
}
