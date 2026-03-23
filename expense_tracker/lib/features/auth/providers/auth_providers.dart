import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/models/user.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final hiveServiceProvider = Provider<HiveService>((ref) => HiveService());
final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

final authStateProvider = StreamProvider<fb.User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});

final currentUserProvider = FutureProvider<User?>((ref) async {
  final authUserAsync = ref.watch(authStateProvider);
  final authUser = authUserAsync.value;
  if (authUser == null) {
    return null;
  }
  final localUser = HiveService().getUser(authUser.uid);
  if (localUser != null) return localUser;
  final remote = await FirestoreService().getUser(authUser.uid);
  if (remote != null) {
    await HiveService().saveUser(remote);
  }
  return remote;
});
