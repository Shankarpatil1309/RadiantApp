import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  final String id;
  final String title;
  final String content;
  final String priority;
  final List<String> departments;
  final String author;
  final String? authorId;
  final bool isActive;
  final List<String> readBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.priority,
    required this.departments,
    required this.author,
    this.authorId,
    this.isActive = true,
    this.readBy = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Announcement.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Announcement(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      priority: data['priority'] ?? 'normal',
      departments: List<String>.from(data['departments'] ?? ['All']),
      author: data['author'] ?? '',
      authorId: data['authorId'],
      isActive: data['isActive'] ?? true,
      readBy: List<String>.from(data['readBy'] ?? []),
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'priority': priority,
      'departments': departments,
      'author': author,
      'authorId': authorId,
      'isActive': isActive,
      'readBy': readBy,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Helper getter for backward compatibility
  String get message => content;
  
  // Helper getter for single department (for backward compatibility)
  String? get department => departments.contains('All') ? null : departments.first;
  
  // Helper getter for createdBy (for backward compatibility)
  String get createdBy => author;
}
