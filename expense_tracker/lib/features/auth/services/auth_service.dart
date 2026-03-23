import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../../core/models/user.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/hive_service.dart';

class AuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();
  final HiveService _hive = HiveService();

  Stream<fb.User?> authStateChanges() => _auth.authStateChanges();

  fb.User? get currentFirebaseUser => _auth.currentUser;

  String? get currentUid => _auth.currentUser?.uid;

  Future<User> signUp({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final uid = cred.user!.uid;

    final user = User(
      id: uid,
      name: name,
      username: username,
      email: email,
      createdAt: DateTime.now().toUtc(),
    );

    await _firestore.setUser(user);
    await _hive.saveUser(user);

    await cred.user?.sendEmailVerification();
    return user;
  }

  Future<User> signIn({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final firebaseUser = cred.user!;

    final user = await _firestore.getUser(firebaseUser.uid);
    if (user == null) {
      throw Exception('User profile not found in Firestore.');
    }

    await _hive.saveUser(user);

    return user;
  }

  Future<void> signOut() async {
    final uid = currentUid;
    await _auth.signOut();
    if (uid != null) {
      await _hive.clearUser(uid);
    }
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
