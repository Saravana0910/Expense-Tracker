import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/models/user.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/services/firestore_service.dart';

class UserService {
  final DatabaseService _db = DatabaseService();
  final HiveService _hive = HiveService();
  final FirestoreService _firestore = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  Future<User?> getCurrentUser() async {
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
    required User user,
  }) async {
    await _hive.saveUser(user);
    await _firestore.setUser(user);
  }

  Future<void> updateUser(User user) async {
    await _hive.saveUser(user);
    await _firestore.setUser(user);
  }

  Future<void> clearUser() async {
    if (currentUserId.isEmpty) return;
    await _hive.clearUser(currentUserId);
  }
}