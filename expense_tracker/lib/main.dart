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
    // Silently handle Firebase init errors - app can run offline
  }

  try {
    // Initialize local Hive database
    final dbService = DatabaseService();
    await dbService.init();
  } catch (e) {
    // Silently handle database init errors - app can still function
  }

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
