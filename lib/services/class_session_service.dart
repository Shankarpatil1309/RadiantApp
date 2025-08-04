import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:radiant_app/models/class_session_model.dart';

class ClassSessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = "class_sessions";

  Future<String> createClassSession(ClassSession session) async {
    final docRef = await _firestore.collection(_collection).add(session.toMap());
    return docRef.id;
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
;
    
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
            session.status != 'cancelled' &&
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
            session.status != 'cancelled' && 
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
            session.status != 'cancelled' &&
            session.startTime.isAfter(startDate.subtract(Duration(seconds: 1))) &&
            session.startTime.isBefore(endDate.add(Duration(days: 1))))
        .toList();
    
    // Sort by start time
    sessions.sort((a, b) => a.startTime.compareTo(b.startTime));
    
    return sessions;
  }

  Future<void> markSessionCompleted(String sessionId) async {
    await updateClassSession(sessionId, {
      'status': 'completed',
    });
  }

  // Copy schedule functionality
  Future<List<String>> copyScheduleFromPreviousDay(
    String facultyId,
    DateTime targetDate,
  ) async {
    final previousDay = targetDate.subtract(Duration(days: 1));
    final previousDayStr = '${previousDay.year}-${previousDay.month.toString().padLeft(2, '0')}-${previousDay.day.toString().padLeft(2, '0')}';
    
    // Get sessions from previous day
    final snapshot = await _firestore
        .collection(_collection)
        .where('facultyId', isEqualTo: facultyId)
        .where('date', isEqualTo: previousDayStr)
        .get();
    
    final List<String> newSessionIds = [];
    final targetDateStr = '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';
    
    for (final doc in snapshot.docs) {
      final session = ClassSession.fromDoc(doc);
      
      // Create new session for target date
      final newSession = session.copyWith(
        id: '', // Will be auto-generated
        date: targetDateStr,
        startTime: DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
          session.startTime.hour,
          session.startTime.minute,
        ),
        endTime: DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
          session.endTime.hour,
          session.endTime.minute,
        ),
        status: 'scheduled',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final docRef = await _firestore.collection(_collection).add(newSession.toMap());
      newSessionIds.add(docRef.id);
    }
    
    return newSessionIds;
  }

  Future<List<String>> copyScheduleFromPreviousWeek(
    String facultyId,
    DateTime weekStart,
  ) async {
    final previousWeekStart = weekStart.subtract(Duration(days: 7));
    final previousWeekEnd = previousWeekStart.add(Duration(days: 6));
    
    // Get sessions from previous week
    final sessions = await getClassSessionsByDateRange(
      facultyId,
      previousWeekStart,
      previousWeekEnd,
    );
    
    final List<String> newSessionIds = [];
    
    for (final session in sessions) {
      // Calculate target date (same day of week, next week)
      final daysDifference = session.startTime.difference(previousWeekStart).inDays;
      final targetDate = weekStart.add(Duration(days: daysDifference));
      final targetDateStr = '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';
      
      // Create new session for target week
      final newSession = session.copyWith(
        id: '', // Will be auto-generated
        date: targetDateStr,
        startTime: DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
          session.startTime.hour,
          session.startTime.minute,
        ),
        endTime: DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
          session.endTime.hour,
          session.endTime.minute,
        ),
        status: 'scheduled',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final docRef = await _firestore.collection(_collection).add(newSession.toMap());
      newSessionIds.add(docRef.id);
    }
    
    return newSessionIds;
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
    
    // Filter by section, semester, date range in memory
    final sessions = snapshot.docs
        .map((doc) => ClassSession.fromDoc(doc))
        .where((session) => 
            session.status != 'cancelled' &&
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