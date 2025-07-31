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

  Future<void> markAttendanceForSession(
    String sessionId,
    String department,
    String section,
    int semester,
    String subject,
    String facultyId,
    List<String> presentStudentIds,
    List<String> absentStudentIds,
  ) async {
    final attendanceData = Attendance(
      id: sessionId,
      department: department,
      semester: semester,
      section: section,
      subject: subject,
      classDate: DateTime.now().toString().split(' ')[0],
      classTime: DateTime.now().toString(),
      markedBy: facultyId,
      studentsPresent: presentStudentIds,
      studentsAbsent: absentStudentIds,
    );

    await _firestoreService.createDocument(
      _collection, 
      sessionId, 
      attendanceData.toMap()
    );
  }

  Future<List<Attendance>> getAttendanceBySection(String department, String section) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(_collection)
        .where('department', isEqualTo: department)
        .where('section', isEqualTo: section)
        .orderBy('classDate', descending: true)
        .get();
    
    return snapshot.docs.map((doc) => Attendance.fromDoc(doc)).toList();
  }

  Future<List<Attendance>> getAttendanceByFaculty(String facultyId) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(_collection)
        .where('markedBy', isEqualTo: facultyId)
        .orderBy('classDate', descending: true)
        .get();
    
    return snapshot.docs.map((doc) => Attendance.fromDoc(doc)).toList();
  }

  Future<List<Attendance>> getAttendanceByDateRange(
    String department,
    String section,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final startDateStr = startDate.toString().split(' ')[0];
    final endDateStr = endDate.toString().split(' ')[0];
    
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(_collection)
        .where('department', isEqualTo: department)
        .where('section', isEqualTo: section)
        .where('classDate', isGreaterThanOrEqualTo: startDateStr)
        .where('classDate', isLessThanOrEqualTo: endDateStr)
        .orderBy('classDate', descending: true)
        .get();
    
    return snapshot.docs.map((doc) => Attendance.fromDoc(doc)).toList();
  }
}
