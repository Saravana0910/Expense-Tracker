import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (defaultTargetPlatform == TargetPlatform.android) {
      // On Android, google-services.json configures Firebase natively at build time.
      // Do NOT pass options here — passing the Dart-side options would override
      // the native config with wrong placeholder values, breaking Auth.
      await Firebase.initializeApp();
    } else {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('Firebase init: $e');
  }

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
