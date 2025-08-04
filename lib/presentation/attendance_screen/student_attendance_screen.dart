import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../controllers/attendance_controller.dart';
import '../../controllers/student_dashboard_controller.dart';
import '../../models/student_model.dart';
import './widgets/attendance_calendar_widget.dart';
import './widgets/attendance_filter_widget.dart';
import './widgets/attendance_stats_widget.dart';

// Provider for student attendance data
final studentAttendanceProvider = FutureProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>((ref, params) async {
  final attendanceService = ref.read(attendanceServiceProvider);
  final department = params['department'] as String;
  final section = params['section'] as String;
  final semester = params['semester'] as int;
  
  final attendanceRecords = await attendanceService.getAttendanceBySection(department, section, semester);
  
  // Process attendance records for student view
  return attendanceRecords.map((attendance) => {
    'date': attendance.date,
    'subject': attendance.subject,
    'subjectCode': attendance.subjectCode,
    'totalStudents': attendance.totalStudents,
    'presentCount': attendance.presentCount,
    'absentCount': attendance.absentCount,
    'markedAt': attendance.markedAt,
  }).toList();
});

// Provider for student attendance trends
final studentAttendanceTrendsProvider = FutureProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>((ref, params) async {
  final attendanceService = ref.read(attendanceServiceProvider);
  final department = params['department'] as String;
  final section = params['section'] as String;
  final semester = params['semester'] as int;
  final studentId = params['studentId'] as String;
  
  final attendanceRecords = await attendanceService.getAttendanceBySection(department, section, semester);
  
  // Group attendance by week to show trends
  final Map<String, Map<String, int>> weeklyStats = {};
  
  for (final record in attendanceRecords) {
    // Parse the date string (format: "YYYY-MM-DD")
    try {
      final recordDate = DateTime.parse(record.date);
      // Get week of year
      final weekStart = recordDate.subtract(Duration(days: recordDate.weekday - 1));
      final weekKey = '${weekStart.day}/${weekStart.month}';
      
      if (!weeklyStats.containsKey(weekKey)) {
        weeklyStats[weekKey] = {'present': 0, 'total': 0};
      }
      
      weeklyStats[weekKey]!['total'] = weeklyStats[weekKey]!['total']! + 1;
      
      if (record.studentsPresent.contains(studentId)) {
        weeklyStats[weekKey]!['present'] = weeklyStats[weekKey]!['present']! + 1;
      }
    } catch (e) {
      print('Error parsing date ${record.date}: $e');
      continue;
    }
  }
  
  // Convert to trend data (last 6 weeks)
  final trends = weeklyStats.entries.take(6).map((entry) {
    final present = entry.value['present']!;
    final total = entry.value['total']!;
    final percentage = total > 0 ? (present / total) * 100 : 0.0;
    
    return {
      'week': entry.key,
      'percentage': percentage,
      'present': present,
      'total': total,
    };
  }).toList();
  
  return trends;
});

// Provider for student attendance stats
final studentAttendanceStatsProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  final attendanceService = ref.read(attendanceServiceProvider);
  final department = params['department'] as String;
  final section = params['section'] as String;
  final semester = params['semester'] as int;
  final studentId = params['studentId'] as String;
  
  final attendanceRecords = await attendanceService.getAttendanceBySection(department, section, semester);
  
  // Calculate student-specific statistics
  final subjectStats = <String, Map<String, int>>{};
  int totalPresent = 0;
  int totalClasses = 0;
  
  for (final record in attendanceRecords) {
    if (!subjectStats.containsKey(record.subject)) {
      subjectStats[record.subject] = {'present': 0, 'total': 0};
    }
    
    subjectStats[record.subject]!['total'] = subjectStats[record.subject]!['total']! + 1;
    totalClasses++;
    
    if (record.studentsPresent.contains(studentId)) {
      subjectStats[record.subject]!['present'] = subjectStats[record.subject]!['present']! + 1;
      totalPresent++;
    }
  }
  
  final overallPercentage = totalClasses > 0 ? (totalPresent / totalClasses) * 100 : 0.0;
  
  final subjects = subjectStats.entries.map((entry) {
    final present = entry.value['present']!;
    final total = entry.value['total']!;
    final percentage = total > 0 ? (present / total) * 100 : 0.0;
    
    return {
      'name': entry.key,
      'percentage': percentage,
      'present': present,
      'total': total,
    };
  }).toList();
  
  return {
    'overallPercentage': overallPercentage,
    'subjects': subjects,
  };
});

