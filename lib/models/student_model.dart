import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String id;
  final String name;
  final String usn;
  final String mobile;
  final String email;
  final String branch;
  final String section;
  final int currentSemester;
  final int year;
  final String address;
  final String? profileImage;
  final DateTime dateOfAdmission;

  Student({
    required this.id,
    required this.name,
    required this.usn,
    required this.mobile,
    required this.email,
    required this.branch,
    required this.section,
    required this.currentSemester,
    required this.year,
    required this.address,
    this.profileImage,
    required this.dateOfAdmission,
  });

  factory Student.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Student(
      id: doc.id,
      name: data['name'] ?? '',
      usn: data['usn'] ?? '',
      mobile: data['mobile'] ?? '',
      email: data['email'] ?? '',
      branch: data['branch'] ?? '',
      section: data['section'] ?? '',
      currentSemester: data['currentSemester'] ?? 1,
      year: data['year'] ?? 1,
      address: data['address'] ?? '',
      profileImage: data['profileImage'],
      dateOfAdmission: data['dateOfAdmission'] != null 
          ? (data['dateOfAdmission'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'usn': usn,
      'mobile': mobile,
      'email': email,
      'branch': branch,
      'section': section,
      'currentSemester': currentSemester,
      'year': year,
      'address': address,
      'profileImage': profileImage,
      'dateOfAdmission': Timestamp.fromDate(dateOfAdmission),
    };
  }
}
