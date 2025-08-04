import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:radiant_app/models/schedule_model.dart';
import 'package:radiant_app/services/firestore_service.dart';
import 'package:radiant_app/config/app_config.dart';

class ScheduleService {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collection = "schedules";

  Future<void> addSchedule(Schedule schedule) async {
    await _firestoreService.createDocument(
        _collection, schedule.id, schedule.toMap());
  }

  Future<Schedule?> getSchedule(String id) async {
    DocumentSnapshot doc = await _firestoreService.getDocument(_collection, id);
    if (doc.exists) {
      return Schedule.fromDoc(doc);
    }
    return null;
  }

  Future<void> updateSchedule(Schedule schedule) async {
    await _firestoreService.updateDocument(
        _collection, schedule.id, schedule.toMap());
  }

  Future<void> deleteSchedule(String id) async {
    await _firestoreService.deleteDocument(_collection, id);
  }

  Stream<List<Schedule>> listenSchedules() {
    return _firestoreService.listenToCollection(_collection).map((snapshot) =>
        snapshot.docs.map((doc) => Schedule.fromDoc(doc)).toList());
  }

  // Convenience methods using AppConfig
  Future<List<Schedule>> getSchedulesByDepartment(String departmentCode) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(_collection)
        .where('department', isEqualTo: departmentCode)
        .get();
    
    return snapshot.docs.map((doc) => Schedule.fromDoc(doc)).toList();
  }

  Future<List<Schedule>> getSchedulesByDepartmentAndSemester(String departmentCode, int semester) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(_collection)
        .where('department', isEqualTo: departmentCode)
        .where('semester', isEqualTo: semester)
        .get();
    
    return snapshot.docs.map((doc) => Schedule.fromDoc(doc)).toList();
  }

  Future<List<Schedule>> getSchedulesByDepartmentSemesterAndSection(
    String departmentCode, 
    int semester, 
    String section
  ) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(_collection)
        .where('department', isEqualTo: departmentCode)
        .where('semester', isEqualTo: semester)
        .where('section', isEqualTo: section)
        .get();
    
    return snapshot.docs.map((doc) => Schedule.fromDoc(doc)).toList();
  }

  // Validation method
  Future<bool> validateScheduleBeforeAdding(Schedule schedule) async {
    // Validate department
    if (!schedule.isValidDepartment) {
      throw Exception('Invalid department code: ${schedule.department}');
    }

    // Validate semester
    if (!schedule.isValidSemester) {
      throw Exception('Invalid semester: ${schedule.semester}');
    }

    // Validate section
    if (!schedule.isValidSection) {
      throw Exception('Invalid section: ${schedule.section} for department: ${schedule.department}');
    }

    // Validate subjects
    if (!schedule.areSubjectsValid) {
      throw Exception('One or more subjects are invalid for department: ${schedule.department}, semester: ${schedule.semester}');
    }

    return true;
  }

  Future<void> addValidatedSchedule(Schedule schedule) async {
    await validateScheduleBeforeAdding(schedule);
    await addSchedule(schedule);
  }
}
