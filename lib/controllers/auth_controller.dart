import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../services/firebase_auth_service.dart';

part 'auth_controller.g.dart'; // 👈 very important for generated code

/// ✅ AuthController using Riverpod code generation
@riverpod
class AuthController extends _$AuthController {
  final _firestore = FirebaseFirestore.instance;

  @override
  Future<User?> build() async {
    // ✅ Load cached user first (offline awareness)
    await _loadCachedUser();

    // ✅ Listen to auth state for realtime updates
    ref.watch(authServiceProvider).authStateChanges.listen((user) async {
      if (user != null) {
        await _cacheUser(user);
      }
      // ✅ Set new state (Riverpod will rebuild UI)
      state = AsyncValue.data(user);
    });

    // ✅ Initial state will be loading, returns FirebaseAuth.currentUser
    return FirebaseAuth.instance.currentUser;
  }

  /// 🔹 Sign in with Google
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
      // ✅ state will update via authStateChanges listener
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 🔹 Sign out
  Future<void> signOut() async {
    await ref.read(authServiceProvider).signOut();
    state = const AsyncValue.data(null);
    final box = await Hive.openBox('auth_cache');
    await box.clear();
  }

  /// 🔹 Cache user locally for offline awareness
  Future<void> _cacheUser(User user) async {
    final box = await Hive.openBox('auth_cache');
    await box.put('uid', user.uid);
    await box.put('email', user.email);
    await box.put('name', user.displayName);
    await box.put('photo', user.photoURL);

    // ✅ Fetch role from Firestore
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (userDoc.exists) {
      await box.put('role', userDoc.data()?['role'] ?? 'STUDENT');
    }
  }

  /// 🔹 Load cached user info if offline
  Future<void> _loadCachedUser() async {
    final box = await Hive.openBox('auth_cache');
    final uid = box.get('uid');
    if (uid != null && FirebaseAuth.instance.currentUser == null) {
      // if offline, we only return minimal info (FirebaseAuth won't be hydrated)
      state = AsyncValue.data(FirebaseAuth.instance.currentUser);
    }
  }

  /// 🔹 Get user role (ADMIN, FACULTY, STUDENT)
  Future<String?> getUserRole() async {
    final box = await Hive.openBox('auth_cache');
    return box.get('role');
  }
}

/// ✅ Provide FirebaseAuthService with codegen as well
@riverpod
FirebaseAuthService authService(AuthServiceRef ref) {
  return FirebaseAuthService();
}
