import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/admin_drawer_widget.dart';
import './widgets/admin_header_widget.dart';
import './widgets/quick_management_card.dart';
import './widgets/recent_activity_card.dart';
import './widgets/system_announcements_card.dart';
import './widgets/user_statistics_card.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;

  // Mock admin data
  final Map<String, dynamic> adminData = {
    "id": "ADM001",
    "name": "Dr. Rajesh Kumar",
    "designation": "Principal",
    "employeeId": "EMP2024001",
    "officeNumber": "101",
    "email": "principal@bkit.edu.in",
    "phone": "+91 9876543210",
    "joiningDate": DateTime(2020, 6, 15),
    "profileImage":
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face",
    "unreadNotifications": 5,
    "totalDepartments": 6,
    "activeSessions": 24,
    "todayAttendance": 87,
  };

  // Mock statistics data
  final Map<String, dynamic> statisticsData = {
    "totalStudents": 1247,
    "totalFaculty": 89,
    "activeUsers": 1156,
    "totalDepartments": 6,
    "totalSections": 18,
  };

  // Mock announcements data
  final List<Map<String, dynamic>> announcementsData = [
    {
      "id": "ANN001",
      "title": "Mid-Semester Examination Schedule Released",
      "content":
          "The mid-semester examination schedule for all departments has been published. Students are advised to check their respective department notice boards and download the schedule from the college portal.",
      "priority": "important",
      "author": "Academic Office",
      "timestamp": DateTime.now().subtract(Duration(hours: 2)),
      "departments": ["CSE", "ECE", "EEE", "MECH", "CIVIL", "IT"],
      "readCount": 892,
    },
    {
      "id": "ANN002",
      "title": "Library Maintenance Notice",
      "content":
          "The central library will be closed for maintenance from 25th to 27th July. Students can access digital resources through the online portal during this period.",
      "priority": "normal",
      "author": "Library Department",
      "timestamp": DateTime.now().subtract(Duration(hours: 6)),
      "departments": ["CSE", "ECE", "EEE", "MECH", "CIVIL", "IT"],
      "readCount": 456,
    },
    {
      "id": "ANN003",
      "title": "Emergency: Classes Suspended Due to Weather",
      "content":
          "Due to severe weather conditions, all classes are suspended for today. Students and faculty are advised to stay safe. Online classes will continue as per schedule.",
      "priority": "urgent",
      "author": "Administration",
      "timestamp": DateTime.now().subtract(Duration(minutes: 30)),
      "departments": ["CSE", "ECE", "EEE", "MECH", "CIVIL", "IT"],
      "readCount": 1203,
    },
  ];

  // Mock recent activities data
  final List<Map<String, dynamic>> recentActivitiesData = [
    {
      "id": "ACT001",
      "type": "registration",
      "title": "New Student Registration",
      "description": "25 new students registered for CSE department",
      "timestamp": DateTime.now().subtract(Duration(minutes: 15)),
      "department": "CSE",
    },
    {
      "id": "ACT002",
      "type": "attendance",
      "title": "Attendance Updated",
      "description": "Faculty marked attendance for 3rd year ECE Section A",
      "timestamp": DateTime.now().subtract(Duration(minutes: 45)),
      "department": "ECE",
    },
    {
      "id": "ACT003",
      "type": "assignment",
      "title": "Assignment Submitted",
      "description": "Data Structures assignment submitted by 42 students",
      "timestamp": DateTime.now().subtract(Duration(hours: 1)),
      "department": "CSE",
    },
    {
      "id": "ACT004",
      "type": "announcement",
      "title": "Announcement Posted",
      "description": "Mid-semester exam schedule published",
      "timestamp": DateTime.now().subtract(Duration(hours: 2)),
      "department": "Academic",
    },
    {
      "id": "ACT005",
      "type": "login",
      "title": "Faculty Login",
      "description": "Dr. Priya Sharma logged into the system",
      "timestamp": DateTime.now().subtract(Duration(hours: 3)),
      "department": "EEE",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      drawer: AdminDrawerWidget(
        adminData: adminData,
        onNavigate: _handleNavigation,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppTheme.getRoleColor('admin'),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: AdminHeaderWidget(
                adminData: adminData,
                onProfileTap: () => _handleNavigation('/profile-settings'),
                onNotificationTap: () => _handleNavigation('/notifications'),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(4.w),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  UserStatisticsCard(
                    statistics: statisticsData,
                    onTap: () => _handleNavigation('/user-statistics'),
                  ),
                  SizedBox(height: 2.h),
                  SystemAnnouncementsCard(
                    announcements: announcementsData,
                    onViewAll: () =>
                        _handleNavigation('/announcement-management'),
                  ),
                  SizedBox(height: 2.h),
                  RecentActivityCard(
                    activities: recentActivitiesData,
                    onViewAll: () => _handleNavigation('/activity-logs'),
                  ),
                  SizedBox(height: 2.h),
                  QuickManagementCard(
                    onAddStudent: () => _handleNavigation('/add-student'),
                    onAddFaculty: () => _handleNavigation('/add-faculty'),
                    onCreateAnnouncement: () =>
                        _handleNavigation('/create-announcement'),
                    onViewReports: () => _handleNavigation('/reports'),
                  ),
                  SizedBox(height: 10.h), // Extra space for FAB
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showQuickActions,
        backgroundColor: AppTheme.getRoleColor('admin'),
        foregroundColor: Colors.white,
        icon: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 24,
        ),
        label: Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Quick Actions',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              crossAxisSpacing: 4.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 1,
              children: [
                _buildQuickActionItem('Add Student', 'person_add',
                    AppTheme.getRoleColor('student')),
                _buildQuickActionItem('Add Faculty', 'person_add',
                    AppTheme.getRoleColor('faculty')),
                _buildQuickActionItem(
                    'Announcement', 'campaign', AppTheme.getRoleColor('admin')),
                _buildQuickActionItem('Reports', 'assessment', Colors.purple),
                _buildQuickActionItem('Settings', 'settings', Colors.orange),
                _buildQuickActionItem('Export Data', 'download', Colors.teal),
              ],
            ),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(String title, String iconName, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _handleQuickAction(title);
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: color,
              size: 28,
            ),
            SizedBox(height: 1.h),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dashboard data refreshed successfully'),
        backgroundColor: AppTheme.getStatusColor('success'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleNavigation(String route) {
    // Handle navigation based on route
    switch (route) {
      case "/add-student":
      case '/add-faculty':
        Navigator.pushNamed(context, route);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Feature coming soon: ${route.replaceAll('/', '').replaceAll('-', ' ')}'),
            backgroundColor: AppTheme.getStatusColor('warning'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  void _handleQuickAction(String action) {
    String route = '';
    switch (action) {
      case 'Add Student':
        route = '/add-student';
        break;
      case 'Add Faculty':
        route = '/add-faculty';
        break;
      case 'Announcement':
        route = '/create-announcement';
        break;
      case 'Reports':
        route = '/reports';
        break;
      case 'Settings':
        route = '/system-settings';
        break;
      case 'Export Data':
        route = '/data-export';
        break;
    }

    if (route.isNotEmpty) {
      _handleNavigation(route);
    }
  }
}
