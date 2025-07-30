import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _initialized = false;

  /// Initializes Google Sign-In (must be called before using authenticate())
  Future<void> initialize() async {
    if (!_initialized) {
      await _googleSignIn.initialize();
      _initialized = true;
    }
  }

  /// 🔹 Google Sign-In + Firestore user creation/update
  Future<User?> signInWithGoogle() async {
    try {
      // ⚙️ Ensure GoogleSignIn is initialized
      await initialize();

      // 1. Use new authenticate() flow
      final account = await _googleSignIn.authenticate();

      // 2. Get auth event token (event object contains tokens)
      final authEvent = account;
      final googleAuth = authEvent as GoogleSignInAuthentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // 3. Sign in with Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        await _createOrUpdateUserDocument(user);
      }
      return user;
    } catch (e, st) {
      print('❌ Google Sign-In error: $e\n$st');
      return null;
    }
  }

  Future<void> _createOrUpdateUserDocument(User user) async {
    try {
      final userRef = _firestore.collection('users').doc(user.uid);
      final doc = await userRef.get();

      if (doc.exists) {
        await userRef.update({'updatedAt': FieldValue.serverTimestamp()});
      } else {
        await userRef.set({
          'id': user.uid,
          'email': user.email,
          'name': user.displayName,
          'mobile': '',
          'role': 'STUDENT',
          'imageUrl': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('⚠️ Firestore write error: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      print('✅ Signed out');
    } catch (e) {
      print('❌ Sign-out error: $e');
    }
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;
}
