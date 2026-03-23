import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../../core/models/user.dart' as local;
import '../../../core/services/hive_service.dart';
import '../../../core/services/firestore_service.dart';

class UserService {
  final HiveService _hive = HiveService();
  final FirestoreService _firestore = FirestoreService();
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  Future<local.User?> getCurrentUser() async {
    if (currentUserId.isEmpty) return null;
    final localUser = _hive.getUser(currentUserId);
    if (localUser != null) return localUser;

    final remote = await _firestore.getUser(currentUserId);
    if (remote != null) {
      await _hive.saveUser(remote);
    }
    return remote;
  }

  Future<void> createOrUpdateUser({
    required local.User user,
  }) async {
    await _hive.saveUser(user);
    await _firestore.setUser(user);
  }

  Future<void> updateUser(local.User user) async {
    await _hive.saveUser(user);
    await _firestore.setUser(user);
  }

  Future<void> clearUser() async {
    if (currentUserId.isEmpty) return;
    await _hive.clearUser(currentUserId);
  }
}