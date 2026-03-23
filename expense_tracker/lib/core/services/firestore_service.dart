import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import '../models/user.dart' as local;
import '../models/transaction.dart' as local;

class FirestoreService {
  final fs.FirebaseFirestore _firestore = fs.FirebaseFirestore.instance;

  fs.CollectionReference get usersCollection => _firestore.collection('users');

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

  Future<void> addExpense(String userId, local.Transaction expense) async {
    final expenses = usersCollection.doc(userId).collection('expenses');
    await expenses.doc(expense.id).set(expense.toMap());
  }

  Future<List<local.Transaction>> getUserExpenses(String userId) async {
    final snapshot = await usersCollection.doc(userId).collection('expenses').get();
    return snapshot.docs.map((d) {
      final data = d.data();
      return local.Transaction.fromMap(data);
    }).toList();
  }

  Stream<List<local.Transaction>> streamUserExpenses(String userId) {
    return usersCollection
        .doc(userId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map((query) => query.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return local.Transaction.fromMap(data);
            })
            .toList());
  }
}
