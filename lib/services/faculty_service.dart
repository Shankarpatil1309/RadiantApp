import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:radiant_app/models/faculty_model.dart';
import 'package:radiant_app/services/firestore_service.dart';

class FacultyService {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collection = "faculty";

  Future<void> addFaculty(Faculty faculty) async {
    // Use employeeId as document ID
    await _firestoreService.createDocument(_collection, faculty.employeeId, faculty.toMap());
  }

  Future<Faculty?> getFaculty(String employeeId) async {
    // Primary method: Get by employeeId (document ID)
    DocumentSnapshot doc = await _firestoreService.getDocument(_collection, employeeId.toUpperCase());
    if (doc.exists) {
      return Faculty.fromDoc(doc);
    }
    return null;
  }

  Future<Faculty?> getFacultyByUid(String uid) async {
    // Search by UID field for faculty who have signed in
    final query = await FirebaseFirestore.instance
        .collection(_collection)
        .where('uid', isEqualTo: uid)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
    
    if (query.docs.isNotEmpty) {
      return Faculty.fromDoc(query.docs.first);
    }
    return null;
  }

  Future<Faculty?> getFacultyByEmail(String email) async {
    final query = await FirebaseFirestore.instance
        .collection(_collection)
        .where('email', isEqualTo: email.toLowerCase())
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
    
    if (query.docs.isNotEmpty) {
      return Faculty.fromDoc(query.docs.first);
    }
    return null;
  }

  // Method to link UID with faculty record when they sign in
  Future<void> linkUidToFaculty(String email, String uid) async {
    try {
      // Find existing faculty by email
      final existingFaculty = await getFacultyByEmail(email);
      if (existingFaculty != null) {
        // Update the faculty document with the UID
        final updatedData = {
          'uid': uid,
          'updatedAt': FieldValue.serverTimestamp(),
        };
        
        await _firestoreService.updateDocument(_collection, existingFaculty.id, updatedData);
        print('✅ Linked UID $uid to faculty ${existingFaculty.employeeId}');
      }
    } catch (e) {
      print('Error linking UID to faculty: $e');
    }
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
