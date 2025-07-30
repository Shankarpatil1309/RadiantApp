import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/attendance_calendar_widget.dart';
import './widgets/attendance_filter_widget.dart';
import './widgets/attendance_stats_widget.dart';
import './widgets/student_attendance_list_widget.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String userRole =
      'student'; // Mock user role - can be 'student', 'faculty', or 'admin'
  DateTime selectedMonth = DateTime.now();
  bool isMarkingMode = false;
  bool isLoading = false;
  Map<String, dynamic> currentFilters = {
    'subject': 'All Subjects',
    'attendanceThreshold': 0.0,
    'status': 'All',
    'dateRange': null,
  };

  // Mock data for student attendance
  final Map<String, dynamic> mockStudentAttendanceData = {
    "overallPercentage": 87.5,
    "subjects": [
      {
        "name": "Mathematics",
        "percentage": 92.0,
        "present": 23,
        "total": 25,
      },
      {
        "name": "Physics",
        "percentage": 85.0,
        "present": 17,
        "total": 20,
      },
      {
        "name": "Computer Science",
        "percentage": 90.0,
        "present": 18,
        "total": 20,
      },
      {
        "name": "Chemistry",
        "percentage": 82.0,
        "present": 14,
        "total": 17,
      },
      {
        "name": "English",
        "percentage": 88.0,
        "present": 22,
        "total": 25,
      },
    ],
  };

  // Mock data for faculty attendance
  final Map<String, dynamic> mockFacultyAttendanceData = {
    "todayClasses": [
      {
        "className": "CSE-A Mathematics",
        "time": "09:00 AM - 10:00 AM",
        "isCompleted": true,
        "studentsPresent": 45,
        "totalStudents": 50,
      },
      {
        "className": "CSE-B Physics",
        "time": "11:00 AM - 12:00 PM",
        "isCompleted": false,
        "studentsPresent": 0,
        "totalStudents": 48,
      },
      {
        "className": "CSE-C Chemistry",
        "time": "02:00 PM - 03:00 PM",
        "isCompleted": false,
        "studentsPresent": 0,
        "totalStudents": 52,
      },
    ],
    "pendingSessions": 2,
  };

  // Mock calendar data
  final Map<String, dynamic> mockCalendarData = {
    "attendanceRecords": [
      {
        "date": "2025-01-25",
        "status": "present",
        "subjects": ["Mathematics", "Physics"],
      },
      {
        "date": "2025-01-24",
        "status": "present",
        "subjects": ["Computer Science", "English"],
      },
      {
        "date": "2025-01-23",
        "status": "absent",
        "subjects": ["Chemistry"],
      },
      {
        "date": "2025-01-22",
        "status": "present",
        "subjects": ["Mathematics", "Physics", "Chemistry"],
      },
      {
        "date": "2025-01-21",
        "status": "holiday",
        "subjects": [],
      },
      {
        "date": "2025-01-20",
        "status": "present",
        "subjects": ["Computer Science", "English"],
      },
    ],
  };

  // Mock student list for faculty
  final List<Map<String, dynamic>> mockStudentList = [
    {
      "id": "1",
      "name": "Aarav Sharma",
      "usn": "1BK21CS001",
      "profileImage":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "isPresent": true,
    },
    {
      "id": "2",
      "name": "Priya Patel",
      "usn": "1BK21CS002",
      "profileImage":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "isPresent": false,
    },
    {
      "id": "3",
      "name": "Rohit Kumar",
      "usn": "1BK21CS003",
      "profileImage":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "isPresent": true,
    },
    {
      "id": "4",
      "name": "Sneha Reddy",
      "usn": "1BK21CS004",
      "profileImage":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "isPresent": true,
    },
    {
      "id": "5",
      "name": "Arjun Singh",
      "usn": "1BK21CS005",
      "profileImage":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "isPresent": false,
    },
    {
      "id": "6",
      "name": "Kavya Nair",
      "usn": "1BK21CS006",
      "profileImage":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "isPresent": true,
    },
    {
      "id": "7",
      "name": "Vikram Joshi",
      "usn": "1BK21CS007",
      "profileImage":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "isPresent": false,
    },
    {
      "id": "8",
      "name": "Ananya Gupta",
      "usn": "1BK21CS008",
      "profileImage":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "isPresent": true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: userRole == 'student' ? 3 : 2,
      vsync: this,
    );
    _loadAttendanceData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            if (userRole == 'student') _buildMonthSelector(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _buildTabViews(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          userRole == 'faculty' ? _buildFloatingActionButton() : null,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Attendance',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          color: AppTheme.getRoleColor(userRole),
        ),
      ),
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: AppTheme.lightTheme.colorScheme.onSurface,
          size: 24,
        ),
      ),
      actions: [
        if (userRole == 'faculty' && isMarkingMode)
          TextButton(
            onPressed: _saveAttendance,
            child: Text(
              'Save',
              style: TextStyle(
                color: AppTheme.getRoleColor('faculty'),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        IconButton(
          onPressed: _showFilterOptions,
          icon: CustomIconWidget(
            iconName: 'filter_list',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuSelection,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'download',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  const Text('Export Report'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'analytics',
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'analytics',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  const Text('View Analytics'),
                ],
              ),
            ),
            if (userRole == 'student')
              PopupMenuItem(
                value: 'switch_role',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'swap_horiz',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    const Text('Switch to Faculty'),
                  ],
                ),
              ),
            if (userRole == 'faculty')
              PopupMenuItem(
                value: 'switch_role',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'swap_horiz',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    const Text('Switch to Student'),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Academic Year 2024-25',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'calendar_month',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  _getMonthYearString(selectedMonth),
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    List<Tab> tabs = [];

    if (userRole == 'student') {
      tabs = [
        Tab(
          icon: CustomIconWidget(
            iconName: 'analytics',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 20,
          ),
          text: 'Overview',
        ),
        Tab(
          icon: CustomIconWidget(
            iconName: 'calendar_today',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 20,
          ),
          text: 'Calendar',
        ),
        Tab(
          icon: CustomIconWidget(
            iconName: 'filter_list',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 20,
          ),
          text: 'Filter',
        ),
      ];
    } else {
      tabs = [
        Tab(
          icon: CustomIconWidget(
            iconName: 'people',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 20,
          ),
          text: 'Students',
        ),
        Tab(
          icon: CustomIconWidget(
            iconName: 'analytics',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 20,
          ),
          text: 'Overview',
        ),
      ];
    }

    return Container(
      color: AppTheme.lightTheme.scaffoldBackgroundColor,
      child: TabBar(
        controller: _tabController,
        tabs: tabs,
        indicatorColor: AppTheme.getRoleColor(userRole),
        labelColor: AppTheme.getRoleColor(userRole),
        unselectedLabelColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  List<Widget> _buildTabViews() {
    if (userRole == 'student') {
      return [
        _buildOverviewTab(),
        _buildCalendarTab(),
        _buildFilterTab(),
      ];
    } else {
      return [
        _buildStudentListTab(),
        _buildOverviewTab(),
      ];
    }
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          AttendanceStatsWidget(
            attendanceData: userRole == 'student'
                ? mockStudentAttendanceData
                : mockFacultyAttendanceData,
            userRole: userRole,
          ),
          if (userRole == 'student') _buildAttendanceTrends(),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildCalendarTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          AttendanceCalendarWidget(
            calendarData: mockCalendarData,
            onDateTap: _onDateTap,
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildFilterTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          AttendanceFilterWidget(
            onFilterChanged: _onFilterChanged,
            currentFilters: currentFilters,
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildStudentListTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          StudentAttendanceListWidget(
            students: mockStudentList,
            onAttendanceToggle: _onAttendanceToggle,
            isMarkingMode: isMarkingMode,
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildAttendanceTrends() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'trending_up',
                color: AppTheme.lightTheme.primaryColor,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'Attendance Trends',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Container(
            height: 20.h,
            child: Center(
              child: Text(
                'Attendance trend chart will be displayed here',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (userRole != 'faculty') return null;

    return FloatingActionButton.extended(
      onPressed: _startAttendanceSession,
      backgroundColor: AppTheme.getRoleColor('faculty'),
      icon: CustomIconWidget(
        iconName: isMarkingMode ? 'save' : 'add',
        color: Colors.white,
        size: 24,
      ),
      label: Text(
        isMarkingMode ? 'Save Attendance' : 'Mark Attendance',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return NavigationBar(
      selectedIndex: 2, // Attendance screen index
      onDestinationSelected: _onBottomNavTap,
      destinations: [
        NavigationDestination(
          icon: CustomIconWidget(
            iconName: 'dashboard',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          selectedIcon: CustomIconWidget(
            iconName: 'dashboard',
            color: AppTheme.getRoleColor(userRole),
            size: 24,
          ),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: CustomIconWidget(
            iconName: 'schedule',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          selectedIcon: CustomIconWidget(
            iconName: 'schedule',
            color: AppTheme.getRoleColor(userRole),
            size: 24,
          ),
          label: 'Schedule',
        ),
        NavigationDestination(
          icon: CustomIconWidget(
            iconName: 'how_to_reg',
            color: AppTheme.getRoleColor(userRole),
            size: 24,
          ),
          selectedIcon: CustomIconWidget(
            iconName: 'how_to_reg',
            color: AppTheme.getRoleColor(userRole),
            size: 24,
          ),
          label: 'Attendance',
        ),
        NavigationDestination(
          icon: CustomIconWidget(
            iconName: 'assignment',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          selectedIcon: CustomIconWidget(
            iconName: 'assignment',
            color: AppTheme.getRoleColor(userRole),
            size: 24,
          ),
          label: 'Assignments',
        ),
      ],
    );
  }

  void _onBottomNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(
          context,
          userRole == 'student'
              ? '/student-dashboard'
              : userRole == 'faculty'
                  ? '/faculty-dashboard'
                  : '/admin-dashboard',
        );
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/weekly-schedule-screen');
        break;
      case 2:
        // Current screen
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/assignments-screen');
        break;
    }
  }

  Future<void> _loadAttendanceData() async {
    setState(() {
      isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    await _loadAttendanceData();
  }

  void _onDateTap(DateTime date) {
    // Handle date tap - show attendance details for that date
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Attendance Details'),
        content: Text('Details for ${_formatDate(date)} will be shown here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _onAttendanceToggle(String studentId, bool isPresent) {
    // Handle attendance toggle for faculty
    print('Student $studentId marked as ${isPresent ? 'present' : 'absent'}');
  }

  void _onFilterChanged(Map<String, dynamic> filters) {
    setState(() {
      currentFilters = filters;
    });
    // Apply filters to data
  }

  void _startAttendanceSession() {
    if (isMarkingMode) {
      _saveAttendance();
    } else {
      setState(() {
        isMarkingMode = true;
      });
    }
  }

  void _saveAttendance() {
    setState(() {
      isMarkingMode = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Attendance saved successfully'),
        backgroundColor: AppTheme.getStatusColor('success'),
      ),
    );
  }

  void _showFilterOptions() {
    if (userRole == 'student') {
      _tabController.animateTo(2); // Switch to filter tab
    } else {
      // Show filter bottom sheet for faculty
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => Container(
          height: 70.h,
          child: AttendanceFilterWidget(
            onFilterChanged: _onFilterChanged,
            currentFilters: currentFilters,
          ),
        ),
      );
    }
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'export':
        _exportReport();
        break;
      case 'analytics':
        _showAnalytics();
        break;
      case 'switch_role':
        _switchRole();
        break;
    }
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Attendance report exported successfully'),
      ),
    );
  }

  void _showAnalytics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Attendance Analytics'),
        content: SizedBox(
          width: double.maxFinite,
          height: 40.h,
          child: const Center(
            child: Text('Detailed analytics will be displayed here'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _switchRole() {
    setState(() {
      userRole = userRole == 'student' ? 'faculty' : 'student';
      _tabController.dispose();
      _tabController = TabController(
        length: userRole == 'student' ? 3 : 2,
        vsync: this,
      );
      isMarkingMode = false;
    });
  }

  String _getMonthYearString(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
