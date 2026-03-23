import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/database_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  try {
    // Initialize local Hive database
    final dbService = DatabaseService();
    await dbService.init();
  } catch (e) {
    debugPrint('Database initialization error: $e');
  }

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
