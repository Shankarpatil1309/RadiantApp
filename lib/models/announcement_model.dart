import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  final String id;
  final String title;
  final String message;
  final String? department; // null means for all
  final String createdBy;
  final DateTime createdAt;
  final String priority;

  Announcement({
    required this.id,
    required this.title,
    required this.message,
    this.department,
    required this.createdBy,
    required this.createdAt,
    required this.priority,
  });

  factory Announcement.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Announcement(
      id: doc.id,
      title: data['title'],
      message: data['message'],
      department: data['department'],
      createdBy: data['createdBy'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      priority: data['priority'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'department': department,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'priority': priority,
    };
  }
}
