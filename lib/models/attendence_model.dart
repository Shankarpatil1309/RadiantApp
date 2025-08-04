import 'package:cloud_firestore/cloud_firestore.dart';

class Attendance {
  final String id;
  final String classSessionId;
  final String date;
  final String subject;
  final String? subjectCode;
  final String department;
  final String section;
  final int semester;
  final String facultyId;
  final int totalStudents;
  final int presentCount;
  final int absentCount;
  final List<String> studentsPresent;
  final List<String> studentsAbsent;
  final DateTime markedAt;

  Attendance({
    required this.id,
    required this.classSessionId,
    required this.date,
    required this.subject,
    this.subjectCode,
    required this.department,
    required this.section,
    required this.semester,
    required this.facultyId,
    required this.totalStudents,
    required this.presentCount,
    required this.absentCount,
    required this.studentsPresent,
    required this.studentsAbsent,
    required this.markedAt,
  });

  factory Attendance.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Attendance(
      id: doc.id,
      classSessionId: data['classSessionId'] ?? '',
      date: data['date'] ?? '',
      subject: data['subject'] ?? '',
      subjectCode: data['subjectCode'],
      department: data['department'] ?? '',
      section: data['section'] ?? '',
      semester: data['semester'] ?? 1,
      facultyId: data['facultyId'] ?? '',
      totalStudents: data['totalStudents'] ?? 0,
      presentCount: data['presentCount'] ?? 0,
      absentCount: data['absentCount'] ?? 0,
      studentsPresent: List<String>.from(data['studentsPresent'] ?? []),
      studentsAbsent: List<String>.from(data['studentsAbsent'] ?? []),
      markedAt: data['markedAt'] != null 
          ? (data['markedAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'classSessionId': classSessionId,
      'date': date,
      'subject': subject,
      'subjectCode': subjectCode,
      'department': department,
      'section': section,
      'semester': semester,
      'facultyId': facultyId,
      'totalStudents': totalStudents,
      'presentCount': presentCount,
      'absentCount': absentCount,
      'studentsPresent': studentsPresent,
      'studentsAbsent': studentsAbsent,
      'markedAt': Timestamp.fromDate(markedAt),
    };
  }
}
