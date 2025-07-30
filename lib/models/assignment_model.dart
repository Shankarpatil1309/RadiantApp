import 'package:cloud_firestore/cloud_firestore.dart';

class Assignment {
  final String id;
  final String title;
  final String description;
  final String fileUrl;
  final String subject;
  final String department;
  final int semester;
  final DateTime dueDate;
  final String uploadedBy;
  final DateTime createdAt;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.fileUrl,
    required this.subject,
    required this.department,
    required this.semester,
    required this.dueDate,
    required this.uploadedBy,
    required this.createdAt,
  });

  factory Assignment.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Assignment(
      id: doc.id,
      title: data['title'],
      description: data['description'],
      fileUrl: data['fileUrl'],
      subject: data['subject'],
      department: data['department'],
      semester: data['semester'],
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      uploadedBy: data['uploadedBy'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'fileUrl': fileUrl,
      'subject': subject,
      'department': department,
      'semester': semester,
      'dueDate': dueDate,
      'uploadedBy': uploadedBy,
      'createdAt': createdAt,
    };
  }
}
