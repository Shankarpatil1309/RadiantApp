import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get admin data from Firebase admin collection
  Future<Map<String, dynamic>?> getAdminData() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      // First, try to get admin data by UID from admin collection
      final adminByUidQuery = await _firestore
          .collection('admin')
          .where('uid', isEqualTo: currentUser.uid)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      Map<String, dynamic>? adminData;
      
      if (adminByUidQuery.docs.isNotEmpty) {
        adminData = adminByUidQuery.docs.first.data();
      } else {
        // Fallback: try to get admin data by email
        final adminByEmailQuery = await _firestore
            .collection('admin')
            .where('email', isEqualTo: currentUser.email?.toLowerCase())
            .where('isActive', isEqualTo: true)
            .limit(1)
            .get();
            
        if (adminByEmailQuery.docs.isNotEmpty) {
          adminData = adminByEmailQuery.docs.first.data();
          
          // Link UID to admin document
          await adminByEmailQuery.docs.first.reference.update({
            'uid': currentUser.uid,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      if (adminData != null) {
        // Get additional real-time stats
        final statistics = await getStatisticsData();
        
        return {
          "id": adminData['adminId'] ?? adminData['employeeId'] ?? currentUser.uid,
          "name": adminData['name'] ?? currentUser.displayName ?? "Administrator",
          "designation": adminData['designation'] ?? "Administrator",
          "employeeId": adminData['employeeId'] ?? adminData['adminId'] ?? "ADM001",
          "officeNumber": adminData['officeNumber'] ?? "101",
          "email": adminData['email'] ?? currentUser.email ?? "",
          "phone": adminData['phone'] ?? "",
          "joiningDate": adminData['joiningDate']?.toDate() ?? DateTime.now(),
          "profileImage": adminData['profileImage'] ?? currentUser.photoURL ?? "",
          "department": adminData['department'] ?? "Administration",
          "unreadNotifications": await _getUnreadNotificationsCount(),
          "totalDepartments": statistics['totalDepartments'] ?? 0,
          "activeSessions": await _getActiveSessionsCount(),
          "todayAttendance": await _getTodayAttendancePercentage(),
        };
      }

      // Fallback: Create basic admin data if not found in admin collection
      return {
        "id": currentUser.uid,
        "name": currentUser.displayName ?? "Administrator",
        "designation": "Administrator", 
        "employeeId": "ADM001",
        "officeNumber": "101",
        "email": currentUser.email ?? "",
        "phone": "",
        "joiningDate": DateTime.now(),
        "profileImage": currentUser.photoURL ?? "",
        "department": "Administration",
        "unreadNotifications": 0,
        "totalDepartments": 6,
        "activeSessions": 0,
        "todayAttendance": 0,
      };
    } catch (e) {
      print('Error fetching admin data: $e');
      return null;
    }
  }

  /// Get statistics data from Firebase collections
  Future<Map<String, dynamic>> getStatisticsData() async {
    try {
      // Get total students count - simplified query
      final studentsSnapshot = await _firestore
          .collection('students')
          .get();
      
      // Get total faculty count - simplified query  
      final facultySnapshot = await _firestore
          .collection('faculty')
          .get();
      
      // Filter active students and faculty client-side
      final activeStudents = studentsSnapshot.docs
          .where((doc) => doc.data()['isActive'] == true)
          .toList();
          
      final activeFaculty = facultySnapshot.docs
          .where((doc) => doc.data()['isActive'] == true)
          .toList();

      // Calculate active users from both collections instead of users collection
      // This avoids the complex index requirement
      final totalActiveUsers = activeStudents.length + activeFaculty.length;

      // Get departments count from active students
      final Set<String> departments = {};
      for (var doc in activeStudents) {
        final branch = doc.data()['branch'] as String?;
        if (branch != null && branch.isNotEmpty) {
          departments.add(branch);
        }
      }

      // Get sections count from active students
      final Set<String> sections = {};
      for (var doc in activeStudents) {
        final branch = doc.data()['branch'] as String?;
        final section = doc.data()['section'] as String?;
        if (branch != null && section != null) {
          sections.add('$branch-$section');
        }
      }

      return {
        "totalStudents": activeStudents.length,
        "totalFaculty": activeFaculty.length,
        "activeUsers": totalActiveUsers,
        "totalDepartments": departments.length,
        "totalSections": sections.length,
      };
    } catch (e) {
      print('Error fetching statistics data: $e');
      return {
        "totalStudents": 0,
        "totalFaculty": 0,
        "activeUsers": 0,
        "totalDepartments": 0,
        "totalSections": 0,
      };
    }
  }

  /// Get announcements data from Firebase
  Future<List<Map<String, dynamic>>> getAnnouncementsData() async {
    try {
      // Simplified query without composite index requirement
      final announcementsSnapshot = await _firestore
          .collection('announcements')
          .orderBy('createdAt', descending: true)
          .limit(20) // Get more to filter client-side
          .get();

      // Filter active announcements client-side to avoid index requirement
      final activeAnnouncements = announcementsSnapshot.docs
          .where((doc) => doc.data()['isActive'] == true)
          .take(10) // Take only 10 after filtering
          .map((doc) {
        final data = doc.data();
        return {
          "id": doc.id,
          "title": data['title'] ?? '',
          "content": data['content'] ?? '',
          "priority": data['priority'] ?? 'normal',
          "author": data['author'] ?? 'Unknown',
          "timestamp": (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          "departments": List<String>.from(data['departments'] ?? []),
          "readCount": (data['readBy'] as List?)?.length ?? 0,
        };
      }).toList();

      return activeAnnouncements;
    } catch (e) {
      print('Error fetching announcements data: $e');
      return [];
    }
  }

  /// Get recent activities data from Firebase (you may need to create an activities collection)
  Future<List<Map<String, dynamic>>> getRecentActivitiesData() async {
    try {
      // For now, we'll create mock data, but you can implement a real activities collection
      final now = DateTime.now();
      
      return [
        {
          "id": "ACT001",
          "type": "registration",
          "title": "New Student Registration",
          "description": "New students registered for various departments",
          "timestamp": now.subtract(Duration(minutes: 15)),
          "department": "Multiple",
        },
        {
          "id": "ACT002",
          "type": "attendance",
          "title": "Attendance Updated",
          "description": "Faculty marked attendance for classes",
          "timestamp": now.subtract(Duration(minutes: 45)),
          "department": "Multiple",
        },
        {
          "id": "ACT003",
          "type": "announcement",
          "title": "Announcement Posted",
          "description": "New announcements published",
          "timestamp": now.subtract(Duration(hours: 1)),
          "department": "Academic",
        },
      ];
    } catch (e) {
      print('Error fetching recent activities data: $e');
      return [];
    }
  }

  /// Get unread notifications count for current admin
  Future<int> _getUnreadNotificationsCount() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return 0;

      // This would depend on your notifications structure
      // For now, returning 0 as placeholder
      return 0;
    } catch (e) {
      print('Error fetching unread notifications count: $e');
      return 0;
    }
  }

  /// Get active sessions count
  Future<int> _getActiveSessionsCount() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Count class sessions for today (if you have a class_sessions collection)
      final sessionsSnapshot = await _firestore
          .collection('class_sessions')
          .where('date', isGreaterThanOrEqualTo: today)
          .where('date', isLessThan: today.add(Duration(days: 1)))
          .where('status', isEqualTo: 'active')
          .get();
      
      return sessionsSnapshot.docs.length;
    } catch (e) {
      print('Error fetching active sessions count: $e');
      return 0;
    }
  }

  /// Get today's attendance percentage
  Future<int> _getTodayAttendancePercentage() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Calculate attendance percentage based on attendance records
      final attendanceSnapshot = await _firestore
          .collection('attendance')
          .where('date', isGreaterThanOrEqualTo: today)
          .where('date', isLessThan: today.add(Duration(days: 1)))
          .get();
      
      if (attendanceSnapshot.docs.isEmpty) return 0;
      
      int totalPresent = 0;
      int totalStudents = 0;
      
      for (var doc in attendanceSnapshot.docs) {
        final data = doc.data();
        final attendance = data['attendance'] as Map<String, dynamic>?;
        if (attendance != null) {
          totalStudents += attendance.length;
          totalPresent += attendance.values.where((status) => status == 'present').length;
        }
      }
      
      return totalStudents > 0 ? ((totalPresent / totalStudents) * 100).round() : 0;
    } catch (e) {
      print('Error fetching today\'s attendance percentage: $e');
      return 0;
    }
  }

  /// Get admin by UID (similar to faculty service pattern)
  Future<Map<String, dynamic>?> getAdminByUid(String uid) async {
    try {
      final query = await _firestore
          .collection('admin')
          .where('uid', isEqualTo: uid)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        return query.docs.first.data();
      }
      return null;
    } catch (e) {
      print('Error fetching admin by UID: $e');
      return null;
    }
  }

  /// Get admin by email (similar to faculty service pattern)
  Future<Map<String, dynamic>?> getAdminByEmail(String email) async {
    try {
      final query = await _firestore
          .collection('admin')
          .where('email', isEqualTo: email.toLowerCase())
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        return query.docs.first.data();
      }
      return null;
    } catch (e) {
      print('Error fetching admin by email: $e');
      return null;
    }
  }

  /// Link UID to admin record (similar to faculty service pattern)
  Future<void> linkUidToAdmin(String email, String uid) async {
    try {
      final existingAdmin = await getAdminByEmail(email);
      if (existingAdmin != null) {
        // Find the document and update it
        final query = await _firestore
            .collection('admin')
            .where('email', isEqualTo: email.toLowerCase())
            .where('isActive', isEqualTo: true)
            .limit(1)
            .get();
            
        if (query.docs.isNotEmpty) {
          await query.docs.first.reference.update({
            'uid': uid,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          print('✅ Linked UID $uid to admin ${existingAdmin['adminId'] ?? existingAdmin['employeeId']}');
        }
      }
    } catch (e) {
      print('Error linking UID to admin: $e');
    }
  }

  /// Create announcement
  Future<void> createAnnouncement(Map<String, dynamic> announcementData) async {
    try {
      await _firestore.collection('announcements').add({
        ...announcementData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'readBy': <String>[],
      });
    } catch (e) {
      print('Error creating announcement: $e');
      rethrow;
    }
  }
}