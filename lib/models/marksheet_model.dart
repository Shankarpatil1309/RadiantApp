import 'package:cloud_firestore/cloud_firestore.dart';

class Marksheet {
  final String id;
  final String studentId;
  final int semester;
  final String department;
  final List<Map<String, dynamic>> marks;
  final String uploadedBy;
  final DateTime createdAt;

  Marksheet({
    required this.id,
    required this.studentId,
    required this.semester,
    required this.department,
    required this.marks,
    required this.uploadedBy,
    required this.createdAt,
  });

  factory Marksheet.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Marksheet(
      id: doc.id,
      studentId: data['studentId'],
      semester: data['semester'],
      department: data['department'],
      marks: List<Map<String, dynamic>>.from(data['marks']),
      uploadedBy: data['uploadedBy'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'semester': semester,
      'department': department,
      'marks': marks,
      'uploadedBy': uploadedBy,
      'createdAt': createdAt,
    };
  }
}
