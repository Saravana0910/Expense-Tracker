import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import '../models/user.dart' as local;
import '../models/transaction.dart' as local;
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

  Future<List<local.Transaction>> getUserExpenses(String userId) async {
    return await RetryHelper.retry(
      operation: () async {
        final snapshot = await usersCollection.doc(userId).collection('expenses').get();
        return snapshot.docs.map((d) {
          final data = d.data();
          return local.Transaction.fromMap(data);
        }).toList();
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
}
