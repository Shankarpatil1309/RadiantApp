import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/attendance_calendar_widget.dart';
import './widgets/attendance_filter_widget.dart';
import './widgets/attendance_stats_widget.dart';

class StudentAttendanceScreen extends ConsumerStatefulWidget {
  const StudentAttendanceScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StudentAttendanceScreen> createState() => _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends ConsumerState<StudentAttendanceScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime selectedMonth = DateTime.now();
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
            _buildMonthSelector(),
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
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'My Attendance',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          color: AppTheme.getRoleColor('student'),
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
    return Container(
      color: AppTheme.lightTheme.scaffoldBackgroundColor,
      child: TabBar(
        controller: _tabController,
        tabs: [
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
        ],
        indicatorColor: AppTheme.getRoleColor('student'),
        labelColor: AppTheme.getRoleColor('student'),
        unselectedLabelColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  List<Widget> _buildTabViews() {
    return [
      _buildOverviewTab(),
      _buildCalendarTab(),
      _buildFilterTab(),
    ];
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          AttendanceStatsWidget(
            attendanceData: mockStudentAttendanceData,
            userRole: 'student',
          ),
          _buildAttendanceTrends(),
          _buildAttendanceInsights(),
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

  Widget _buildAttendanceInsights() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
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
                iconName: 'lightbulb',
                color: AppTheme.getStatusColor('warning'),
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'Attendance Insights',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildInsightItem(
            'Your attendance in Chemistry is below 85%',
            'Consider attending next few classes to improve',
            Icons.warning_amber_rounded,
            AppTheme.getStatusColor('warning'),
          ),
          SizedBox(height: 1.h),
          _buildInsightItem(
            'Great job maintaining 90%+ in Computer Science!',
            'Keep up the excellent attendance record',
            Icons.celebration,
            AppTheme.getStatusColor('success'),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
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
            color: AppTheme.getRoleColor('student'),
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
            color: AppTheme.getRoleColor('student'),
            size: 24,
          ),
          label: 'Schedule',
        ),
        NavigationDestination(
          icon: CustomIconWidget(
            iconName: 'how_to_reg',
            color: AppTheme.getRoleColor('student'),
            size: 24,
          ),
          selectedIcon: CustomIconWidget(
            iconName: 'how_to_reg',
            color: AppTheme.getRoleColor('student'),
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
            color: AppTheme.getRoleColor('student'),
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
        Navigator.pushNamed(context, '/student-dashboard');
        break;
      case 1:
        Navigator.pushNamed(context, '/weekly-schedule-screen');
        break;
      case 2:
        // Current screen
        break;
      case 3:
        Navigator.pushNamed(context, '/student-assignments-screen');
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

  void _onFilterChanged(Map<String, dynamic> filters) {
    setState(() {
      currentFilters = filters;
    });
    // Apply filters to data
  }

  void _showFilterOptions() {
    _tabController.animateTo(2); // Switch to filter tab
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

  String _getMonthYearString(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}