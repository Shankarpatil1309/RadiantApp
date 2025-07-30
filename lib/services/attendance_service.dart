import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:radiant_app/models/attendence_model.dart';
import 'package:radiant_app/services/firestore_service.dart';

class AttendanceService {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collection = "attendance";

  Future<void> addAttendance(Attendance attendance) async {
    await _firestoreService.createDocument(
        _collection, attendance.id, attendance.toMap());
  }

  Future<Attendance?> getAttendance(String id) async {
    DocumentSnapshot doc = await _firestoreService.getDocument(_collection, id);
    if (doc.exists) {
      return Attendance.fromDoc(doc);
    }
    return null;
  }

  Future<void> updateAttendance(Attendance attendance) async {
    await _firestoreService.updateDocument(
        _collection, attendance.id, attendance.toMap());
  }

  Future<void> deleteAttendance(String id) async {
    await _firestoreService.deleteDocument(_collection, id);
  }

  Stream<List<Attendance>> listenAttendance() {
    return _firestoreService.listenToCollection(_collection).map((snapshot) =>
        snapshot.docs.map((doc) => Attendance.fromDoc(doc)).toList());
  }
}
