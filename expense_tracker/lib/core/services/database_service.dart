import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/hive_boxes.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import '../models/budget.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<void> init() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.initFlutter(appDocumentDir.path);

    // Register adapters
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(BudgetAdapter());

    // Open boxes
    await Hive.openBox<Transaction>(HiveBoxes.transactions);
    await Hive.openBox<User>(HiveBoxes.users);
    await Hive.openBox<Budget>(HiveBoxes.budgets);
  }

  Box<Transaction> get transactionsBox => Hive.box<Transaction>(HiveBoxes.transactions);
  Box<User> get usersBox => Hive.box<User>(HiveBoxes.users);
  Box<Budget> get budgetsBox => Hive.box<Budget>(HiveBoxes.budgets);

  Future<void> close() async {
    await Hive.close();
  }
}