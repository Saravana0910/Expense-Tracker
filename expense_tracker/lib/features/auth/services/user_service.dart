import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../../core/models/user.dart' as local;
import '../../../core/services/firestore_service.dart';

class UserService {
  final FirestoreService _firestore = FirestoreService();
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  Future<local.User?> getCurrentUser() async {
    if (currentUserId.isEmpty) return null;
    return await _firestore.getUser(currentUserId);
  }

  Future<void> createOrUpdateUser({required local.User user}) async {
    await _firestore.setUser(user);
  }

  Future<void> updateUser(local.User user) async {
    await _firestore.setUser(user);
  }
}
