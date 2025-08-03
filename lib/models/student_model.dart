import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String id;
  final String name;
  final String usn;
  final String phone;
  final String email;
  final String department;
  final String section;
  final int semester;
  final int year;
  final String gender;
  final DateTime dateOfBirth;
  final DateTime admissionDate;
  final String address;
  final String guardianName;
  final String guardianPhone;
  final String emergencyContact;
  final String role;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? profileImage;

  Student({
    required this.id,
    required this.name,
    required this.usn,
    required this.phone,
    required this.email,
    required this.department,
    required this.section,
    required this.semester,
    required this.year,
    required this.gender,
    required this.dateOfBirth,
    required this.admissionDate,
    required this.address,
    required this.guardianName,
    required this.guardianPhone,
    required this.emergencyContact,
    required this.role,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.profileImage,
  });

  factory Student.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Student(
      id: doc.id,
      name: data['name'] ?? '',
      usn: data['usn'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      department: data['department'] ?? '',
      section: data['section'] ?? '',
      semester: data['semester'] ?? 1,
      year: data['year'] ?? 1,
      gender: data['gender'] ?? '',
      dateOfBirth: data['dateOfBirth'] != null 
          ? (data['dateOfBirth'] as Timestamp).toDate()
          : DateTime.now(),
      admissionDate: data['admissionDate'] != null 
          ? (data['admissionDate'] as Timestamp).toDate()
          : DateTime.now(),
      address: data['address'] ?? '',
      guardianName: data['guardianName'] ?? '',
      guardianPhone: data['guardianPhone'] ?? '',
      emergencyContact: data['emergencyContact'] ?? '',
      role: data['role'] ?? 'STUDENT',
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      createdBy: data['createdBy'],
      profileImage: data['profileImage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'usn': usn,
      'phone': phone,
      'email': email,
      'department': department,
      'section': section,
      'semester': semester,
      'year': year,
      'gender': gender,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'admissionDate': Timestamp.fromDate(admissionDate),
      'address': address,
      'guardianName': guardianName,
      'guardianPhone': guardianPhone,
      'emergencyContact': emergencyContact,
      'role': role,
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
      'createdBy': createdBy,
      'profileImage': profileImage,
    };
  }
}
