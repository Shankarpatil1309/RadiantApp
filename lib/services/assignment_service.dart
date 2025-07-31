import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:radiant_app/models/assignment_model.dart';

class AssignmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = "assignments";

  Future<String> addAssignment(Assignment assignment) async {
    print('💾 Adding assignment to database: ${assignment.title}');
    print('💾 Faculty ID: ${assignment.facultyId}');
    print('💾 Subject: ${assignment.subject}');
    print('💾 Department: ${assignment.department}');
    
    final assignmentMap = assignment.toMap();
    print('💾 Assignment data: $assignmentMap');
    
    final docRef = await _firestore.collection(_collection).add(assignmentMap);
    print('💾 Assignment saved with ID: ${docRef.id}');
    
    return docRef.id;
  }

  Future<Assignment?> getAssignment(String id) async {
    DocumentSnapshot doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.exists) {
      return Assignment.fromDoc(doc);
    }
    return null;
  }

  Future<void> updateAssignment(String id, Map<String, dynamic> data) async {
    await _firestore.collection(_collection).doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteAssignment(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  Stream<List<Assignment>> listenAssignments() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Assignment.fromDoc(doc)).toList());
  }

  Stream<List<Assignment>> listenAssignmentsByFaculty(String facultyId) {
    return _firestore
        .collection(_collection)
        .where('facultyId', isEqualTo: facultyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Assignment.fromDoc(doc)).toList());
  }

  Stream<List<Assignment>> listenAssignmentsByDepartment(String department, {String? section}) {
    Query query = _firestore
        .collection(_collection)
        .where('department', isEqualTo: department)
        .where('isActive', isEqualTo: true);
    
    if (section != null) {
      query = query.where('section', isEqualTo: section);
    }
    
    return query
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Assignment.fromDoc(doc)).toList());
  }

  Future<List<Assignment>> getUpcomingAssignments(String department, {String? section, int limit = 5}) async {
    Query query = _firestore
        .collection(_collection)
        .where('department', isEqualTo: department)
        .where('isActive', isEqualTo: true)
        .where('dueDate', isGreaterThan: Timestamp.now());
    
    if (section != null) {
      query = query.where('section', isEqualTo: section);
    }
    
    final snapshot = await query
        .orderBy('dueDate', descending: false)
        .limit(limit)
        .get();
    
    return snapshot.docs.map((doc) => Assignment.fromDoc(doc)).toList();
  }

  // Faculty-specific methods
  Future<List<Assignment>> getAssignmentsByFaculty(String facultyId) async {
    print('🔍 Querying assignments for facultyId: $facultyId');
    
    final snapshot = await _firestore
        .collection(_collection)
        .where('facultyId', isEqualTo: facultyId)
        .get();
    
    print('🔍 Found ${snapshot.docs.length} assignments in database');
    final assignments = snapshot.docs.map((doc) => Assignment.fromDoc(doc)).toList();
    
    for (final assignment in assignments) {
      print('  📋 ${assignment.title} - ${assignment.subject} (Active: ${assignment.isActive})');
    }
    
    return assignments;
  }

  Future<List<Assignment>> getActiveAssignmentsByFaculty(String facultyId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('facultyId', isEqualTo: facultyId)
        .where('isActive', isEqualTo: true)
        .get();
    
    final assignments = snapshot.docs
        .map((doc) => Assignment.fromDoc(doc))
        .where((assignment) => assignment.dueDate.isAfter(DateTime.now()))
        .toList();
    
    assignments.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return assignments;
  }

  Future<List<Assignment>> getClosedAssignmentsByFaculty(String facultyId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('facultyId', isEqualTo: facultyId)
        .get();
    
    final assignments = snapshot.docs
        .map((doc) => Assignment.fromDoc(doc))
        .where((assignment) => 
            !assignment.isActive || 
            assignment.dueDate.isBefore(DateTime.now()))
        .toList();
    
    assignments.sort((a, b) => b.dueDate.compareTo(a.dueDate));
    return assignments;
  }

  Future<List<Assignment>> getOverdueAssignmentsByFaculty(String facultyId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('facultyId', isEqualTo: facultyId)
        .where('isActive', isEqualTo: true)
        .get();
    
    final assignments = snapshot.docs
        .map((doc) => Assignment.fromDoc(doc))
        .where((assignment) => assignment.dueDate.isBefore(DateTime.now()))
        .toList();
    
    assignments.sort((a, b) => b.dueDate.compareTo(a.dueDate));
    return assignments;
  }

  Future<List<Assignment>> getAssignmentsBySubject(String facultyId, String subject) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('facultyId', isEqualTo: facultyId)
        .where('subject', isEqualTo: subject)
        .get();
    
    final assignments = snapshot.docs.map((doc) => Assignment.fromDoc(doc)).toList();
    assignments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return assignments;
  }

  Future<List<Assignment>> getAssignmentsByDepartmentAndSection(
    String facultyId, 
    String department, 
    String section
  ) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('facultyId', isEqualTo: facultyId)
        .where('department', isEqualTo: department)
        .where('section', isEqualTo: section)
        .get();
    
    final assignments = snapshot.docs.map((doc) => Assignment.fromDoc(doc)).toList();
    assignments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return assignments;
  }

  Future<List<Assignment>> searchAssignments(String facultyId, String query) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('facultyId', isEqualTo: facultyId)
        .get();
    
    final assignments = snapshot.docs
        .map((doc) => Assignment.fromDoc(doc))
        .where((assignment) {
          final searchQuery = query.toLowerCase();
          return assignment.title.toLowerCase().contains(searchQuery) ||
                 assignment.description.toLowerCase().contains(searchQuery) ||
                 assignment.subject.toLowerCase().contains(searchQuery) ||
                 assignment.department.toLowerCase().contains(searchQuery);
        })
        .toList();
    
    assignments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return assignments;
  }

  Future<void> extendDeadline(String assignmentId, DateTime newDeadline) async {
    await updateAssignment(assignmentId, {
      'dueDate': Timestamp.fromDate(newDeadline),
    });
  }

  Future<void> toggleAssignmentStatus(String assignmentId, bool isActive) async {
    await updateAssignment(assignmentId, {
      'isActive': isActive,
    });
  }

  // Get assignments statistics for faculty dashboard
  Future<Map<String, int>> getAssignmentStats(String facultyId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('facultyId', isEqualTo: facultyId)
        .get();
    
    final assignments = snapshot.docs.map((doc) => Assignment.fromDoc(doc)).toList();
    final now = DateTime.now();
    
    int activeCount = 0;
    int closedCount = 0;
    int overdueCount = 0;
    
    for (final assignment in assignments) {
      if (assignment.isActive && assignment.dueDate.isAfter(now)) {
        activeCount++;
      } else if (!assignment.isActive || assignment.dueDate.isBefore(now)) {
        if (assignment.isActive && assignment.dueDate.isBefore(now)) {
          overdueCount++;
        }
        closedCount++;
      }
    }
    
    return {
      'total': assignments.length,
      'active': activeCount,
      'closed': closedCount,
      'overdue': overdueCount,
    };
  }
}
