import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:radiant_app/models/class_session_model.dart';

class ClassSessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = "class_sessions";

  Future<String> createClassSession(ClassSession session) async {
    final docRef = await _firestore.collection(_collection).add(session.toMap());
    
    // If recurring, create multiple sessions
    if (session.isRecurring && session.recurringPattern != null && session.recurringEndDate != null) {
      await _createRecurringSessions(session, docRef.id);
    }
    
    return docRef.id;
  }

  Future<void> _createRecurringSessions(ClassSession session, String parentId) async {
    if (session.recurringEndDate == null) return;
    
    DateTime currentDate = session.startTime;
    final endDate = session.recurringEndDate!;
    
    while (currentDate.isBefore(endDate)) {
      DateTime nextDate;
      
      switch (session.recurringPattern) {
        case 'daily':
          nextDate = currentDate.add(Duration(days: 1));
          break;
        case 'weekly':
          nextDate = currentDate.add(Duration(days: 7));
          break;
        case 'monthly':
          nextDate = DateTime(currentDate.year, currentDate.month + 1, currentDate.day);
          break;
        default:
          return;
      }
      
      if (nextDate.isAfter(endDate)) break;
      
      final duration = session.endTime.difference(session.startTime);
      final nextSession = ClassSession(
        id: '',
        title: session.title,
        subject: session.subject,
        department: session.department,
        section: session.section,
        semester: session.semester,
        facultyId: session.facultyId,
        facultyName: session.facultyName,
        room: session.room,
        startTime: nextDate,
        endTime: nextDate.add(duration),
        type: session.type,
        description: session.description,
        isActive: session.isActive,
        isRecurring: false, // Individual sessions are not recurring
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _firestore.collection(_collection).add(nextSession.toMap());
      currentDate = nextDate;
    }
  }

  Future<ClassSession?> getClassSession(String id) async {
    DocumentSnapshot doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.exists) {
      return ClassSession.fromDoc(doc);
    }
    return null;
  }

  Future<void> updateClassSession(String id, Map<String, dynamic> data) async {
    await _firestore.collection(_collection).doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteClassSession(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  Future<void> cancelClassSession(String id, String reason) async {
    await updateClassSession(id, {
      'status': 'cancelled',
      'description': reason,
    });
  }

  Stream<List<ClassSession>> listenClassSessions() {
    return _firestore
        .collection(_collection)
        .orderBy('startTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ClassSession.fromDoc(doc)).toList());
  }

  Stream<List<ClassSession>> listenClassSessionsByFaculty(String facultyId) {
    return _firestore
        .collection(_collection)
        .where('facultyId', isEqualTo: facultyId)
        .orderBy('startTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ClassSession.fromDoc(doc)).toList());
  }

  Stream<List<ClassSession>> listenClassSessionsByDepartment(String department, {String? section}) {
    Query query = _firestore
        .collection(_collection)
        .where('department', isEqualTo: department)
        .where('isActive', isEqualTo: true);
    
    if (section != null) {
      query = query.where('section', isEqualTo: section);
    }
    
    return query
        .orderBy('startTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ClassSession.fromDoc(doc)).toList());
  }

  Future<List<ClassSession>> getTodayClassesByFaculty(String facultyId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(Duration(days: 1));
    
    // Use only single field query to avoid composite index
    final snapshot = await _firestore
        .collection(_collection)
        .where('facultyId', isEqualTo: facultyId)
        .get();
    
    // Filter by date range, active status in memory
    final sessions = snapshot.docs
        .map((doc) => ClassSession.fromDoc(doc))
        .where((session) => 
            session.isActive &&
            session.startTime.isAfter(startOfDay.subtract(Duration(seconds: 1))) &&
            session.startTime.isBefore(endOfDay))
        .toList();
    
    // Sort by start time
    sessions.sort((a, b) => a.startTime.compareTo(b.startTime));
    
    return sessions;
  }

  Future<List<ClassSession>> getUpcomingClassesByFaculty(String facultyId, {int limit = 5}) async {
    final now = DateTime.now();
    
    // Use only single field query to avoid composite index
    final snapshot = await _firestore
        .collection(_collection)
        .where('facultyId', isEqualTo: facultyId)
        .get();
    
    // Filter by future date and active status in memory
    final sessions = snapshot.docs
        .map((doc) => ClassSession.fromDoc(doc))
        .where((session) => 
            session.isActive && 
            session.startTime.isAfter(now))
        .toList();
    
    // Sort by start time
    sessions.sort((a, b) => a.startTime.compareTo(b.startTime));
    
    // Apply limit
    return sessions.take(limit).toList();
  }

  Future<List<ClassSession>> getClassSessionsByDateRange(
    String facultyId, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    // Use only single field query to avoid composite index
    final snapshot = await _firestore
        .collection(_collection)
        .where('facultyId', isEqualTo: facultyId)
        .get();
    
    // Filter by date range and active status in memory
    final sessions = snapshot.docs
        .map((doc) => ClassSession.fromDoc(doc))
        .where((session) => 
            session.isActive &&
            session.startTime.isAfter(startDate.subtract(Duration(seconds: 1))) &&
            session.startTime.isBefore(endDate.add(Duration(days: 1))))
        .toList();
    
    // Sort by start time
    sessions.sort((a, b) => a.startTime.compareTo(b.startTime));
    
    return sessions;
  }

  Future<void> markAttendance(String sessionId, List<String> attendeeIds) async {
    await updateClassSession(sessionId, {
      'attendees': attendeeIds,
      'status': 'completed',
    });
  }

  // Student-specific methods
  Future<List<ClassSession>> getClassSessionsByDateRangeForStudent(
    String department,
    String section,
    int semester,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Use only single field query to avoid composite index
    final snapshot = await _firestore
        .collection(_collection)
        .where('department', isEqualTo: department)
        .get();
    
    // Filter by section, semester, date range and active status in memory
    final sessions = snapshot.docs
        .map((doc) => ClassSession.fromDoc(doc))
        .where((session) => 
            session.isActive &&
            session.section == section &&
            session.semester == semester &&
            session.startTime.isAfter(startDate.subtract(Duration(seconds: 1))) &&
            session.startTime.isBefore(endDate.add(Duration(days: 1))))
        .toList();
    
    // Sort by start time
    sessions.sort((a, b) => a.startTime.compareTo(b.startTime));
    
    return sessions;
  }

  Future<List<ClassSession>> getTodayClassesForStudent(
    String department,
    String section,
    int semester,
  ) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(Duration(days: 1));
    
    return getClassSessionsByDateRangeForStudent(
      department,
      section, 
      semester,
      startOfDay,
      endOfDay,
    );
  }

  Future<List<ClassSession>> getWeeklyScheduleForStudent(
    String department,
    String section,
    int semester,
    DateTime weekStart,
  ) async {
    final weekEnd = weekStart.add(Duration(days: 6));
    
    return getClassSessionsByDateRangeForStudent(
      department,
      section,
      semester,
      weekStart,
      weekEnd,
    );
  }
}