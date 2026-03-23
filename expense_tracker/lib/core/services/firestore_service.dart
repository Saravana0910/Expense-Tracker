import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/transaction.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get usersCollection => _firestore.collection('users');

  Future<void> setUser(User user) async {
    await usersCollection.doc(user.id).set(user.toMap());
  }

  Future<User?> getUser(String uid) async {
    final snapshot = await usersCollection.doc(uid).get();
    if (!snapshot.exists) return null;
    return User.fromMap(snapshot.data() as Map<String, dynamic>);
  }

  Future<void> addExpense(String userId, Transaction expense) async {
    final expenses = usersCollection.doc(userId).collection('expenses');
    await expenses.doc(expense.id).set(expense.toMap());
  }

  Future<List<Transaction>> getUserExpenses(String userId) async {
    final snapshot = await usersCollection.doc(userId).collection('expenses').get();
    return snapshot.docs.map((d) {
      final data = d.data() as Map<String, dynamic>;
      return Transaction.fromMap(data);
    }).toList();
  }

  Stream<List<Transaction>> streamUserExpenses(String userId) {
    return usersCollection
        .doc(userId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map((query) =>
            query.docs.map((doc) => Transaction.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }
}
