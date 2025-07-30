import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      case '/create-announcement':
        _showCreateAnnouncementBottomSheet();
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

  void _showCreateAnnouncementBottomSheet() {
    final _titleController = TextEditingController();
    final _contentController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    
    String _selectedPriority = 'normal';
    List<String> _selectedDepartments = ['All'];
    bool _isLoading = false;

    final List<String> _priorities = ['normal', 'important', 'urgent'];
    final List<String> _departments = ['All', 'CSE', 'ECE', 'EEE', 'MECH', 'CIVIL', 'IT'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: 85.h,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 12.w,
                height: 0.5.h,
                margin: EdgeInsets.only(top: 2.h),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              
              // Header
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Row(
                  children: [
                    Icon(
                      Icons.campaign,
                      color: AppTheme.getRoleColor('admin'),
                      size: 28,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'Create Announcement',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              
              // Form
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title field
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Announcement Title',
                            hintText: 'Enter announcement title',
                            prefixIcon: Icon(Icons.title, color: AppTheme.getRoleColor('admin')),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppTheme.getRoleColor('admin')),
                            ),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Title is required';
                            if (value!.length < 5) return 'Title must be at least 5 characters';
                            return null;
                          },
                          maxLength: 100,
                        ),
                        SizedBox(height: 2.h),
                        
                        // Content field
                        TextFormField(
                          controller: _contentController,
                          decoration: InputDecoration(
                            labelText: 'Announcement Content',
                            hintText: 'Enter detailed announcement content',
                            prefixIcon: Icon(Icons.description, color: AppTheme.getRoleColor('admin')),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppTheme.getRoleColor('admin')),
                            ),
                          ),
                          maxLines: 4,
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Content is required';
                            if (value!.length < 10) return 'Content must be at least 10 characters';
                            return null;
                          },
                          maxLength: 500,
                        ),
                        SizedBox(height: 2.h),
                        
                        // Priority dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedPriority,
                          decoration: InputDecoration(
                            labelText: 'Priority',
                            prefixIcon: Icon(Icons.priority_high, color: AppTheme.getRoleColor('admin')),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppTheme.getRoleColor('admin')),
                            ),
                          ),
                          items: _priorities.map((priority) {
                            return DropdownMenuItem<String>(
                              value: priority,
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _getPriorityColor(priority),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(priority.toUpperCase()),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) => setModalState(() => _selectedPriority = value!),
                        ),
                        SizedBox(height: 2.h),
                        
                        // Department selection
                        Text(
                          'Target Departments',
                          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Wrap(
                            spacing: 2.w,
                            runSpacing: 1.h,
                            children: _departments.map((dept) {
                              final isSelected = _selectedDepartments.contains(dept);
                              return FilterChip(
                                label: Text(dept),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setModalState(() {
                                    if (dept == 'All') {
                                      if (selected) {
                                        _selectedDepartments = ['All'];
                                      } else {
                                        _selectedDepartments.remove('All');
                                      }
                                    } else {
                                      if (selected) {
                                        _selectedDepartments.remove('All');
                                        _selectedDepartments.add(dept);
                                      } else {
                                        _selectedDepartments.remove(dept);
                                        if (_selectedDepartments.isEmpty) {
                                          _selectedDepartments.add('All');
                                        }
                                      }
                                    }
                                  });
                                },
                                selectedColor: AppTheme.getRoleColor('admin').withValues(alpha: 0.2),
                                checkmarkColor: AppTheme.getRoleColor('admin'),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 4.h),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Submit button
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      if (_selectedDepartments.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Please select at least one department'),
                            backgroundColor: AppTheme.getStatusColor('error'),
                          ),
                        );
                        return;
                      }

                      setModalState(() => _isLoading = true);

                      try {
                        // Create announcement document
                        final announcementData = {
                          'title': _titleController.text.trim(),
                          'content': _contentController.text.trim(),
                          'priority': _selectedPriority,
                          'departments': _selectedDepartments,
                          'author': adminData['name'], // Use actual admin name
                          'authorId': 'admin', // TODO: Get current admin user ID
                          'isActive': true,
                          'readBy': <String>[], // Array to track who has read the announcement
                          'createdAt': FieldValue.serverTimestamp(),
                          'updatedAt': FieldValue.serverTimestamp(),
                        };

                        await FirebaseFirestore.instance
                            .collection('announcements')
                            .add(announcementData);

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Announcement "${_titleController.text}" created successfully!'),
                            backgroundColor: AppTheme.getStatusColor('success'),
                          ),
                        );

                        // Close bottom sheet
                        Navigator.pop(context);

                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${e.toString()}'),
                            backgroundColor: AppTheme.getStatusColor('error'),
                          ),
                        );
                      } finally {
                        setModalState(() => _isLoading = false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.getRoleColor('admin'),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Create Announcement',
                            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
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
}
