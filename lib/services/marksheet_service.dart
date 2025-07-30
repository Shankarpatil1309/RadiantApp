import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:radiant_app/models/marksheet_model.dart';
import 'package:radiant_app/services/firestore_service.dart';

class MarksheetService {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collection = "marksheets";

  Future<void> addMarksheet(Marksheet marksheet) async {
    await _firestoreService.createDocument(
        _collection, marksheet.id, marksheet.toMap());
  }

  Future<Marksheet?> getMarksheet(String id) async {
    DocumentSnapshot doc = await _firestoreService.getDocument(_collection, id);
    if (doc.exists) {
      return Marksheet.fromDoc(doc);
    }
    return null;
  }

  Future<void> updateMarksheet(Marksheet marksheet) async {
    await _firestoreService.updateDocument(
        _collection, marksheet.id, marksheet.toMap());
  }

  Future<void> deleteMarksheet(String id) async {
    await _firestoreService.deleteDocument(_collection, id);
  }

  Stream<List<Marksheet>> listenMarksheets() {
    return _firestoreService.listenToCollection(_collection).map((snapshot) =>
        snapshot.docs.map((doc) => Marksheet.fromDoc(doc)).toList());
  }
}