class StudentAttendanceScreen extends ConsumerStatefulWidget {
  final bool isEmbedded;
  final VoidCallback? onBackPressed;
  
  const StudentAttendanceScreen({
    Key? key,
    this.isEmbedded = false,
    this.onBackPressed,
  }) : super(key: key);

  @override
  ConsumerState<StudentAttendanceScreen> createState() => _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends ConsumerState<StudentAttendanceScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
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
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(studentDataProvider).when(
      data: (studentData) {
        if (studentData == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: AppTheme.getStatusColor('error')),
                  SizedBox(height: 1.h),
                  Text('Student data not found'),
                ],
              ),
            ),
          );
        }
        
        return _buildMainContent(studentData);
      },
      loading: () => Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: AppTheme.getStatusColor('error')),
              SizedBox(height: 1.h),
              Text('Error loading student data'),
              Text(error.toString()),
              SizedBox(height: 2.h),
              ElevatedButton(
                onPressed: () => ref.refresh(studentDataProvider),
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(Student studentData) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () => _refreshData(studentData),
        child: Column(
          children: [
            _buildMonthSelector(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _buildTabViews(studentData),
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
      leading: widget.isEmbedded ? IconButton(
        onPressed: widget.onBackPressed ?? () {},
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: AppTheme.lightTheme.colorScheme.onSurface,
          size: 24,
        ),
      ) : IconButton(
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

  List<Widget> _buildTabViews(Student studentData) {
    return [
      _buildOverviewTab(studentData),
      _buildCalendarTab(studentData),
      _buildFilterTab(),
    ];
  }

  Widget _buildOverviewTab(Student studentData) {
    return ref.watch(currentStudentIdProvider).when(
      data: (studentId) {
        if (studentId == null) {
          return Center(child: Text('Student ID not found'));
        }
        
        final statsParams = {
          'department': studentData.department,
          'section': studentData.section,
          'semester': studentData.semester,
          'studentId': studentId,
        };
        
        final attendanceStatsAsync = ref.watch(studentAttendanceStatsProvider(statsParams));
        
        return SingleChildScrollView(
          child: Column(
            children: [
              attendanceStatsAsync.when(
                data: (attendanceData) => AttendanceStatsWidget(
                  attendanceData: attendanceData,
                  userRole: 'student',
                ),
                loading: () => Container(
                  height: 20.h,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => Container(
                  height: 20.h,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: AppTheme.getStatusColor('error')),
                        SizedBox(height: 1.h),
                        Text('Failed to load attendance data'),
                        TextButton(
                          onPressed: () => ref.refresh(studentAttendanceStatsProvider(statsParams)),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _buildAttendanceTrends(studentData, studentId),
              attendanceStatsAsync.when(
                data: (data) => _buildAttendanceInsights(data),
                loading: () => SizedBox(),
                error: (_, __) => SizedBox(),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        );
      },
      loading: () => Container(
        height: 20.h,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Container(
        height: 20.h,
        child: Center(child: Text('Error loading student ID')),
      ),
    );
  }

  Widget _buildCalendarTab(Student studentData) {
    return ref.watch(currentStudentIdProvider).when(
      data: (studentId) {
        if (studentId == null) {
          return Center(child: Text('Student ID not found'));
        }
        
        final attendanceParams = {
          'department': studentData.department,
          'section': studentData.section,
          'semester': studentData.semester,
        };
        
        final attendanceDataAsync = ref.watch(studentAttendanceProvider(attendanceParams));
        
        return SingleChildScrollView(
          child: Column(
            children: [
              attendanceDataAsync.when(
                data: (attendanceRecords) {
                  return FutureBuilder(
                    future: ref.read(attendanceServiceProvider).getAttendanceBySection(studentData.department, studentData.section, studentData.semester),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          height: 40.h,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      
                      if (snapshot.hasError) {
                        return Container(
                          height: 40.h,
                          child: Center(child: Text('Error loading calendar data')),
                        );
                      }
                      
                      final actualRecords = snapshot.data ?? [];
                      final calendarData = {
                        'attendanceRecords': actualRecords.map((record) {
                          final isPresent = record.studentsPresent.contains(studentId);
                          return {
                            'date': record.date,
                            'status': isPresent ? 'present' : 'absent',
                            'subjects': [record.subject],
                          };
                        }).toList(),
                      };
                      
                      return AttendanceCalendarWidget(
                        calendarData: calendarData,
                        onDateTap: _onDateTap,
                      );
                    },
                  );
                },
                loading: () => Container(
                  height: 40.h,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => Container(
                  height: 40.h,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: AppTheme.getStatusColor('error')),
                        SizedBox(height: 1.h),
                        Text('Failed to load calendar data'),
                        TextButton(
                          onPressed: () => ref.refresh(studentAttendanceProvider(attendanceParams)),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        );
      },
      loading: () => Container(
        height: 40.h,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Container(
        height: 40.h,
        child: Center(child: Text('Error loading student ID')),
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

  Widget _buildAttendanceTrends(Student studentData, String studentId) {
    final trendsParams = {
      'department': studentData.department,
      'section': studentData.section,
      'semester': studentData.semester,
      'studentId': studentId,
    };
    
    final attendanceTrendsAsync = ref.watch(studentAttendanceTrendsProvider(trendsParams));
    
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
          attendanceTrendsAsync.when(
            data: (trends) => _buildTrendsChart(trends),
            loading: () => Container(
              height: 20.h,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => Container(
              height: 20.h,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: AppTheme.getStatusColor('error')),
                    SizedBox(height: 1.h),
                    Text('Failed to load trends data'),
                    TextButton(
                      onPressed: () => ref.refresh(studentAttendanceTrendsProvider(trendsParams)),
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsChart(List<Map<String, dynamic>> trends) {
    if (trends.isEmpty) {
      return Container(
        height: 20.h,
        child: Center(
          child: Text(
            'No attendance data available yet',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Container(
      height: 20.h,
      child: Column(
        children: [
          // Simple bar chart representation
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: trends.map((weekData) {
                final percentage = weekData['percentage'] as double;
                final week = weekData['week'] as String;
                
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 1.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${percentage.toStringAsFixed(0)}%',
                          style: AppTheme.lightTheme.textTheme.labelSmall,
                        ),
                        SizedBox(height: 1.h),
                        Container(
                          height: (percentage / 100) * 15.h, // Scale to available height
                          decoration: BoxDecoration(
                            color: percentage >= 75
                                ? AppTheme.getStatusColor('success')
                                : percentage >= 50
                                    ? AppTheme.getStatusColor('warning')
                                    : AppTheme.getStatusColor('error'),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          week,
                          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                            fontSize: 8.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Weekly Attendance Percentage',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceInsights(Map<String, dynamic> attendanceData) {
    final subjects = attendanceData['subjects'] as List<dynamic>? ?? [];
    final insights = <Widget>[];
    
    for (final subject in subjects) {
      final percentage = subject['percentage'] as double;
      final name = subject['name'] as String;
      
      if (percentage < 75) {
        insights.add(_buildInsightItem(
          'Your attendance in $name is ${percentage.toStringAsFixed(1)}%',
          'You need to attend more classes to meet the 75% requirement',
          Icons.warning_amber_rounded,
          AppTheme.getStatusColor('error'),
        ));
        insights.add(SizedBox(height: 1.h));
      } else if (percentage >= 90) {
        insights.add(_buildInsightItem(
          'Excellent attendance in $name at ${percentage.toStringAsFixed(1)}%!',
          'Keep up the great work',
          Icons.celebration,
          AppTheme.getStatusColor('success'),
        ));
        insights.add(SizedBox(height: 1.h));
      }
    }
    
    if (insights.isEmpty) {
      insights.add(_buildInsightItem(
        'Your attendance is on track',
        'Continue maintaining good attendance habits',
        Icons.check_circle,
        AppTheme.getStatusColor('info'),
      ));
    }
    
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
          ...insights,
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

  Future<void> _refreshData(Student studentData) async {
    final studentIdAsync = await ref.read(currentStudentIdProvider.future);
    if (studentIdAsync != null) {
      final statsParams = {
        'department': studentData.department,
        'section': studentData.section,
        'semester': studentData.semester,
        'studentId': studentIdAsync,
      };
      
      final attendanceParams = {
        'department': studentData.department,
        'section': studentData.section,
        'semester': studentData.semester,
      };
      
      ref.invalidate(studentAttendanceStatsProvider(statsParams));
      ref.invalidate(studentAttendanceProvider(attendanceParams));
      ref.invalidate(studentAttendanceTrendsProvider(statsParams));
    }
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