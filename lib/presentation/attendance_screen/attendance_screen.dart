import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../controllers/attendance_controller.dart';
import '../../controllers/auth_controller.dart';
import './widgets/attendance_calendar_widget.dart';
import './widgets/attendance_filter_widget.dart';
import './widgets/attendance_stats_widget.dart';
import './widgets/student_attendance_list_widget.dart';
import './student_attendance_screen.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String? _userRole;
  DateTime selectedMonth = DateTime.now();
  Map<String, dynamic> currentFilters = {
    'subject': 'All Subjects',
    'attendanceThreshold': 0.0,
    'status': 'All',
    'dateRange': null,
  };

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final role = await ref.read(authControllerProvider.notifier).getUserRole();
    if (mounted) {
      setState(() {
        _userRole = role;
        _initializeController();
      });
    }
  }

  void _initializeController() {
    if (_userRole != null && _userRole != 'STUDENT') {
      _tabController = TabController(
        length: 2, // Faculty/Admin only has 2 tabs
        vsync: this,
      );
    }
  }

  @override
  void dispose() {
    if (_userRole != null && _userRole != 'STUDENT') {
      _tabController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_userRole == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // For students, show the dedicated StudentAttendanceScreen
    if (_userRole == 'STUDENT') {
      return StudentAttendanceScreen(
        isEmbedded: true,
        onBackPressed: () => Navigator.pop(context),
      );
    }

    // For faculty and admin, show the original attendance screen
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
      floatingActionButton:
          _userRole == 'FACULTY' ? _buildFloatingActionButton() : null,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Attendance',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          color: AppTheme.getRoleColor(_userRole ?? 'student'),
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
        if (_userRole == 'FACULTY' && ref.watch(attendanceControllerProvider).isMarkingMode)
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
            if (_userRole == 'STUDENT')
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
            if (_userRole == 'FACULTY')
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
    // Only show tab bar for faculty/admin since students use dedicated screen
    List<Tab> tabs = [
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

    return Container(
      color: AppTheme.lightTheme.scaffoldBackgroundColor,
      child: TabBar(
        controller: _tabController,
        tabs: tabs,
        indicatorColor: AppTheme.getRoleColor(_userRole ?? 'faculty'),
        labelColor: AppTheme.getRoleColor(_userRole ?? 'faculty'),
        unselectedLabelColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  List<Widget> _buildTabViews() {
    // Only return faculty/admin tabs since students use dedicated screen
    return [
      _buildStudentListTab(),
      _buildOverviewTab(),
    ];
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          AttendanceStatsWidget(
            attendanceData: _userRole == 'STUDENT'
                ? {"overallPercentage": 87.5, "subjects": []}
                : {"todayClasses": [], "pendingSessions": 0},
            userRole: _userRole ?? 'student',
          ),
          if (_userRole == 'STUDENT') _buildAttendanceTrends(),
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
            calendarData: {"attendanceRecords": []},
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
    final attendanceState = ref.watch(attendanceControllerProvider);
    
    return SingleChildScrollView(
      child: Column(
        children: [
          StudentAttendanceListWidget(
            students: attendanceState.students.map((student) => {
              'id': student.id,
              'name': student.name,
              'usn': student.usn,
              'profileImage': student.profileImage,
              'isPresent': attendanceState.attendance[student.id] ?? true,
            }).toList(),
            onAttendanceToggle: _onAttendanceToggle,
            isMarkingMode: attendanceState.isMarkingMode,
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
    if (_userRole != 'FACULTY') return null;
    
    final attendanceState = ref.watch(attendanceControllerProvider);

    return FloatingActionButton.extended(
      heroTag: "attendance_start_session_fab",
      onPressed: _startAttendanceSession,
      backgroundColor: AppTheme.getRoleColor('faculty'),
      icon: CustomIconWidget(
        iconName: attendanceState.isMarkingMode ? 'save' : 'add',
        color: Colors.white,
        size: 24,
      ),
      label: Text(
        attendanceState.isMarkingMode ? 'Save Attendance' : 'Mark Attendance',
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
            color: AppTheme.getRoleColor(_userRole ?? 'student'),
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
            color: AppTheme.getRoleColor(_userRole ?? 'student'),
            size: 24,
          ),
          label: 'Schedule',
        ),
        NavigationDestination(
          icon: CustomIconWidget(
            iconName: 'how_to_reg',
            color: AppTheme.getRoleColor(_userRole ?? 'student'),
            size: 24,
          ),
          selectedIcon: CustomIconWidget(
            iconName: 'how_to_reg',
            color: AppTheme.getRoleColor(_userRole ?? 'student'),
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
            color: AppTheme.getRoleColor(_userRole ?? 'student'),
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
          _userRole == 'STUDENT'
              ? '/student-dashboard'
              : _userRole == 'FACULTY'
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
        Navigator.pushReplacementNamed(context, '/student-assignments-screen');
        break;
    }
  }

  Future<void> _loadAttendanceData() async {
    // Refresh attendance data from providers
    ref.invalidate(attendanceControllerProvider);
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
    ref.read(attendanceControllerProvider.notifier).toggleAttendance(studentId, isPresent);
  }

  void _onFilterChanged(Map<String, dynamic> filters) {
    setState(() {
      currentFilters = filters;
    });
    // Apply filters to data
  }

  void _startAttendanceSession() {
    final attendanceState = ref.read(attendanceControllerProvider);
    if (attendanceState.isMarkingMode) {
      _saveAttendance();
    } else {
      // TODO: Show session selection dialog
      // ref.read(attendanceControllerProvider.notifier).startMarkingMode('sessionId');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Session selection coming soon')),
      );
    }
  }

  void _saveAttendance() async {
    final success = await ref.read(attendanceControllerProvider.notifier).saveAttendance(
      'facultyId', // TODO: Get from faculty profile
      'subject', // TODO: Get from session
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Attendance saved successfully' : 'Failed to save attendance'),
        backgroundColor: success ? AppTheme.getStatusColor('success') : AppTheme.getStatusColor('error'),
      ),
    );
  }

  void _showFilterOptions() {
    // Show filter bottom sheet for faculty/admin
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
      final oldRole = _userRole;
      _userRole = _userRole == 'STUDENT' ? 'FACULTY' : 'STUDENT';
      
      // Dispose old controller if it exists (for non-student roles)
      if (oldRole != null && oldRole != 'STUDENT') {
        _tabController.dispose();
      }
      
      _initializeController();
    });
    ref.read(attendanceControllerProvider.notifier).exitMarkingMode();
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
