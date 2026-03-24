import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // May throw if already initialized natively via google-services.json,
    // or if placeholder values are used — either way the app can proceed.
    debugPrint('Firebase init: $e');
  }

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
