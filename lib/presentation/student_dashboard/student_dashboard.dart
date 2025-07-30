import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../controllers/auth_controller.dart';
import './widgets/greeting_header_widget.dart';
import './widgets/pending_assignments_card_widget.dart';
import './widgets/quick_stats_card_widget.dart';
import './widgets/recent_announcements_card_widget.dart';
import './widgets/today_schedule_card_widget.dart';

class StudentDashboard extends ConsumerStatefulWidget {
  final Function(int)? onNavigateToTab;
  
  const StudentDashboard({super.key, this.onNavigateToTab});

  @override
  ConsumerState<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends ConsumerState<StudentDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final String userRole = 'student';

  // Mock student data
  final Map<String, dynamic> studentData = {
    "name": "Arjun Sharma",
    "usn": "1BK21CS045",
    "department": "CSE",
    "section": "A",
    "semester": 5,
    "year": 3,
    "email": "arjun.sharma@bkit.edu.in",
    "phone": "+91 9876543210",
    "address": "123 MG Road, Bangalore, Karnataka 560001",
    "profileImage":
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face",
  };

  // Mock today's schedule data
  final List<Map<String, dynamic>> todaySchedule = [
    {
      "id": 1,
      "subject": "Data Structures and Algorithms",
      "faculty": "Dr. Priya Nair",
      "room": "CS-301",
      "startTime": "2025-07-29T09:00:00.000Z",
      "endTime": "2025-07-29T10:30:00.000Z",
      "type": "Theory",
    },
    {
      "id": 2,
      "subject": "Database Management Systems",
      "faculty": "Prof. Rajesh Kumar",
      "room": "CS-302",
      "startTime": "2025-07-29T11:00:00.000Z",
      "endTime": "2025-07-29T12:30:00.000Z",
      "type": "Theory",
    },
    {
      "id": 3,
      "subject": "Computer Networks Lab",
      "faculty": "Dr. Meera Patel",
      "room": "CS-Lab-1",
      "startTime": "2025-07-29T14:00:00.000Z",
      "endTime": "2025-07-29T17:00:00.000Z",
      "type": "Lab",
    },
  ];

  // Mock announcements data
  final List<Map<String, dynamic>> announcements = [
    {
      "id": 1,
      "title": "Mid-Semester Examination Schedule Released",
      "content":
          "The mid-semester examination schedule for all departments has been released. Please check your respective department notice boards and download the schedule from the student portal.",
      "priority": "important",
      "author": "Academic Office",
      "department": "All",
      "timestamp": "2025-07-29T08:30:00.000Z",
      "isRead": false,
    },
    {
      "id": 2,
      "title": "Library Timing Changes",
      "content":
          "Due to maintenance work, the library will be closed on Saturday, August 2nd. Normal timings will resume from Monday, August 4th.",
      "priority": "normal",
      "author": "Library Department",
      "department": "All",
      "timestamp": "2025-07-29T07:15:00.000Z",
      "isRead": true,
    },
    {
      "id": 3,
      "title": "Urgent: Fee Payment Deadline Extended",
      "content":
          "The fee payment deadline has been extended to August 15th due to technical issues with the payment gateway. Students are advised to complete their payments before the new deadline.",
      "priority": "urgent",
      "author": "Finance Office",
      "department": "All",
      "timestamp": "2025-07-29T06:45:00.000Z",
      "isRead": false,
    },
    {
      "id": 4,
      "title": "CSE Department Workshop on AI/ML",
      "content":
          "A two-day workshop on Artificial Intelligence and Machine Learning will be conducted on August 10-11. Registration is mandatory for all CSE final year students.",
      "priority": "important",
      "author": "Dr. Suresh Babu",
      "department": "CSE",
      "timestamp": "2025-07-28T16:20:00.000Z",
      "isRead": false,
    },
  ];

