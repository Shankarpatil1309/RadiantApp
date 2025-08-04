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
    
    // Check if attendance already exists for this session
    final existingAttendance = await getAttendanceBySession(sessionId);
    
    final attendanceData = Attendance(
      id: existingAttendance?.id ?? '', // Use existing ID or empty for new
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

    if (existingAttendance != null) {
      // Update existing attendance record
      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(existingAttendance.id)
          .update(attendanceData.toMap());
    } else {
      // Create new attendance record
      await FirebaseFirestore.instance
          .collection(_collection)
          .add(attendanceData.toMap());
    }
  }

  Future<List<Attendance>> getAttendanceBySection(String department, String section, int semester) async {
    // Use only equality filters to avoid requiring composite index
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(_collection)
        .where('department', isEqualTo: department)
        .where('section', isEqualTo: section)
        .where('semester', isEqualTo: semester)
        .get();
    
    // Convert to list and sort in memory
    final attendanceList = snapshot.docs.map((doc) => Attendance.fromDoc(doc)).toList();
    
    // Sort by date in descending order (newest first)
    attendanceList.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.date);
        final dateB = DateTime.parse(b.date);
        return dateB.compareTo(dateA); // Descending order
      } catch (e) {
        // Fallback to string comparison if date parsing fails
        return b.date.compareTo(a.date);
      }
    });
    
    return attendanceList;
  }

  Future<List<Attendance>> getAttendanceByFaculty(String facultyId) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(_collection)
        .where('facultyId', isEqualTo: facultyId)
        .get();
    
    // Convert to list and sort in memory for consistency
    final attendanceList = snapshot.docs.map((doc) => Attendance.fromDoc(doc)).toList();
    
    // Sort by date in descending order (newest first)
    attendanceList.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.date);
        final dateB = DateTime.parse(b.date);
        return dateB.compareTo(dateA); // Descending order
      } catch (e) {
        // Fallback to string comparison if date parsing fails
        return b.date.compareTo(a.date);
      }
    });
    
    return attendanceList;
  }

  Future<Attendance?> getAttendanceBySession(String sessionId) async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(_collection)
          .where('classSessionId', isEqualTo: sessionId)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return Attendance.fromDoc(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, bool>> getAttendanceStatusForSessions(List<String> sessionIds) async {
    final Map<String, bool> attendanceStatus = {};
    
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(_collection)
          .where('classSessionId', whereIn: sessionIds)
          .get();
      
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final sessionId = data['classSessionId'] as String;
        attendanceStatus[sessionId] = true;
      }
      
      // Set false for sessions without attendance
      for (final sessionId in sessionIds) {
        attendanceStatus[sessionId] ??= false;
      }
      
    } catch (e) {
      // If error, assume no attendance marked
      for (final sessionId in sessionIds) {
        attendanceStatus[sessionId] = false;
      }
    }
    
    return attendanceStatus;
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
    
    // Use only equality filters to avoid requiring composite index
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(_collection)
        .where('department', isEqualTo: department)
        .where('section', isEqualTo: section)
        .where('semester', isEqualTo: semester)
        .get();
    
    // Filter by date range and sort in memory
    final attendanceList = snapshot.docs
        .map((doc) => Attendance.fromDoc(doc))
        .where((attendance) {
          // Filter by date range
          return attendance.date.compareTo(startDateStr) >= 0 && 
                 attendance.date.compareTo(endDateStr) <= 0;
        })
        .toList();
    
    // Sort by date in descending order (newest first)
    attendanceList.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.date);
        final dateB = DateTime.parse(b.date);
        return dateB.compareTo(dateA); // Descending order
      } catch (e) {
        // Fallback to string comparison if date parsing fails
        return b.date.compareTo(a.date);
      }
    });
    
    return attendanceList;
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
