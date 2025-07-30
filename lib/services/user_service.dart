import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:radiant_app/models/user_model.dart';
import 'package:radiant_app/services/firestore_service.dart';

class UserService {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collection = "users";

  Future<void> addUser(AppUser user) async {
    await _firestoreService.createDocument(_collection, user.id, user.toMap());
  }

  Future<AppUser?> getUser(String id) async {
    DocumentSnapshot doc = await _firestoreService.getDocument(_collection, id);
    if (doc.exists) {
      return AppUser.fromDoc(doc);
    }
    return null;
  }

  Future<void> updateUser(AppUser user) async {
    await _firestoreService.updateDocument(_collection, user.id, user.toMap());
  }

  Future<void> deleteUser(String id) async {
    await _firestoreService.deleteDocument(_collection, id);
  }

  Stream<List<AppUser>> listenUsers() {
    return _firestoreService.listenToCollection(_collection).map((snapshot) =>
        snapshot.docs.map((doc) => AppUser.fromDoc(doc)).toList());
  }
}