  // Mock assignments data
  final List<Map<String, dynamic>> assignments = [
    {
      "id": 1,
      "title": "Design and Analysis of Algorithms Assignment",
      "description":
          "Implement and analyze time complexity of sorting algorithms including Quick Sort, Merge Sort, and Heap Sort.",
      "subject": "Data Structures and Algorithms",
      "faculty": "Dr. Priya Nair",
      "dueDate": "2025-08-05T23:59:00.000Z",
      "marks": 25,
      "status": "pending",
      "submissionType": "file",
    },
    {
      "id": 2,
      "title": "Database Design Project",
      "description":
          "Design a complete database schema for a library management system with ER diagrams and normalization.",
      "subject": "Database Management Systems",
      "faculty": "Prof. Rajesh Kumar",
      "dueDate": "2025-08-08T23:59:00.000Z",
      "marks": 30,
      "status": "pending",
      "submissionType": "file",
    },
    {
      "id": 3,
      "title": "Network Protocol Analysis",
      "description":
          "Analyze TCP/IP protocol stack and create a detailed report on packet flow and routing mechanisms.",
      "subject": "Computer Networks",
      "faculty": "Dr. Meera Patel",
      "dueDate": "2025-07-31T23:59:00.000Z",
      "marks": 20,
      "status": "pending",
      "submissionType": "report",
    },
    {
      "id": 4,
      "title": "Software Engineering Case Study",
      "description":
          "Complete case study analysis of a real-world software project using SDLC methodologies.",
      "subject": "Software Engineering",
      "faculty": "Prof. Anita Desai",
      "dueDate": "2025-08-12T23:59:00.000Z",
      "marks": 35,
      "status": "pending",
      "submissionType": "presentation",
    },
    {
      "id": 5,
      "title": "Operating Systems Lab Report",
      "description":
          "Submit lab report covering process scheduling algorithms and memory management techniques.",
      "subject": "Operating Systems",
      "faculty": "Dr. Vikram Singh",
      "dueDate": "2025-08-01T23:59:00.000Z",
      "marks": 15,
      "status": "pending",
      "submissionType": "report",
    },
  ];

