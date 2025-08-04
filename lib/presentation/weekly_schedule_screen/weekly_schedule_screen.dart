import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../controllers/schedule_controller.dart';
import '../../models/class_session_model.dart';
import './widgets/add_class_session_widget.dart';
import './widgets/class_detail_bottom_sheet.dart';
import './widgets/day_column_widget.dart';
import './widgets/filter_bottom_sheet.dart';
import './widgets/quick_actions_bottom_sheet.dart';

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


  @override
  Widget build(BuildContext context) {
    final scheduleState = ref.watch(scheduleControllerProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(scheduleControllerProvider.notifier).loadWeeklySchedule();
        },
        child: Column(
          children: [
            _buildWeekNavigation(),
            Expanded(
              child: scheduleState.isLoading
                  ? _buildLoadingWidget()
                  : scheduleState.error != null
                      ? _buildErrorWidget(scheduleState.error!)
                      : _buildScheduleContent(scheduleState.weeklySchedule),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "weekly_schedule_add_fab",
        onPressed: _showAddClassDialog,
        backgroundColor: AppTheme.getRoleColor('faculty'),
        foregroundColor: Colors.white,
        child: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 24,
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

  Widget _buildScheduleContent(Map<String, List<ClassSession>> schedule) {
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
              classes: classes.map((session) {
                final timeStr = '${session.startTime.hour.toString().padLeft(2, '0')}:${session.startTime.minute.toString().padLeft(2, '0')}';
                print('🕒 Mapping session "${session.subject}" with time: $timeStr (${session.startTime})');
                return {
                  'time': timeStr,
                  'subject': session.subject,
                  'faculty': session.facultyName,
                  'room': session.room,
                  'contact': '', // Faculty's own contact
                  'progress': 0, // Could be derived from attendance/assignments
                  'attendance': 0, // Could be derived from attendance records
                  'totalClasses': 0, // Could be calculated
                  'section': session.section,
                  'semester': session.semester.toString(),
                  'title': session.title,
                  'department': session.department,
                  'type': session.type,
                  'id': session.id,
                };
              }).toList(),
              onClassTap: _showClassDetails,
              onClassLongPress: _showQuickActions,
              onFreePeriodTap: (timeSlot, date) => _showScheduleClassBottomSheet(timeSlot, date, day),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'error',
            size: 64,
            color: AppTheme.getStatusColor('error'),
          ),
          SizedBox(height: 2.h),
          Text(
            'Error Loading Schedule',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.getStatusColor('error'),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            error,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          ElevatedButton(
            onPressed: () => ref.read(scheduleControllerProvider.notifier).loadWeeklySchedule(),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekNavigation() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => ref.read(scheduleControllerProvider.notifier).goToPreviousWeek(),
            icon: CustomIconWidget(
              iconName: 'chevron_left',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  ref.read(scheduleControllerProvider.notifier).weekRangeText,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!ref.read(scheduleControllerProvider.notifier).isCurrentWeek)
                  TextButton(
                    onPressed: () => ref.read(scheduleControllerProvider.notifier).goToCurrentWeek(),
                    child: Text(
                      'Go to Current Week',
                      style: TextStyle(
                        color: AppTheme.getRoleColor('faculty'),
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => ref.read(scheduleControllerProvider.notifier).goToNextWeek(),
            icon: CustomIconWidget(
              iconName: 'chevron_right',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'filter',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'filter_list',
                      color: AppTheme.getRoleColor('faculty'),
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text('Filter'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'copy_previous_week',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'content_copy',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text('Copy Previous Week'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDateForDay(String dayName) {
    final scheduleState = ref.watch(scheduleControllerProvider);
    final currentWeekStart = scheduleState.currentWeek;
    final daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final dayIndex = daysOfWeek.indexOf(dayName);
    
    if (dayIndex == -1) return '';
    
    final targetDate = currentWeekStart.add(Duration(days: dayIndex));
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


  void _showFilterBottomSheet() {
    final scheduleState = ref.read(scheduleControllerProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        selectedDepartment: scheduleState.selectedDepartment,
        selectedSection: scheduleState.selectedSection,
        onApplyFilter: _applyFilter,
      ),
    );
  }

  void _applyFilter(String department, String section) {
    ref.read(scheduleControllerProvider.notifier).updateFilters(
      department: department,
      section: section,
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'filter':
        _showFilterBottomSheet();
        break;
      case 'copy_previous_week':
        _copyPreviousWeek();
        break;
    }
  }

  Future<void> _copyPreviousWeek() async {
    try {
      final scheduleState = ref.read(scheduleControllerProvider);
      await ref.read(scheduleControllerProvider.notifier).copyScheduleFromPreviousWeek(
        scheduleState.currentWeek,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Schedule copied from previous week successfully'),
          backgroundColor: AppTheme.getStatusColor('success'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to copy schedule: $e'),
          backgroundColor: AppTheme.getStatusColor('error'),
        ),
      );
    }
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

  void _showAddClassDialog() {
    final scheduleState = ref.read(scheduleControllerProvider);
    final today = DateTime.now();
    final weekStart = scheduleState.currentWeek;
    
    // Default to today if within current week, otherwise first day of the week
    DateTime selectedDate = today;
    if (today.isBefore(weekStart) || today.isAfter(weekStart.add(Duration(days: 6)))) {
      selectedDate = weekStart;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddClassSessionWidget(
        selectedDate: selectedDate,
        onClose: () => Navigator.pop(context),
        onSave: _addClassSession,
      ),
    );
  }


  Future<void> _addClassSession(ClassSession session) async {
    Navigator.pop(context); // Close the add session sheet
    
    try {
      await ref.read(scheduleControllerProvider.notifier).addClassSession(session);
      
      // Force a manual refresh to ensure UI updates
      await ref.read(scheduleControllerProvider.notifier).loadWeeklySchedule();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Class session "${session.title}" added successfully'),
          backgroundColor: AppTheme.getStatusColor('success'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add class session: $e'),
          backgroundColor: AppTheme.getStatusColor('error'),
        ),
      );
    }
  }

  void _showScheduleClassBottomSheet(String timeSlot, String dayDate, String dayName) {
    final scheduleState = ref.read(scheduleControllerProvider);
    final currentWeek = scheduleState.currentWeek;
    
    // Calculate the actual date for the day
    final daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final dayIndex = daysOfWeek.indexOf(dayName);
    final actualDate = dayIndex != -1 
        ? currentWeek.add(Duration(days: dayIndex))
        : DateTime.now();
    
    // Parse time slot to DateTime
    final timeParts = timeSlot.split(':');
    final hour = int.parse(timeParts[0]);
    final startTime = DateTime(
      actualDate.year,
      actualDate.month,
      actualDate.day,
      hour,
      0,
    );
    final endTime = startTime.add(Duration(hours: 1)); // Default 1 hour duration

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddClassSessionWidget(
        selectedDate: actualDate,
        prefilledStartTime: startTime,
        prefilledEndTime: endTime,
        onClose: () => Navigator.pop(context),
        onSave: _addClassSession,
      ),
    );
  }
}
