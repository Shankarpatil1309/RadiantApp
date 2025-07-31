import 'package:cloud_firestore/cloud_firestore.dart';

class Assignment {
  final String id;
  final String title;
  final String description;
  final String? fileUrl;
  final String subject;
  final String department;
  final String section;
  final int semester;
  final DateTime dueDate;
  final String facultyId;
  final String facultyName;
  final int maxMarks;
  final String type; // 'assignment', 'project', 'lab', etc.
  final bool isActive;
  final List<String> allowedFormats; // ['pdf', 'docx', 'jpg', etc.]
  final String? instructions;
  final DateTime createdAt;
  final DateTime updatedAt;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    this.fileUrl,
    required this.subject,
    required this.department,
    required this.section,
    required this.semester,
    required this.dueDate,
    required this.facultyId,
    required this.facultyName,
    this.maxMarks = 100,
    this.type = 'assignment',
    this.isActive = true,
    this.allowedFormats = const ['pdf', 'docx', 'jpg', 'png'],
    this.instructions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Assignment.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Assignment(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      fileUrl: data['fileUrl'],
      subject: data['subject'] ?? '',
      department: data['department'] ?? '',
      section: data['section'] ?? '',
      semester: data['semester'] ?? 1,
      dueDate: data['dueDate'] != null 
          ? (data['dueDate'] as Timestamp).toDate() 
          : DateTime.now(),
      facultyId: data['facultyId'] ?? '',
      facultyName: data['facultyName'] ?? '',
      maxMarks: data['maxMarks'] ?? 100,
      type: data['type'] ?? 'assignment',
      isActive: data['isActive'] ?? true,
      allowedFormats: List<String>.from(data['allowedFormats'] ?? ['pdf', 'docx']),
      instructions: data['instructions'],
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
      'description': description,
      'fileUrl': fileUrl,
      'subject': subject,
      'department': department,
      'section': section,
      'semester': semester,
      'dueDate': Timestamp.fromDate(dueDate),
      'facultyId': facultyId,
      'facultyName': facultyName,
      'maxMarks': maxMarks,
      'type': type,
      'isActive': isActive,
      'allowedFormats': allowedFormats,
      'instructions': instructions,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Helper getter for backward compatibility
  String get uploadedBy => facultyName;
  
  // Helper methods for file handling
  bool get hasFile => fileUrl != null && fileUrl!.isNotEmpty;
  
  String get fileName {
    if (!hasFile) return '';
    try {
      final uri = Uri.parse(fileUrl!);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        final fileName = pathSegments.last;
        // Remove Firebase Storage tokens and return clean filename
        final cleanName = fileName.split('?').first;
        // Decode URL encoding
        return Uri.decodeComponent(cleanName);
      }
    } catch (e) {
      // Fallback if URL parsing fails
    }
    return 'Assignment File';
  }
  
  String get fileExtension {
    if (!hasFile) return '';
    try {
      final name = fileName;
      final lastDotIndex = name.lastIndexOf('.');
      if (lastDotIndex != -1 && lastDotIndex < name.length - 1) {
        return name.substring(lastDotIndex + 1).toLowerCase();
      }
    } catch (e) {
      // Fallback if parsing fails
    }
    return '';
  }
}
