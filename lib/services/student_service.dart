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

  Future<List<Student>> getStudentsBySection(String department, String section) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(_collection)
        .where('branch', isEqualTo: department)
        .where('section', isEqualTo: section)
        .get();
    
    return snapshot.docs.map((doc) => Student.fromDoc(doc)).toList();
  }

  Future<List<Student>> getStudentsBySemester(String department, String section, int semester) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(_collection)
        .where('branch', isEqualTo: department)
        .where('section', isEqualTo: section)
        .where('currentSemester', isEqualTo: semester)
        .get();
    
    return snapshot.docs.map((doc) => Student.fromDoc(doc)).toList();
  }

  Stream<List<Student>> listenStudentsBySection(String department, String section) {
    return FirebaseFirestore.instance
        .collection(_collection)
        .where('branch', isEqualTo: department)
        .where('section', isEqualTo: section)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Student.fromDoc(doc)).toList());
  }
}
