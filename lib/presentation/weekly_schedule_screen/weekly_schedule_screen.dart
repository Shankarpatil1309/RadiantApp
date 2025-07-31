import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../controllers/faculty_dashboard_controller.dart';
import './widgets/class_detail_bottom_sheet.dart';
import './widgets/day_column_widget.dart';
import './widgets/filter_bottom_sheet.dart';
import './widgets/quick_actions_bottom_sheet.dart';
import './widgets/week_navigation_widget.dart';

class WeeklyScheduleScreen extends ConsumerStatefulWidget {
  final bool isEmbedded;
  final VoidCallback? onBackPressed;
  
  const WeeklyScheduleScreen({
    Key? key,
    this.isEmbedded = false,
    this.onBackPressed,
  }) : super(key: key);

  @override
  ConsumerState<WeeklyScheduleScreen> createState() => _WeeklyScheduleScreenState();
}

class _WeeklyScheduleScreenState extends ConsumerState<WeeklyScheduleScreen> {
  DateTime _currentWeek = DateTime.now();
  String _selectedDepartment = 'CSE';
  String _selectedSection = 'A';
  bool _isLoading = false;


  @override
  Widget build(BuildContext context) {
    final weeklySchedule = ref.watch(facultyWeeklyScheduleProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(facultyWeeklyScheduleProvider);
        },
        child: Column(
          children: [
            WeekNavigationWidget(
              currentWeek: _currentWeek,
              onPreviousWeek: _goToPreviousWeek,
              onNextWeek: _goToNextWeek,
              onFilterTap: _showFilterBottomSheet,
            ),
            Expanded(
              child: weeklySchedule.when(
                data: (schedule) => _buildScheduleContent(schedule),
                loading: () => _buildLoadingWidget(),
                error: (error, stack) => _buildErrorWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
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
      title: Text(
        'Weekly Schedule',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _showSearchDialog,
          icon: CustomIconWidget(
            iconName: 'search',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        IconButton(
          onPressed: _exportToCalendar,
          icon: CustomIconWidget(
            iconName: 'calendar_today',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          SizedBox(height: 2.h),
          Text(
            'Loading schedule...',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleContent(Map<String, List<Map<String, dynamic>>> schedule) {
    final daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    
    return Container(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: daysOfWeek.map((day) {
            final isToday = _isToday(day);
            final classes = schedule[day] ?? [];
            final dayDate = _getDateForDay(day);
            
            return DayColumnWidget(
              dayName: day,
              dayDate: dayDate,
              isToday: isToday,
              classes: classes.map((classData) => {
                'time': classData['time'],
                'subject': classData['subject'],
                'faculty': 'You', // Faculty viewing their own schedule
                'room': classData['room'],
                'contact': '', // Faculty's own contact
                'progress': 0, // Could be derived from attendance/assignments
                'attendance': 0, // Could be derived from attendance records
                'totalClasses': 0, // Could be calculated
                'section': classData['section'],
                'semester': classData['semester'],
              }).toList(),
              onClassTap: _showClassDetails,
              onClassLongPress: _showQuickActions,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text('Error loading schedule'),
          TextButton(
            onPressed: () => ref.refresh(facultyWeeklyScheduleProvider),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _getDateForDay(String dayName) {
    final now = DateTime.now();
    final today = now.weekday;
    final daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final targetDay = daysOfWeek.indexOf(dayName) + 1;
    
    final difference = targetDay - today;
    final targetDate = now.add(Duration(days: difference));
    
    return targetDate.day.toString().padLeft(2, '0');
  }

  bool _isToday(String dayName) {
    final today = DateTime.now();
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final todayIndex = today.weekday - 1;
    return weekdays[todayIndex] == dayName;
  }

  void _goToPreviousWeek() {
    setState(() {
      _currentWeek = _currentWeek.subtract(Duration(days: 7));
    });
    ref.refresh(facultyWeeklyScheduleProvider);
  }

  void _goToNextWeek() {
    setState(() {
      _currentWeek = _currentWeek.add(Duration(days: 7));
    });
    ref.refresh(facultyWeeklyScheduleProvider);
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        selectedDepartment: _selectedDepartment,
        selectedSection: _selectedSection,
        onApplyFilter: _applyFilter,
      ),
    );
  }

  void _applyFilter(String department, String section) {
    setState(() {
      _selectedDepartment = department;
      _selectedSection = section;
    });
    ref.refresh(facultyWeeklyScheduleProvider);
  }

  void _showClassDetails(Map<String, dynamic> classData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClassDetailBottomSheet(
        classData: classData,
        onSetReminder: () => _setReminder(classData),
        onViewFacultyProfile: () => _viewFacultyProfile(classData),
        onCheckAttendance: () => _checkAttendance(classData),
      ),
    );
  }

  void _showQuickActions(Map<String, dynamic> classData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickActionsBottomSheet(
        classData: classData,
        onSetReminder: () => _setReminder(classData),
        onViewFacultyProfile: () => _viewFacultyProfile(classData),
        onCheckAttendance: () => _checkAttendance(classData),
      ),
    );
  }

  void _setReminder(Map<String, dynamic> classData) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reminder set for ${classData['subject']}'),
        backgroundColor: AppTheme.getStatusColor('success'),
      ),
    );
  }

  void _viewFacultyProfile(Map<String, dynamic> classData) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${classData['faculty']} profile'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _checkAttendance(Map<String, dynamic> classData) {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/attendance-screen');
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Search Schedule'),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Search subject or faculty...',
            prefixIcon: CustomIconWidget(
              iconName: 'search',
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
              size: 20,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Search functionality coming soon')),
              );
            },
            child: Text('Search'),
          ),
        ],
      ),
    );
  }

  void _exportToCalendar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Schedule exported to device calendar'),
        backgroundColor: AppTheme.getStatusColor('success'),
      ),
    );
  }
}
