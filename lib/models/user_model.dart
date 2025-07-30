import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { ADMIN, FACULTY, STUDENT }

class AppUser {
  final String id;
  final String email;
  final String name;
  final String mobile;
  final UserRole role;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.mobile,
    required this.role,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppUser.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      email: data['email'],
      name: data['name'],
      mobile: data['mobile'],
      role: UserRole.values.firstWhere((e) => e.name == data['role']),
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'mobile': mobile,
      'role': role.name,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
