import 'package:cloud_firestore/cloud_firestore.dart';

class Faculty {
  final String id; // Document ID (employeeId)
  final String? uid; // Firebase Auth UID (linked when user signs in)
  final String name;
  final String email;
  final String phone;
  final String employeeId;
  final String department;
  final String designation;
  final String gender;
  final DateTime dateOfBirth;
  final DateTime joiningDate;
  final double salary;
  final String address;
  final String qualification;
  final String experience;
  final List<String> specializedSubjects;
  final String emergencyContact;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  Faculty({
    required this.id,
    this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.employeeId,
    required this.department,
    required this.designation,
    required this.gender,
    required this.dateOfBirth,
    required this.joiningDate,
    required this.salary,
    required this.address,
    required this.qualification,
    required this.experience,
    required this.specializedSubjects,
    required this.emergencyContact,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  factory Faculty.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Faculty(
      id: doc.id, // This will be the employeeId
      uid: data['uid'],
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      employeeId: data['employeeId'] ?? doc.id, // Fallback to doc.id
      department: data['department'] ?? '',
      designation: data['designation'] ?? '',
      gender: data['gender'] ?? '',
      dateOfBirth: data['dateOfBirth'] != null 
          ? (data['dateOfBirth'] as Timestamp).toDate()
          : DateTime.now(),
      joiningDate: data['joiningDate'] != null
          ? (data['joiningDate'] as Timestamp).toDate()
          : DateTime.now(),
      salary: (data['salary'] ?? 0).toDouble(),
      address: data['address'] ?? '',
      qualification: data['qualification'] ?? '',
      experience: data['experience'] ?? '',
      specializedSubjects: data['specializedSubjects'] != null
          ? List<String>.from(data['specializedSubjects'])
          : [],
      emergencyContact: data['emergencyContact'] ?? '',
      role: data['role'] ?? 'FACULTY',
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'employeeId': employeeId,
      'department': department,
      'designation': designation,
      'gender': gender,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'joiningDate': Timestamp.fromDate(joiningDate),
      'salary': salary,
      'address': address,
      'qualification': qualification,
      'experience': experience,
      'specializedSubjects': specializedSubjects,
      'emergencyContact': emergencyContact,
      'role': role,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
    };
  }

  // Convenience getter for mobile compatibility
  String get mobile => phone;
}
