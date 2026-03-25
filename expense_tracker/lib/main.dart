import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try explicit options first (written from CI secret / filled manually).
  // On failure (placeholder values, wrong format, or desktop platform that has
  // no config), fall back to native init via google-services.json /
  // GoogleService-Info.plist.  If both fail the app still starts and shows
  // appropriate error states instead of crashing before runApp.
  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } on UnsupportedError {
      // Platform not configured in firebase_options.dart (e.g. desktop build).
      try {
        await Firebase.initializeApp();
      } catch (_) {}
    } catch (_) {
      // Explicit options are placeholders or invalid — try native init.
      try {
        await Firebase.initializeApp();
      } catch (_) {}
    }
  }

  // Enable Firestore offline persistence so the app works with intermittent
  // connectivity.  Guarded so it doesn't throw when Firebase isn't available.
  if (Firebase.apps.isNotEmpty) {
    try {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (_) {}
  }

  runApp(const ProviderScope(child: App()));
}
