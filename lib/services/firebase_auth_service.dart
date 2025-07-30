import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _signIn = GoogleSignIn.instance;

  bool _initialized = false;

  /// Initializes Google Sign-In (no additional setup needed for modern versions)
  Future<void> initialize() async {
    if (!_initialized) {
      await _signIn.initialize(); // Ensure GoogleSignIn is initialized
      _initialized = true;
    }
  }

  /// 🔹 Google Sign-In + Firestore user creation/update
  Future<User?> signInWithGoogle() async {
    try {
      // ⚙️ Ensure GoogleSignIn is initialized
      await initialize();

      // 1. Trigger the authentication flow using the singleton instance
      final GoogleSignInAccount? googleUser = await _signIn.authenticate();

      if (googleUser == null) {
        // User canceled the sign-in
        print('🚫 Google Sign-In canceled by user');
        return null;
      }

      // 2. Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // 3. Create a new credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // 4. Sign in with Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // 5. Validate email domain for B.K.I.T college
        if (!_isValidCollegeEmail(user.email)) {
          // Sign out the user if email domain is invalid
          await signOut();
          throw Exception(
              'Please use your B.K.I.T college email address to sign in.');
        }

        await _createOrUpdateUserDocument(user);
        print('✅ Google Sign-In successful: ${user.email}');
      }
      return user;
    } catch (e, st) {
      print('❌ Google Sign-In error: $e\n$st');
      rethrow; // Re-throw to let the UI handle the error
    }
  }

  /// Validates if the email belongs to B.K.I.T college domain
  bool _isValidCollegeEmail(String? email) {
    if (email == null) return false;

    final emailLower = email.toLowerCase();

    // College email domains
    final collegeDomains = [
      '@bkit.edu',
      '@student.bkit.edu',
      '@faculty.bkit.edu',
      '@bkit.ac.in',
    ];

    // Testing emails for development
    final testingEmails = [
      'uapatil614@gmail.com',
      // Add more testing emails here as needed
    ];

    // For development: Allow Gmail domain (remove in production)
    final devDomains = [
      '@gmail.com', // TODO: Remove this in production
    ];

    // Check specific testing emails first
    if (testingEmails.contains(emailLower)) {
      return true;
    }

    // Check college domains
    if (collegeDomains.any((domain) => emailLower.endsWith(domain))) {
      return true;
    }

    // Check dev domains (for testing only)
    if (devDomains.any((domain) => emailLower.endsWith(domain))) {
      print('⚠️ Development mode: Allowing ${email} for testing');
      return true;
    }

    return false;
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
      await GoogleSignIn.instance.signOut();
      await _auth.signOut();
      print('✅ Signed out');
    } catch (e) {
      print('❌ Sign-out error: $e');
    }
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;
}
