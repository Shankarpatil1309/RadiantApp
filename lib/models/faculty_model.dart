import 'package:cloud_firestore/cloud_firestore.dart';

class Faculty {
  final String id;
  final String department;
  final String designation;
  final String employeeId;
  final DateTime joiningDate;

  Faculty({
    required this.id,
    required this.department,
    required this.designation,
    required this.employeeId,
    required this.joiningDate,
  });

  factory Faculty.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Faculty(
      id: doc.id,
      department: data['department'],
      designation: data['designation'],
      employeeId: data['employeeId'],
      joiningDate: (data['joiningDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'department': department,
      'designation': designation,
      'employeeId': employeeId,
      'joiningDate': joiningDate,
    };
  }
}
