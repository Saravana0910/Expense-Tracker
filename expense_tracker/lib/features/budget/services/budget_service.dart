import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/budget.dart';
import '../../../core/services/firestore_service.dart';

class BudgetService {
  final FirestoreService _firestore = FirestoreService();

  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<Budget?> getCurrentMonthBudget(DateTime month) async {
    if (currentUserId.isEmpty) return null;
    return _firestore.getBudgetForMonth(currentUserId, month);
  }

  Future<void> setMonthlyBudget(double amount, DateTime month) async {
    if (currentUserId.isEmpty) return;
    final existing = await getCurrentMonthBudget(month);
    final budget = Budget(
      id: existing?.id ?? const Uuid().v4(),
      amount: amount,
      month: DateTime(month.year, month.month, 1),
      userId: currentUserId,
    );
    await _firestore.setBudget(budget);
  }
}