  // Mock recent marks data
  final List<Map<String, dynamic>> recentMarks = [
    {
      "id": 1,
      "subject": "Data Structures",
      "examType": "Internal Assessment 1",
      "marks": 85.0,
      "totalMarks": 100.0,
      "date": "2025-07-20T00:00:00.000Z",
    },
    {
      "id": 2,
      "subject": "Database Systems",
      "examType": "Quiz 2",
      "marks": 78.0,
      "totalMarks": 100.0,
      "date": "2025-07-18T00:00:00.000Z",
    },
    {
      "id": 3,
      "subject": "Computer Networks",
      "examType": "Lab Assessment",
      "marks": 92.0,
      "totalMarks": 100.0,
      "date": "2025-07-15T00:00:00.000Z",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshDashboard() async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Trigger haptic feedback
    HapticFeedback.lightImpact();
  }

  void _onAnnouncementTap(Map<String, dynamic> announcement) {
    // Mark announcement as read
    setState(() {
      final index =
          announcements.indexWhere((a) => a['id'] == announcement['id']);
      if (index != -1) {
        announcements[index]['isRead'] = true;
      }
    });

    // Show announcement details
    _showAnnouncementDetails(announcement);
  }

  void _onAnnouncementLongPress(Map<String, dynamic> announcement) {
    HapticFeedback.mediumImpact();
    _showAnnouncementContextMenu(announcement);
  }

  void _showAnnouncementDetails(Map<String, dynamic> announcement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 70.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(top: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(
                                announcement['priority'] as String),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            (announcement['priority'] as String).toUpperCase(),
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: CustomIconWidget(
                            iconName: 'close',
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      announcement['title'] as String,
                      style:
                          AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      announcement['content'] as String,
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'person',
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                          size: 16,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          announcement['author'] as String,
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        ),
                        const Spacer(),
                        Text(
                          _formatTimestamp(DateTime.parse(
                              announcement['timestamp'] as String)),
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAnnouncementContextMenu(Map<String, dynamic> announcement) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(top: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: announcement['isRead'] == true
                    ? 'mark_as_unread'
                    : 'mark_email_read',
                color: AppTheme.lightTheme.primaryColor,
                size: 24,
              ),
              title: Text(
                announcement['isRead'] == true
                    ? 'Mark as Unread'
                    : 'Mark as Read',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              onTap: () {
                setState(() {
                  final index = announcements
                      .indexWhere((a) => a['id'] == announcement['id']);
                  if (index != -1) {
                    announcements[index]['isRead'] =
                        !(announcements[index]['isRead'] as bool? ?? false);
                  }
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'star',
                color: AppTheme.getStatusColor('warning'),
                size: 24,
              ),
              title: Text(
                'Mark as Important',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                // Handle mark as important
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return AppTheme.lightTheme.colorScheme.error;
      case 'important':
        return const Color(0xFFFF9800);
      case 'normal':
      default:
        return AppTheme.lightTheme.primaryColor;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  Future<bool> _showExitConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Exit App',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'Are you sure you want to exit the app?',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Exit'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(top: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                  studentData['profileImage'] as String,
                ),
                child: studentData['profileImage'] == null
                    ? Text((studentData['name'] as String)
                        .substring(0, 1)
                        .toUpperCase())
                    : null,
              ),
              title: Text(
                studentData['name'] as String,
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                studentData['usn'] as String,
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
            ),
            Divider(),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'person',
                color: AppTheme.lightTheme.primaryColor,
                size: 24,
              ),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon('Profile');
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'settings',
                color: AppTheme.lightTheme.primaryColor,
                size: 24,
              ),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon('Settings');
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'logout',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 24,
              ),
              title: Text(
                'Sign Out',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showSignOutConfirmation();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _showSignOutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Sign Out',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Sign out using AuthController
              await ref.read(authControllerProvider.notifier).signOut();
              // Navigate to login screen
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login-screen',
                  (route) => false,
                );
              }
            },
            child: Text(
              'Sign Out',
              style: TextStyle(
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // Handle back button - show exit confirmation
        final shouldExit = await _showExitConfirmation();
        if (shouldExit && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Student Dashboard',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              onPressed: _showProfileMenu,
              icon: CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(
                  studentData['profileImage'] as String,
                ),
                onBackgroundImageError: (exception, stackTrace) {
                  // Fallback to initials
                },
                child: studentData['profileImage'] == null
                    ? Text(
                        (studentData['name'] as String)
                            .substring(0, 1)
                            .toUpperCase(),
                        style:
                            AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : null,
              ),
            ),
            SizedBox(width: 2.w),
          ],
        ),
        body: SafeArea(
          child: _buildDashboardTab(),
        ),
      ),
    );
  }


  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: _refreshDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 2.h),
            // Greeting Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: GreetingHeaderWidget(
                studentName: studentData['name'] as String,
                usn: studentData['usn'] as String,
                department: studentData['department'] as String,
                section: studentData['section'] as String,
              ),
            ),
            SizedBox(height: 2.h),
            // Today's Schedule Card
            TodayScheduleCardWidget(
              todayClasses: todaySchedule,
              onTap: () {
                widget.onNavigateToTab?.call(1); // Navigate to Schedule tab
              },
            ),
            // Recent Announcements Card
            RecentAnnouncementsCardWidget(
              announcements: announcements,
              onAnnouncementTap: _onAnnouncementTap,
              onAnnouncementLongPress: _onAnnouncementLongPress,
            ),
            // Pending Assignments Card
            PendingAssignmentsCardWidget(
              assignments: assignments,
              onViewAll: () {
                widget.onNavigateToTab?.call(3); // Navigate to Assignments tab
              },
            ),
            // Quick Stats Card
            QuickStatsCardWidget(
              attendancePercentage: 87.5,
              recentMarks: recentMarks,
              onAttendanceTap: () {
                widget.onNavigateToTab?.call(2); // Navigate to Attendance tab
              },
              onMarksTap: () {
                // Navigate to marks screen
              },
            ),
            SizedBox(height: 10.h), // Space for FAB
          ],
        ),
      ),
    );
  }
}
