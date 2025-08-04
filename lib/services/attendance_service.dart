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
    String? subjectCode,
    String facultyId,
    List<String> presentStudentIds,
    List<String> absentStudentIds,
  ) async {
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    final attendanceData = Attendance(
      id: '', // Will be auto-generated
      classSessionId: sessionId,
      date: dateStr,
      subject: subject,
      subjectCode: subjectCode,
      department: department,
      section: section,
      semester: semester,
      facultyId: facultyId,
      totalStudents: presentStudentIds.length + absentStudentIds.length,
      presentCount: presentStudentIds.length,
      absentCount: absentStudentIds.length,
      studentsPresent: presentStudentIds,
      studentsAbsent: absentStudentIds,
      markedAt: now,
    );

    await _firestoreService.createDocument(
      _collection, 
      '', // Auto-generate ID
      attendanceData.toMap()
    );
  }

  Future<List<Attendance>> getAttendanceBySection(String department, String section, int semester) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(_collection)
        .where('department', isEqualTo: department)
        .where('section', isEqualTo: section)
        .where('semester', isEqualTo: semester)
        .orderBy('date', descending: true)
        .get();
    
    return snapshot.docs.map((doc) => Attendance.fromDoc(doc)).toList();
  }

  Future<List<Attendance>> getAttendanceByFaculty(String facultyId) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(_collection)
        .where('facultyId', isEqualTo: facultyId)
        .orderBy('date', descending: true)
        .get();
    
    return snapshot.docs.map((doc) => Attendance.fromDoc(doc)).toList();
  }

  Future<List<Attendance>> getAttendanceByDateRange(
    String department,
    String section,
    int semester,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final startDateStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    final endDateStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
    
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(_collection)
        .where('department', isEqualTo: department)
        .where('section', isEqualTo: section)
        .where('semester', isEqualTo: semester)
        .where('date', isGreaterThanOrEqualTo: startDateStr)
        .where('date', isLessThanOrEqualTo: endDateStr)
        .orderBy('date', descending: true)
        .get();
    
    return snapshot.docs.map((doc) => Attendance.fromDoc(doc)).toList();
  }

  // Get class sessions for attendance marking
  Future<List<Map<String, dynamic>>> getClassSessionsForAttendance(
    String facultyId,
    String department,
    String section,
    int semester,
  ) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('class_sessions')
        .where('facultyId', isEqualTo: facultyId)
        .where('department', isEqualTo: department)
        .where('section', isEqualTo: section)
        .where('semester', isEqualTo: semester)
        .where('status', isEqualTo: 'scheduled')
        .orderBy('startTime', descending: false)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'subject': data['subject'] ?? '',
        'subjectCode': data['subjectCode'] ?? '',
        'title': data['title'] ?? '',
        'date': data['date'] ?? '',
        'startTime': data['startTime'],
        'endTime': data['endTime'],
        'room': data['room'] ?? '',
      };
    }).toList();
  }

  // Get students for attendance marking
  Future<List<Map<String, dynamic>>> getStudentsForAttendance(
    String department,
    String section,
    int semester,
  ) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('students')
        .where('department', isEqualTo: department)
        .where('section', isEqualTo: section)
        .where('semester', isEqualTo: semester)
        .orderBy('name', descending: false)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'name': data['name'] ?? '',
        'rollNumber': data['rollNumber'] ?? '',
        'email': data['email'] ?? '',
      };
    }).toList();
  }
}
