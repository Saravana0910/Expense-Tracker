import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../../core/models/user.dart';
import '../../../core/services/firestore_service.dart';

class AuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();

  Stream<fb.User?> authStateChanges() => _auth.authStateChanges();

  fb.User? get currentFirebaseUser => _auth.currentUser;

  String? get currentUid => _auth.currentUser?.uid;

  Future<User> signUp({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    final uid = cred.user!.uid;

    final user = User(
      id: uid,
      name: name,
      username: username,
      email: email,
      createdAt: DateTime.now().toUtc(),
    );

    await _firestore.setUser(user);
    await cred.user?.sendEmailVerification();
    return user;
  }

  Future<User> signIn(
      {required String email, required String password}) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      final firebaseUser = cred.user!;

      final user = await _firestore.getUser(firebaseUser.uid);
      if (user == null) {
        throw Exception('User profile not found. Please contact support.');
      }
      return user;
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw ArgumentError('No account found with this email.');
      } else if (e.code == 'wrong-password') {
        throw ArgumentError('Incorrect password.');
      } else if (e.code == 'too-many-requests') {
        throw ArgumentError(
            'Too many login attempts. Please try again later.');
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}

