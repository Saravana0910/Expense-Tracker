import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/services/database_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize database
    final dbService = DatabaseService();
    await dbService.init();
    debugPrint('Database initialized successfully');
  } catch (e, stackTrace) {
    debugPrint('Database initialization failed: $e');
    debugPrint('Stack trace: $stackTrace');
    // Continue with app startup even if database fails
  }

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
