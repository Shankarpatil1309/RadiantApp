import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:radiant_app/models/assignment_model.dart';
import 'package:radiant_app/services/firestore_service.dart';

class AssignmentService {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collection = "assignments";

  Future<void> addAssignment(Assignment assignment) async {
    await _firestoreService.createDocument(
        _collection, assignment.id, assignment.toMap());
  }

  Future<Assignment?> getAssignment(String id) async {
    DocumentSnapshot doc = await _firestoreService.getDocument(_collection, id);
    if (doc.exists) {
      return Assignment.fromDoc(doc);
    }
    return null;
  }

  Future<void> updateAssignment(Assignment assignment) async {
    await _firestoreService.updateDocument(
        _collection, assignment.id, assignment.toMap());
  }

  Future<void> deleteAssignment(String id) async {
    await _firestoreService.deleteDocument(_collection, id);
  }

  Stream<List<Assignment>> listenAssignments() {
    return _firestoreService.listenToCollection(_collection).map((snapshot) =>
        snapshot.docs.map((doc) => Assignment.fromDoc(doc)).toList());
  }
}
