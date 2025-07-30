import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:radiant_app/models/student_model.dart';
import 'package:radiant_app/services/firestore_service.dart';

class StudentService {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collection = "students";

  Future<void> addStudent(Student student) async {
    await _firestoreService.createDocument(
        _collection, student.id, student.toMap());
  }

  Future<Student?> getStudent(String id) async {
    DocumentSnapshot doc = await _firestoreService.getDocument(_collection, id);
    if (doc.exists) {
      return Student.fromDoc(doc);
    }
    return null;
  }

  Future<void> updateStudent(Student student) async {
    await _firestoreService.updateDocument(
        _collection, student.id, student.toMap());
  }

  Future<void> deleteStudent(String id) async {
    await _firestoreService.deleteDocument(_collection, id);
  }

  Stream<List<Student>> listenStudents() {
    return _firestoreService.listenToCollection(_collection).map((snapshot) =>
        snapshot.docs.map((doc) => Student.fromDoc(doc)).toList());
  }
}
