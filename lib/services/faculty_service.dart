import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:radiant_app/models/faculty_model.dart';
import 'package:radiant_app/services/firestore_service.dart';

class FacultyService {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collection = "faculty";

  Future<void> addFaculty(Faculty faculty) async {
    await _firestoreService.createDocument(
        _collection, faculty.id, faculty.toMap());
  }

  Future<Faculty?> getFaculty(String id) async {
    DocumentSnapshot doc = await _firestoreService.getDocument(_collection, id);
    if (doc.exists) {
      return Faculty.fromDoc(doc);
    }
    return null;
  }

  Future<void> updateFaculty(Faculty faculty) async {
    await _firestoreService.updateDocument(
        _collection, faculty.id, faculty.toMap());
  }

  Future<void> deleteFaculty(String id) async {
    await _firestoreService.deleteDocument(_collection, id);
  }

  Stream<List<Faculty>> listenFaculty() {
    return _firestoreService.listenToCollection(_collection).map((snapshot) =>
        snapshot.docs.map((doc) => Faculty.fromDoc(doc)).toList());
  }
}
