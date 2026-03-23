import 'package:hive/hive.dart';
import '../models/user.dart';
import '../models/transaction.dart';
import '../constants/hive_boxes.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  Box<User> get userBox => Hive.box<User>(HiveBoxes.users);
  Box<Transaction> get transactionsBox => Hive.box<Transaction>(HiveBoxes.transactions);
  Box<Transaction> get unsyncedExpenseBox => Hive.box<Transaction>(HiveBoxes.unsyncedExpenses);

  Future<void> saveUser(User user) async {
    await userBox.put(user.id, user);
  }

  User? getUser(String userId) {
    return userBox.get(userId);
  }

  Future<void> clearUser(String uid) async {
    await userBox.delete(uid);
  }

  Future<void> saveExpense(Transaction expense) async {
    await transactionsBox.put(expense.id, expense);
  }

  Future<List<Transaction>> getExpensesByUser(String userId) async {
    return transactionsBox.values.where((t) => t.userId == userId).toList();
  }

  Future<void> addUnsyncedExpense(Transaction expense) async {
    await unsyncedExpenseBox.put(expense.id, expense);
  }

  Future<List<Transaction>> getUnsyncedExpenses(String userId) async {
    return unsyncedExpenseBox.values.where((t) => t.userId == userId).toList();
  }

  Future<void> removeUnsyncedExpense(String id) async {
    await unsyncedExpenseBox.delete(id);
  }

  Future<void> clearAll() async {
    for (final boxName in HiveBoxes.all) {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).clear();
      }
    }
  }
}
