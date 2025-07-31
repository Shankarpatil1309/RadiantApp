import 'package:cloud_firestore/cloud_firestore.dart';

class ClassSession {
  final String id;
  final String title;
  final String subject;
  final String department;
  final String section;
  final int semester;
  final String facultyId;
  final String facultyName;
  final String room;
  final DateTime startTime;
  final DateTime endTime;
  final String type; // 'lecture', 'lab', 'tutorial', 'exam'
  final String? description;
  final bool isActive;
  final bool isRecurring;
  final String? recurringPattern; // 'daily', 'weekly', 'monthly'
  final DateTime? recurringEndDate;
  final List<String> attendees; // Student IDs who attended
  final String status; // 'scheduled', 'ongoing', 'completed', 'cancelled'
  final DateTime createdAt;
  final DateTime updatedAt;

  ClassSession({
    required this.id,
    required this.title,
    required this.subject,
    required this.department,
    required this.section,
    required this.semester,
    required this.facultyId,
    required this.facultyName,
    required this.room,
    required this.startTime,
    required this.endTime,
    this.type = 'lecture',
    this.description,
    this.isActive = true,
    this.isRecurring = false,
    this.recurringPattern,
    this.recurringEndDate,
    this.attendees = const [],
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
      department: data['department'] ?? '',
      section: data['section'] ?? '',
      semester: data['semester'] ?? 1,
      facultyId: data['facultyId'] ?? '',
      facultyName: data['facultyName'] ?? '',
      room: data['room'] ?? '',
      startTime: data['startTime'] != null 
          ? (data['startTime'] as Timestamp).toDate() 
          : DateTime.now(),
      endTime: data['endTime'] != null 
          ? (data['endTime'] as Timestamp).toDate() 
          : DateTime.now().add(Duration(hours: 1)),
      type: data['type'] ?? 'lecture',
      description: data['description'],
      isActive: data['isActive'] ?? true,
      isRecurring: data['isRecurring'] ?? false,
      recurringPattern: data['recurringPattern'],
      recurringEndDate: data['recurringEndDate'] != null 
          ? (data['recurringEndDate'] as Timestamp).toDate() 
          : null,
      attendees: List<String>.from(data['attendees'] ?? []),
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
      'department': department,
      'section': section,
      'semester': semester,
      'facultyId': facultyId,
      'facultyName': facultyName,
      'room': room,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'type': type,
      'description': description,
      'isActive': isActive,
      'isRecurring': isRecurring,
      'recurringPattern': recurringPattern,
      'recurringEndDate': recurringEndDate != null 
          ? Timestamp.fromDate(recurringEndDate!) 
          : null,
      'attendees': attendees,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Helper getters
  Duration get duration => endTime.difference(startTime);
  bool get isToday {
    final now = DateTime.now();
    return startTime.year == now.year && 
           startTime.month == now.month && 
           startTime.day == now.day;
  }
  bool get isUpcoming => startTime.isAfter(DateTime.now());
  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }
  bool get isCompleted => endTime.isBefore(DateTime.now());
}