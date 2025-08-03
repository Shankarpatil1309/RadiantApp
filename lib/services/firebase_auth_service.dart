import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_config.dart';

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

  /// 🔹 Google Sign-In + Role-based access validation
  Future<User?> signInWithGoogle(String selectedRole) async {
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

      // 2. Validate email domain BEFORE Firebase sign-in
      if (!_isValidCollegeEmail(googleUser.email)) {
        // Sign out from Google if email domain is invalid
        await _signIn.signOut();
        throw Exception(
            'Please use your B.K.I.T college email address to sign in.');
      }

      // 3. Validate user exists in selected role collection BEFORE Firebase sign-in
      await _validateUserRoleAccessByEmail(googleUser.email, selectedRole);

      // 4. Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 5. Create a new credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // 6. Sign in with Firebase ONLY after validation passes
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // 7. Cache user data after successful authentication
        await _createOrUpdateUserCache(user, selectedRole);

        // 8. For faculty users, link UID with their employeeId-based profile
        if (selectedRole.toUpperCase() == 'FACULTY') {
          await _linkFacultyUid(user);
        }
        
        // 9. For admin users, link UID with their admin profile
        if (selectedRole.toUpperCase() == 'ADMIN') {
          await _linkAdminUid(user);
        }

        print('✅ Google Sign-In successful: ${user.email} as ${selectedRole}');
      }
      return user;
    } catch (e, st) {
      print('❌ Google Sign-In error: $e\n$st');
      // Ensure cleanup on any error
      await _signIn.signOut();
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
      '@gmail.com'
    ];

    // Check college domains
    if (collegeDomains.any((domain) => emailLower.endsWith(domain))) {
      return true;
    }

    return false;
  }

  /// Validates if user exists in the selected role collection by email (before Firebase sign-in)
  Future<void> _validateUserRoleAccessByEmail(
      String email, String selectedRole) async {
    try {
      final emailLower = email.toLowerCase();
      bool hasAccess = false;

      switch (selectedRole.toUpperCase()) {
        case 'ADMIN':
          hasAccess = await _checkAdminAccess(emailLower);
          break;
        case 'FACULTY':
          hasAccess = await _checkFacultyAccess(emailLower);
          break;
        case 'STUDENT':
          hasAccess = await _checkStudentAccess(emailLower);
          break;
        default:
          throw Exception('Invalid role selected');
      }

      if (!hasAccess) {
        throw Exception(
            'You don\'t have access to the app as ${selectedRole}.\n'
            'Please contact the college administration if this is an error.\n\n'
            '${AppConfig.contactInfo}');
      }
    } catch (e) {
      print('❌ Role validation error: $e');
      rethrow;
    }
  }

  /// Validates if user exists in the selected role collection and has access (legacy method - kept for compatibility)
  Future<void> _validateUserRoleAccess(User user, String selectedRole) async {
    try {
      final email = user.email?.toLowerCase();
      if (email == null) {
        throw Exception('Email not found in user profile');
      }

      await _validateUserRoleAccessByEmail(email, selectedRole);

      // Update or create user document in 'users' collection for caching
      await _createOrUpdateUserCache(user, selectedRole);
    } catch (e) {
      print('❌ Role validation error: $e');
      rethrow;
    }
  }

  /// Check if user has admin access
  Future<bool> _checkAdminAccess(String email) async {
    try {
      // First check admin collection
      final adminQuery = await _firestore
          .collection('admin')
          .where('email', isEqualTo: email)
          .where('isActive', isEqualTo: true)
          .get();

      if (adminQuery.docs.isNotEmpty) {
        return true;
      }

      // Second check allowedAdmins collection (for legacy support)
      final allowedAdminsDoc =
          await _firestore.collection('allowedAdmins').doc('admins').get();

      if (allowedAdminsDoc.exists) {
        final List<dynamic> allowedEmails =
            allowedAdminsDoc.data()?['emails'] ?? [];
        if (allowedEmails.contains(email)) {
          return true;
        }
      }

      // Fallback: check if admin exists in 'users' collection with ADMIN role
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .where('role', isEqualTo: 'ADMIN')
          .where('isActive', isEqualTo: true)
          .get();

      return userQuery.docs.isNotEmpty;
    } catch (e) {
      print('⚠️ Admin access check error: $e');
      return false;
    }
  }

  /// Check if user exists in faculty collection
  Future<bool> _checkFacultyAccess(String email) async {
    try {
      final facultyQuery = await _firestore
          .collection('faculty')
          .where('email', isEqualTo: email)
          .where('isActive', isEqualTo: true)
          .get();

      return facultyQuery.docs.isNotEmpty;
    } catch (e) {
      print('⚠️ Faculty access check error: $e');
      return false;
    }
  }

  /// Check if user exists in students collection
  Future<bool> _checkStudentAccess(String email) async {
    try {
      final studentQuery = await _firestore
          .collection('students')
          .where('email', isEqualTo: email)
          .where('isActive', isEqualTo: true)
          .get();

      return studentQuery.docs.isNotEmpty;
    } catch (e) {
      print('⚠️ Student access check error: $e');
      return false;
    }
  }

  /// Create or update user cache document with essential fields only
  Future<void> _createOrUpdateUserCache(User user, String role) async {
    try {
      final userRef = _firestore.collection('users').doc(user.uid);

      // Only store essential fields for lookup/cache purposes
      final userData = {
        'uid': user.uid,
        'email': user.email,
        'role': role,
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isActive': true,
      };

      // Check if document exists
      final doc = await userRef.get();
      if (doc.exists) {
        // Update existing document with essential fields only
        await userRef.update(userData);
      } else {
        // Create new document with creation timestamp
        userData['createdAt'] = FieldValue.serverTimestamp();
        await userRef.set(userData);
      }
    } catch (e) {
      print('⚠️ User cache update error: $e');
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

  /// Link faculty UID with their employeeId-based profile
  Future<void> _linkFacultyUid(User user) async {
    try {
      if (user.email == null) return;

      // Search for existing faculty by email
      final emailQuery = await _firestore
          .collection('faculty')
          .where('email', isEqualTo: user.email!.toLowerCase())
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (emailQuery.docs.isNotEmpty) {
        final facultyDoc = emailQuery.docs.first;
        final facultyData = facultyDoc.data();
        final employeeId = facultyData['employeeId'] as String?;

        // Update faculty document with UID
        await facultyDoc.reference.update({
          'uid': user.uid,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Update user cache with employeeId for reference
        if (employeeId != null) {
          await _firestore.collection('users').doc(user.uid).update({
            'uniqueId': employeeId,
            'lastLoginAt': FieldValue.serverTimestamp(),
          });
        }

        print('✅ Linked UID ${user.uid} to faculty $employeeId');
      }
    } catch (e) {
      print('⚠️ Faculty UID linking error: $e');
      // Don't throw error to avoid blocking sign-in
    }
  }

  /// Link admin UID with their admin profile
  Future<void> _linkAdminUid(User user) async {
    try {
      if (user.email == null) return;

      // Search for existing admin by email
      final emailQuery = await _firestore
          .collection('admin')
          .where('email', isEqualTo: user.email!.toLowerCase())
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (emailQuery.docs.isNotEmpty) {
        final adminDoc = emailQuery.docs.first;
        final adminData = adminDoc.data();
        final adminId = adminData['adminId'] ?? adminData['employeeId'] as String?;

        // Update admin document with UID
        await adminDoc.reference.update({
          'uid': user.uid,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Update user cache with adminId for reference
        if (adminId != null) {
          await _firestore.collection('users').doc(user.uid).update({
            'uniqueId': adminId,
            'lastLoginAt': FieldValue.serverTimestamp(),
          });
        }

        print('✅ Linked UID ${user.uid} to admin $adminId');
      }
    } catch (e) {
      print('⚠️ Admin UID linking error: $e');
      // Don't throw error to avoid blocking sign-in
    }
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;
}
