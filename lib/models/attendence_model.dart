import 'package:cloud_firestore/cloud_firestore.dart';

class Attendance {
  final String id;
  final String department;
  final int semester;
  final String section;
  final String subject;
  final String classDate;
  final String classTime;
  final String markedBy;
  final List<String> studentsPresent;
  final List<String> studentsAbsent;

  Attendance({
    required this.id,
    required this.department,
    required this.semester,
    required this.section,
    required this.subject,
    required this.classDate,
    required this.classTime,
    required this.markedBy,
    required this.studentsPresent,
    required this.studentsAbsent,
  });

  factory Attendance.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Attendance(
      id: doc.id,
      department: data['department'],
      semester: data['semester'],
      section: data['section'],
      subject: data['subject'],
      classDate: data['classDate'],
      classTime: data['classTime'],
      markedBy: data['markedBy'],
      studentsPresent: List<String>.from(data['studentsPresent']),
      studentsAbsent: List<String>.from(data['studentsAbsent']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'department': department,
      'semester': semester,
      'section': section,
      'subject': subject,
      'classDate': classDate,
      'classTime': classTime,
      'markedBy': markedBy,
      'studentsPresent': studentsPresent,
      'studentsAbsent': studentsAbsent,
    };
  }
}
