import 'package:cloud_firestore/cloud_firestore.dart';

class ClassSession {
  final String id;
  final String title;
  final String subject;
  final String? subjectCode;
  final String department;
  final String section;
  final int semester;
  final String facultyId;
  final String facultyName;
  final String room;
  final String date; // "2025-01-15"
  final DateTime startTime;
  final DateTime endTime;
  final String type; // 'lecture', 'lab', 'tutorial', 'exam'
  final String? description;
  final String status; // 'scheduled', 'completed', 'cancelled'
  final DateTime createdAt;
  final DateTime updatedAt;

  ClassSession({
    required this.id,
    required this.title,
    required this.subject,
    this.subjectCode,
    required this.department,
    required this.section,
    required this.semester,
    required this.facultyId,
    required this.facultyName,
    required this.room,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.type = 'lecture',
    this.description,
    this.status = 'scheduled',
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClassSession.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClassSession(
      id: doc.id,
      title: data['title'] ?? '',
      subject: data['subject'] ?? '',
      subjectCode: data['subjectCode'],
      department: data['department'] ?? '',
      section: data['section'] ?? '',
      semester: data['semester'] ?? 1,
      facultyId: data['facultyId'] ?? '',
      facultyName: data['facultyName'] ?? '',
      room: data['room'] ?? '',
      date: data['date'] ?? '',
      startTime: data['startTime'] != null 
          ? (data['startTime'] as Timestamp).toDate() 
          : DateTime.now(),
      endTime: data['endTime'] != null 
          ? (data['endTime'] as Timestamp).toDate() 
          : DateTime.now().add(Duration(hours: 1)),
      type: data['type'] ?? 'lecture',
      description: data['description'],
      status: data['status'] ?? 'scheduled',
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
      'subject': subject,
      'subjectCode': subjectCode,
      'department': department,
      'section': section,
      'semester': semester,
      'facultyId': facultyId,
      'facultyName': facultyName,
      'room': room,
      'date': date,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'type': type,
      'description': description,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Helper getters
  Duration get duration => endTime.difference(startTime);
  
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDate = DateTime(startTime.year, startTime.month, startTime.day);
    return today == sessionDate;
  }
  
  bool get isUpcoming => startTime.isAfter(DateTime.now());
  
  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }
  
  bool get isCompleted => status == 'completed';
  
  // Copy method for schedule copying functionality
  ClassSession copyWith({
    String? id,
    String? title,
    String? subject,
    String? subjectCode,
    String? department,
    String? section,
    int? semester,
    String? facultyId,
    String? facultyName,
    String? room,
    String? date,
    DateTime? startTime,
    DateTime? endTime,
    String? type,
    String? description,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClassSession(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      subjectCode: subjectCode ?? this.subjectCode,
      department: department ?? this.department,
      section: section ?? this.section,
      semester: semester ?? this.semester,
      facultyId: facultyId ?? this.facultyId,
      facultyName: facultyName ?? this.facultyName,
      room: room ?? this.room,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}