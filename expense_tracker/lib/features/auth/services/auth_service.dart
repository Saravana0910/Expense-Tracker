import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart' as fs;
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
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final firebaseUser = cred.user!;

      try {
        final user = await _firestore.getUser(firebaseUser.uid);
        if (user == null) {
          throw Exception('User profile not found in Firestore.');
        }

        await _hive.saveUser(user);
        return user;
      } catch (e) {
        // If Firestore is unavailable, try to load from local cache
        final cachedUser = await _hive.getUser(firebaseUser.uid);
        if (cachedUser != null) {
          return cachedUser;
        }
        
        // If no cache available, rethrow with better error message
        if (_isFirestoreUnavailable(e)) {
          throw FirestoreUnavailableException(
            'Unable to verify your account. Please check your internet connection and try again.',
          );
        }
        rethrow;
      }
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw ArgumentError('No account found with this email.');
      } else if (e.code == 'wrong-password') {
        throw ArgumentError('Incorrect password.');
      } else if (e.code == 'too-many-requests') {
        throw ArgumentError('Too many login attempts. Please try again later.');
      }
      rethrow;
    }
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

  /// Check if error is due to Firestore being unavailable
  bool _isFirestoreUnavailable(dynamic error) {
    final errorString = error.toString();
    return errorString.contains('unavailable') ||
        errorString.contains('deadline-exceeded') ||
        errorString.contains('UNAVAILABLE') ||
        errorString.contains('DEADLINE_EXCEEDED') ||
        errorString.contains('connection') ||
        errorString.contains('timeout');
  }
}

/// Custom exception for Firestore unavailability
class FirestoreUnavailableException implements Exception {
  final String message;
  FirestoreUnavailableException(this.message);

  @override
  String toString() => message;
}
