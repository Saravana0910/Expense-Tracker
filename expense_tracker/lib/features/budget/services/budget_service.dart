import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/budget.dart';
import '../../../core/services/database_service.dart';

class BudgetService {
  final DatabaseService _db = DatabaseService();

  Future<Budget?> getCurrentMonthBudget(DateTime month) async {
    final box = _db.budgetsBox;
    final budgets = box.values.where((b) =>
      b.userId == AppConstants.defaultUserId &&
      b.month.year == month.year &&
      b.month.month == month.month
    );
    return budgets.isNotEmpty ? budgets.first : null;
  }

  Future<void> setMonthlyBudget(double amount, DateTime month) async {
    final existing = await getCurrentMonthBudget(month);
    final budget = Budget(
      id: existing?.id ?? const Uuid().v4(),
      amount: amount,
      month: DateTime(month.year, month.month, 1),
      userId: AppConstants.defaultUserId,
    );

    final box = _db.budgetsBox;
    await box.put(budget.id, budget);
  }

  Future<List<Budget>> getAllBudgets() async {
    final box = _db.budgetsBox;
    return box.values.where((b) => b.userId == AppConstants.defaultUserId).toList();
  }
}