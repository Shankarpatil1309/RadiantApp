import 'package:cloud_firestore/cloud_firestore.dart';

class Schedule {
  final String id;
  final String department;
  final int semester;
  final String section;
  final String dayOfWeek;
  final List<Map<String, dynamic>> subjects;

  Schedule({
    required this.id,
    required this.department,
    required this.semester,
    required this.section,
    required this.dayOfWeek,
    required this.subjects,
  });

  factory Schedule.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Schedule(
      id: doc.id,
      department: data['department'],
      semester: data['semester'],
      section: data['section'],
      dayOfWeek: data['dayOfWeek'],
      subjects: List<Map<String, dynamic>>.from(data['subjects']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'department': department,
      'semester': semester,
      'section': section,
      'dayOfWeek': dayOfWeek,
      'subjects': subjects,
    };
  }
}
