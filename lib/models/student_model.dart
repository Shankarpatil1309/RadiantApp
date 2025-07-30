import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String id;
  final String usn;
  final String mobile;
  final String branch;
  final String section;
  final int currentSemester;
  final int year;
  final String address;
  final DateTime dateOfAdmission;

  Student({
    required this.id,
    required this.usn,
    required this.mobile,
    required this.branch,
    required this.section,
    required this.currentSemester,
    required this.year,
    required this.address,
    required this.dateOfAdmission,
  });

  factory Student.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Student(
      id: doc.id,
      usn: data['usn'],
      mobile: data['mobile'],
      branch: data['branch'],
      section: data['section'],
      currentSemester: data['currentSemester'],
      year: data['year'],
      address: data['address'],
      dateOfAdmission: (data['dateOfAdmission'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'usn': usn,
      'mobile': mobile,
      'branch': branch,
      'section': section,
      'currentSemester': currentSemester,
      'year': year,
      'address': address,
      'dateOfAdmission': dateOfAdmission,
    };
  }
}
