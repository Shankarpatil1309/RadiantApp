import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/attendance_filter_widget.dart';
import './widgets/attendance_stats_widget.dart';
import './widgets/student_attendance_list_widget.dart';

class FacultyAttendanceScreen extends ConsumerStatefulWidget {
  const FacultyAttendanceScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FacultyAttendanceScreen> createState() => _FacultyAttendanceScreenState();
}

class _FacultyAttendanceScreenState extends ConsumerState<FacultyAttendanceScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool isMarkingMode = false;
  bool isLoading = false;
  Map<String, dynamic> currentFilters = {
    'subject': 'All Subjects',
    'attendanceThreshold': 0.0,
    'status': 'All',
    'dateRange': null,
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
    _tabController = TabController(length: 2, vsync: this);
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
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Faculty Attendance',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          color: AppTheme.getRoleColor('faculty'),
          fontWeight: FontWeight.w600,
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
        if (isMarkingMode)
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
          ],
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.lightTheme.scaffoldBackgroundColor,
      child: TabBar(
        controller: _tabController,
        tabs: [
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
        ],
        indicatorColor: AppTheme.getRoleColor('faculty'),
        labelColor: AppTheme.getRoleColor('faculty'),
        unselectedLabelColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  List<Widget> _buildTabViews() {
    return [
      _buildStudentListTab(),
      _buildOverviewTab(),
    ];
  }

  Widget _buildStudentListTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildClassSelector(),
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

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          AttendanceStatsWidget(
            attendanceData: mockFacultyAttendanceData,
            userRole: 'faculty',
          ),
          _buildTodayClassesList(),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildClassSelector() {
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
                iconName: 'school',
                color: AppTheme.getRoleColor('faculty'),
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'Select Class',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            ),
            value: 'CSE-A Mathematics',
            items: [
              'CSE-A Mathematics',
              'CSE-B Physics',
              'CSE-C Chemistry',
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? value) {
              // Handle class selection
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTodayClassesList() {
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
                iconName: 'today',
                color: AppTheme.getRoleColor('faculty'),
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'Today\'s Classes',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ...mockFacultyAttendanceData['todayClasses'].map<Widget>((classItem) {
            return _buildClassItem(classItem);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildClassItem(Map<String, dynamic> classItem) {
    final isCompleted = classItem['isCompleted'] as bool;
    final studentsPresent = classItem['studentsPresent'] as int;
    final totalStudents = classItem['totalStudents'] as int;
    
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isCompleted 
            ? AppTheme.getStatusColor('success').withValues(alpha: 0.1)
            : AppTheme.getStatusColor('warning').withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompleted 
              ? AppTheme.getStatusColor('success')
              : AppTheme.getStatusColor('warning'),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  classItem['className'] as String,
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? AppTheme.getStatusColor('success')
                      : AppTheme.getStatusColor('warning'),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isCompleted ? 'COMPLETED' : 'PENDING',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'schedule',
                color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6),
                size: 16,
              ),
              SizedBox(width: 1.w),
              Text(
                classItem['time'] as String,
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              const Spacer(),
              CustomIconWidget(
                iconName: 'people',
                color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6),
                size: 16,
              ),
              SizedBox(width: 1.w),
              Text(
                '$studentsPresent/$totalStudents',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
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
            color: AppTheme.getRoleColor('faculty'),
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
            color: AppTheme.getRoleColor('faculty'),
            size: 24,
          ),
          label: 'Schedule',
        ),
        NavigationDestination(
          icon: CustomIconWidget(
            iconName: 'how_to_reg',
            color: AppTheme.getRoleColor('faculty'),
            size: 24,
          ),
          selectedIcon: CustomIconWidget(
            iconName: 'how_to_reg',
            color: AppTheme.getRoleColor('faculty'),
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
            color: AppTheme.getRoleColor('faculty'),
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
        Navigator.pushNamed(context, '/faculty-dashboard');
        break;
      case 1:
        Navigator.pushNamed(context, '/weekly-schedule-screen');
        break;
      case 2:
        // Current screen
        break;
      case 3:
        Navigator.pushNamed(context, '/faculty-assignments-screen');
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

  void _onAttendanceToggle(String studentId, bool isPresent) {
    // Handle attendance toggle for faculty
    print('Student $studentId marked as ${isPresent ? 'present' : 'absent'}');
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

  void _onFilterChanged(Map<String, dynamic> filters) {
    setState(() {
      currentFilters = filters;
    });
    // Apply filters to data
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'export':
        _exportReport();
        break;
      case 'analytics':
        _showAnalytics();
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
            child: Text('Faculty attendance analytics will be displayed here'),
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
}