import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/models/user.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

final authStateProvider = StreamProvider<fb.User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});

final currentUserProvider = FutureProvider<User?>((ref) async {
  final authUserAsync = ref.watch(authStateProvider);
  final authUser = authUserAsync.value;
  if (authUser == null) return null;
  return FirestoreService().getUser(authUser.uid);
});
