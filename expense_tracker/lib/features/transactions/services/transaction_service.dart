import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/models/transaction.dart' as local;
import '../../../core/services/firestore_service.dart';

class TransactionService {
  final FirestoreService _firestore = FirestoreService();

  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  Stream<List<local.Transaction>> streamTransactions() {
    if (currentUserId.isEmpty) return const Stream.empty();
    return _firestore.streamUserExpenses(currentUserId);
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
}
