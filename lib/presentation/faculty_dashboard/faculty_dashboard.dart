import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/assignment_status_card.dart';
import './widgets/faculty_bottom_sheet.dart';
import './widgets/faculty_header_widget.dart';
import './widgets/quick_actions_card.dart';
import './widgets/recent_announcements_card.dart';
import './widgets/today_classes_card.dart';

class FacultyDashboard extends StatefulWidget {
  const FacultyDashboard({Key? key}) : super(key: key);

  @override
  State<FacultyDashboard> createState() => _FacultyDashboardState();
}

class _FacultyDashboardState extends State<FacultyDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // Mock faculty data
  final Map<String, dynamic> facultyData = {
    "name": "Dr. Sarah Johnson",
    "employeeId": "FAC001",
    "department": "Computer Science",
    "profileImage":
        "https://images.unsplash.com/photo-1494790108755-2616b612b786?fm=jpg&q=60&w=400&ixlib=rb-4.0.3",
    "unreadNotifications": 3,
    "todaySchedule": [
      {
        "subject": "Data Structures",
        "time": "10:00 AM",
        "room": "CS-101",
        "studentCount": 45,
        "duration": "1hr 30min"
      },
      {
        "subject": "Algorithms",
        "time": "2:00 PM",
        "room": "CS-102",
        "studentCount": 38,
        "duration": "1hr 30min"
      }
    ]
  };

  final List<Map<String, dynamic>> todayClasses = [
    {
      "id": 1,
      "subject": "Data Structures",
      "time": "10:00 AM",
      "duration": "1hr 30min",
      "room": "CS-101",
      "studentCount": 45,
      "section": "A",
      "semester": "3rd",
      "attendanceMarked": false
    },
    {
      "id": 2,
      "subject": "Algorithms",
      "time": "2:00 PM",
      "duration": "1hr 30min",
      "room": "CS-102",
      "studentCount": 38,
      "section": "B",
      "semester": "5th",
      "attendanceMarked": true
    },
    {
      "id": 3,
      "subject": "Database Management",
      "time": "4:00 PM",
      "duration": "1hr 30min",
      "room": "CS-103",
      "studentCount": 42,
      "section": "A",
      "semester": "4th",
      "attendanceMarked": false
    }
  ];

  final List<Map<String, dynamic>> recentAnnouncements = [
    {
      "id": 1,
      "title": "Mid-term Examination Schedule Released",
      "content":
          "The mid-term examination schedule for all subjects has been released. Please check your respective class schedules and prepare accordingly.",
      "priority": "important",
      "timeAgo": "2 hours ago",
      "views": 156,
      "likes": 23,
      "author": "Dr. Sarah Johnson"
    },
    {
      "id": 2,
      "title": "Assignment Submission Deadline Extended",
      "content":
          "Due to technical issues with the submission portal, the deadline for Data Structures assignment has been extended to next Friday.",
      "priority": "urgent",
      "timeAgo": "5 hours ago",
      "views": 89,
      "likes": 45,
      "author": "Dr. Sarah Johnson"
    },
    {
      "id": 3,
      "title": "Guest Lecture on Machine Learning",
      "content":
          "We are pleased to announce a guest lecture on 'Introduction to Machine Learning' by industry expert Mr. John Smith next week.",
      "priority": "normal",
      "timeAgo": "1 day ago",
      "views": 234,
      "likes": 67,
      "author": "Dr. Sarah Johnson"
    }
  ];

  final Map<String, dynamic> assignmentStats = {
    "total": 12,
    "pendingReview": 8,
    "submissions": 156,
    "overdue": 3,
    "reviewed": 4
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.index = 0; // Dashboard tab active
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => FacultyBottomSheet(onMarkAttendance: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/attendance-screen');
            }, onUploadAssignment: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/assignments-screen');
            }, onPostAnnouncement: () {
              Navigator.pop(context);
              _showAnnouncementDialog();
            }));
  }

  void _showAnnouncementDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: Text("Post Announcement",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getRoleColor('faculty'))),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                      decoration: const InputDecoration(
                          labelText: "Title",
                          hintText: "Enter announcement title")),
                  SizedBox(height: 2.h),
                  TextField(
                      maxLines: 3,
                      decoration: const InputDecoration(
                          labelText: "Content",
                          hintText: "Enter announcement content")),
                ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel")),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Announcement posted successfully!")));
                      },
                      child: const Text("Post")),
                ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
          FacultyHeaderWidget(
              facultyData: facultyData,
              onProfileTap: () => _tabController.animateTo(4),
              onNotificationTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Opening notifications...")));
              }),
          Expanded(
              child: TabBarView(controller: _tabController, children: [
            _buildDashboardTab(),
            _buildClassesTab(),
            _buildAssignmentsTab(),
            _buildAttendanceTab(),
            _buildProfileTab(),
          ])),
        ]),
        bottomNavigationBar: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                      color:
                          Theme.of(context).shadowColor.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2)),
                ]),
            child: TabBar(
                controller: _tabController,
                labelColor: AppTheme.getRoleColor('faculty'),
                unselectedLabelColor: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
                indicatorColor: AppTheme.getRoleColor('faculty'),
                tabs: [
                  Tab(
                      icon: CustomIconWidget(
                          iconName: 'dashboard',
                          color: _tabController.index == 0
                              ? AppTheme.getRoleColor('faculty')
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                          size: 24),
                      text: "Dashboard"),
                  Tab(
                      icon: CustomIconWidget(
                          iconName: 'school',
                          color: _tabController.index == 1
                              ? AppTheme.getRoleColor('faculty')
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                          size: 24),
                      text: "Classes"),
                  Tab(
                      icon: CustomIconWidget(
                          iconName: 'assignment',
                          color: _tabController.index == 2
                              ? AppTheme.getRoleColor('faculty')
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                          size: 24),
                      text: "Assignments"),
                  Tab(
                      icon: CustomIconWidget(
                          iconName: 'how_to_reg',
                          color: _tabController.index == 3
                              ? AppTheme.getRoleColor('faculty')
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                          size: 24),
                      text: "Attendance"),
                  Tab(
                      icon: CustomIconWidget(
                          iconName: 'person',
                          color: _tabController.index == 4
                              ? AppTheme.getRoleColor('faculty')
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                          size: 24),
                      text: "Profile"),
                ])),
        floatingActionButton: _tabController.index == 0
            ? FloatingActionButton(
                onPressed: _showBottomSheet,
                backgroundColor: AppTheme.getRoleColor('faculty'),
                child: CustomIconWidget(
                    iconName: 'add', color: Colors.white, size: 24))
            : null);
  }

  Widget _buildDashboardTab() {
    return RefreshIndicator(
        onRefresh: _refreshData,
        color: AppTheme.getRoleColor('faculty'),
        child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(children: [
              SizedBox(height: 1.h),
              TodayClassesCard(
                  todayClasses: todayClasses,
                  onClassTap: (classData) {
                    Navigator.pushNamed(context, '/weekly-schedule-screen');
                  },
                  onMarkAttendance: (classData) {
                    Navigator.pushNamed(context, '/faculty-attendance-screen');
                  }),
              RecentAnnouncementsCard(
                  announcements: recentAnnouncements,
                  onAnnouncementTap: (announcement) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Opening: ${announcement["title"]}")));
                  },
                  onAnnouncementLongPress: (announcement) {
                    _showAnnouncementOptions(announcement);
                  }),
              AssignmentStatusCard(
                  assignmentStats: assignmentStats,
                  onViewAssignments: () {
                    Navigator.pushNamed(context, '/faculty-assignments-screen');
                  }),
              QuickActionsCard(
                  onMarkAttendance: () {
                    Navigator.pushNamed(context, '/faculty-attendance-screen');
                  },
                  onPostAnnouncement: _showAnnouncementDialog,
                  onViewSchedule: () {
                    Navigator.pushNamed(context, '/weekly-schedule-screen');
                  },
                  onManageAssignments: () {
                    Navigator.pushNamed(context, '/faculty-assignments-screen');
                  }),
              SizedBox(height: 10.h),
            ])));
  }

  Widget _buildClassesTab() {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      CustomIconWidget(
          iconName: 'school',
          color: AppTheme.getRoleColor('faculty'),
          size: 64),
      SizedBox(height: 2.h),
      Text("Classes",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.getRoleColor('faculty'),
              fontWeight: FontWeight.w600)),
      SizedBox(height: 1.h),
      Text("Manage your class schedules and sessions",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6)),
          textAlign: TextAlign.center),
    ]));
  }

  Widget _buildAssignmentsTab() {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      CustomIconWidget(
          iconName: 'assignment',
          color: AppTheme.getRoleColor('faculty'),
          size: 64),
      SizedBox(height: 2.h),
      Text("Assignments",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.getRoleColor('faculty'),
              fontWeight: FontWeight.w600)),
      SizedBox(height: 1.h),
      Text("Create and manage student assignments",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6)),
          textAlign: TextAlign.center),
    ]));
  }

  Widget _buildAttendanceTab() {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      CustomIconWidget(
          iconName: 'how_to_reg',
          color: AppTheme.getRoleColor('faculty'),
          size: 64),
      SizedBox(height: 2.h),
      Text("Attendance",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.getRoleColor('faculty'),
              fontWeight: FontWeight.w600)),
      SizedBox(height: 1.h),
      Text("Mark and track student attendance",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6)),
          textAlign: TextAlign.center),
    ]));
  }

  Widget _buildProfileTab() {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      CustomIconWidget(
          iconName: 'person',
          color: AppTheme.getRoleColor('faculty'),
          size: 64),
      SizedBox(height: 2.h),
      Text("Profile",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.getRoleColor('faculty'),
              fontWeight: FontWeight.w600)),
      SizedBox(height: 1.h),
      Text("Manage your faculty profile and settings",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6)),
          textAlign: TextAlign.center),
    ]));
  }

  void _showAnnouncementOptions(Map<String, dynamic> announcement) {
    showModalBottomSheet(
        context: context,
        builder: (context) => Container(
            padding: EdgeInsets.all(4.w),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ListTile(
                  leading: CustomIconWidget(
                      iconName: 'edit',
                      color: AppTheme.getRoleColor('faculty'),
                      size: 24),
                  title: const Text("Edit Announcement"),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Edit functionality coming soon!")));
                  }),
              ListTile(
                  leading: CustomIconWidget(
                      iconName: 'delete',
                      color: AppTheme.getStatusColor('error'),
                      size: 24),
                  title: const Text("Delete Announcement"),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(announcement);
                  }),
            ])));
  }

  void _showDeleteConfirmation(Map<String, dynamic> announcement) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text("Delete Announcement"),
                content: Text(
                    "Are you sure you want to delete '${announcement["title"]}'?"),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel")),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Announcement deleted successfully!")));
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.getStatusColor('error')),
                      child: const Text("Delete")),
                ]));
  }
}
