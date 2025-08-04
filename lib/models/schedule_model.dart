import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:radiant_app/config/app_config.dart';

class Schedule {
  final String id;
  final String department; // From AppConfig.departmentCodes
  final String departmentName; // From AppConfig.departments
  final int semester; // 1-8 from AppConfig.semesters
  final String section; // From AppConfig.sectionsByDepartment
  final String dayOfWeek; // Monday, Tuesday, etc.
  final List<ScheduleSubject> subjects;
  final String type; // 'lecture', 'lab', 'tutorial', 'exam'
  final DateTime createdAt;
  final DateTime updatedAt;

  Schedule({
    required this.id,
    required this.department,
    required this.departmentName,
    required this.semester,
    required this.section,
    required this.dayOfWeek,
    required this.subjects,
    this.type = 'lecture',
    required this.createdAt,
    required this.updatedAt,
  });

  factory Schedule.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Schedule(
      id: doc.id,
      department: data['department'] ?? '',
      departmentName: data['departmentName'] ?? '',
      semester: data['semester'] ?? 1,
      section: data['section'] ?? '',
      dayOfWeek: data['dayOfWeek'] ?? '',
      subjects: (data['subjects'] as List<dynamic>? ?? [])
          .map((subject) => ScheduleSubject.fromMap(subject as Map<String, dynamic>))
          .toList(),
      type: data['type'] ?? 'lecture',
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
      'department': department,
      'departmentName': departmentName,
      'semester': semester,
      'section': section,
      'dayOfWeek': dayOfWeek,
      'subjects': subjects.map((subject) => subject.toMap()).toList(),
      'type': type,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Validation methods using AppConfig
  bool get isValidDepartment => AppConfig.departmentCodes.contains(department);
  bool get isValidDepartmentName => AppConfig.departments.contains(departmentName);
  bool get isValidSemester => semester >= 1 && semester <= 8;
  bool get isValidSection => AppConfig.sectionsByDepartment[department]?.contains(section) ?? false;
  bool get isValidDayOfWeek => ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'].contains(dayOfWeek);
  
  // Helper methods
  String get semesterString => semester.toString();
  List<String> get availableSubjects => AppConfig.getSubjectsForDepartment(department, semesterString);
  
  // Validation for all subjects in schedule
  bool get areSubjectsValid {
    final availableSubjectsForSemester = AppConfig.getSubjectsForDepartment(department, semesterString);
    return subjects.every((subject) => availableSubjectsForSemester.contains(subject.subjectName));
  }
  
  // Copy method
  Schedule copyWith({
    String? id,
    String? department,
    String? departmentName,
    int? semester,
    String? section,
    String? dayOfWeek,
    List<ScheduleSubject>? subjects,
    String? type,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Schedule(
      id: id ?? this.id,
      department: department ?? this.department,
      departmentName: departmentName ?? this.departmentName,
      semester: semester ?? this.semester,
      section: section ?? this.section,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      subjects: subjects ?? this.subjects,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Subject model for schedule
class ScheduleSubject {
  final String subjectName; // From AppConfig.departmentSubjects
  final String facultyId;
  final String facultyName;
  final String startTime; // "09:00"
  final String endTime;   // "10:00" 
  final String room;
  final String type; // 'lecture', 'lab', 'tutorial', 'exam'
  
  ScheduleSubject({
    required this.subjectName,
    required this.facultyId,
    required this.facultyName,
    required this.startTime,
    required this.endTime,
    required this.room,
    this.type = 'lecture',
  });
  
  factory ScheduleSubject.fromMap(Map<String, dynamic> map) {
    return ScheduleSubject(
      subjectName: map['subjectName'] ?? '',
      facultyId: map['facultyId'] ?? '',
      facultyName: map['facultyName'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      room: map['room'] ?? '',
      type: map['type'] ?? 'lecture',
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'subjectName': subjectName,
      'facultyId': facultyId,
      'facultyName': facultyName,
      'startTime': startTime,
      'endTime': endTime,
      'room': room,
      'type': type,
    };
  }
  
  ScheduleSubject copyWith({
    String? subjectName,
    String? facultyId,
    String? facultyName,
    String? startTime,
    String? endTime,
    String? room,
    String? type,
  }) {
    return ScheduleSubject(
      subjectName: subjectName ?? this.subjectName,
      facultyId: facultyId ?? this.facultyId,
      facultyName: facultyName ?? this.facultyName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
      type: type ?? this.type,
    );
  }

  // Static helper methods for validation using AppConfig
  static bool isValidDepartmentCode(String departmentCode) {
    return AppConfig.departmentCodes.contains(departmentCode);
  }
  
  static bool isValidDepartmentName(String departmentName) {
    return AppConfig.departments.contains(departmentName);
  }
  
  static bool isValidSectionForDepartment(String departmentCode, String section) {
    return AppConfig.sectionsByDepartment[departmentCode]?.contains(section) ?? false;
  }
  
  static bool isValidSubjectForDepartmentAndSemester(String departmentCode, int semester, String subjectName) {
    return AppConfig.getSubjectsForDepartment(departmentCode, semester.toString()).contains(subjectName);
  }
  
  static List<String> getValidSectionsForDepartment(String departmentCode) {
    return AppConfig.sectionsByDepartment[departmentCode] ?? [];
  }
  
  static List<String> getValidSubjectsForDepartmentAndSemester(String departmentCode, int semester) {
    return AppConfig.getSubjectsForDepartment(departmentCode, semester.toString());
  }
  
  static String getDepartmentNameFromCode(String departmentCode) {
    final index = AppConfig.departmentCodes.indexOf(departmentCode);
    if (index != -1 && index < AppConfig.departments.length) {
      return AppConfig.departments[index];
    }
    return departmentCode;
  }
  
  static String getDepartmentCodeFromName(String departmentName) {
    final index = AppConfig.departments.indexOf(departmentName);
    if (index != -1 && index < AppConfig.departmentCodes.length) {
      return AppConfig.departmentCodes[index];
    }
    return departmentName;
  }
}
