import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/budget.dart';
import '../../../core/services/firestore_service.dart';

class BudgetService {
  final FirestoreService _firestore = FirestoreService();

  String get currentUserId =>
      FirebaseAuth.instance.currentUser?.uid ?? AppConstants.defaultUserId;

  Future<Budget?> getCurrentMonthBudget(DateTime month) async {
    return await _firestore.getBudgetForMonth(
        currentUserId, month.year, month.month);
  }

  Future<void> setMonthlyBudget(double amount, DateTime month) async {
    final existing = await getCurrentMonthBudget(month);
    final budget = Budget(
      id: existing?.id ?? const Uuid().v4(),
      amount: amount,
      month: DateTime(month.year, month.month, 1),
      userId: currentUserId,
    );
    await _firestore.setBudget(budget);
  }

  Future<List<Budget>> getAllBudgets() async {
    return await _firestore.getAllBudgets(currentUserId);
  }
}
