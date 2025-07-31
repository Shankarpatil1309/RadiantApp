import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { ADMIN, FACULTY, STUDENT }

class AppUser {
  final String id; // Document ID (same as UID)
  final String uid; // Firebase Auth UID
  final String email;
  final UserRole role;
  final String? uniqueId; // employeeId for faculty, USN for students (for reference)
  final DateTime? lastLoginAt;
  final bool isActive;
  final DateTime? createdAt;

  AppUser({
    required this.id,
    required this.uid,
    required this.email,
    required this.role,
    this.uniqueId,
    this.lastLoginAt,
    required this.isActive,
    this.createdAt,
  });

  factory AppUser.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      uid: data['uid'] ?? doc.id,
      email: data['email'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == data['role'],
        orElse: () => UserRole.STUDENT,
      ),
      uniqueId: data['uniqueId'],
      lastLoginAt: data['lastLoginAt'] != null
          ? (data['lastLoginAt'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role.name,
      'uniqueId': uniqueId,
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }
}
