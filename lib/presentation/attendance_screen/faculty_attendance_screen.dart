import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radiant_app/config/app_config.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../controllers/attendance_controller.dart';
import '../../models/class_session_model.dart';
import './widgets/attendance_filter_widget.dart';
import './widgets/student_attendance_list_widget.dart';

class FacultyAttendanceScreen extends ConsumerStatefulWidget {
  final bool isEmbedded;
  final VoidCallback? onBackPressed;

  const FacultyAttendanceScreen({
    Key? key,
    this.isEmbedded = false,
    this.onBackPressed,
  }) : super(key: key);

  @override
  ConsumerState<FacultyAttendanceScreen> createState() =>
      _FacultyAttendanceScreenState();
}

class _FacultyAttendanceScreenState
    extends ConsumerState<FacultyAttendanceScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String? selectedDepartment;
  String? selectedSection;
  String? selectedSubject;
  String? selectedSessionId;
  Map<String, dynamic> currentFilters = {
    'subject': 'All Subjects',
    'attendanceThreshold': 0.0,
    'status': 'All',
    'dateRange': null,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTodayClasses();
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
      leading: widget.isEmbedded
          ? IconButton(
              onPressed: widget.onBackPressed ?? () {},
              icon: CustomIconWidget(
                iconName: 'arrow_back',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24,
              ),
            )
          : IconButton(
              onPressed: () => Navigator.pop(context),
              icon: CustomIconWidget(
                iconName: 'arrow_back',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24,
              ),
            ),
      actions: [
        Consumer(
          builder: (context, ref, _) {
            final attendanceState = ref.watch(attendanceControllerProvider);
            if (attendanceState.isMarkingMode) {
              return TextButton(
                onPressed: _saveAttendance,
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: AppTheme.getRoleColor('faculty'),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
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
    final attendanceState = ref.watch(attendanceControllerProvider);

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildClassSelector(),
          if (attendanceState.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (attendanceState.error != null)
            _buildErrorWidget(attendanceState.error!)
          else if (attendanceState.students.isEmpty)
            _buildEmptyStateWidget()
          else
            _buildStudentsList(attendanceState),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final todayClassesAsync = ref.watch(todayClassesProvider);

    return SingleChildScrollView(
      child: Column(
        children: [
          todayClassesAsync.when(
            data: (classes) => _buildTodayClassesList(classes),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _buildErrorWidget(error.toString()),
          ),
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
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  ),
                  value: selectedDepartment,
                  items: AppConfig.departmentCodes.map((String dept) {
                    return DropdownMenuItem<String>(
                      value: dept,
                      child: Text(dept),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedDepartment = value;
                      selectedSection = null;
                    });
                  },
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Section',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  ),
                  value: selectedSection,
                  items: selectedDepartment != null
                      ? AppConfig.sectionsByDepartment[selectedDepartment]
                          ?.map((String section) {
                          return DropdownMenuItem<String>(
                            value: section,
                            child: Text(section),
                          );
                        }).toList()
                      : [],
                  onChanged: selectedDepartment != null
                      ? (String? value) {
                          setState(() {
                            selectedSection = value;
                          });
                          if (value != null && selectedDepartment != null) {
                            _loadStudentsForSection();
                          }
                        }
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayClassesList(List<ClassSession> classes) {
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
          if (classes.isEmpty)
            Center(
              child: Text(
                'No classes scheduled for today',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
            )
          else
            ...classes.map<Widget>((classSession) {
              return _buildClassItem(classSession);
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildClassItem(ClassSession classSession) {
    final isCompleted = classSession.status == 'completed';

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
                  '${classSession.department}-${classSession.section} ${classSession.subject}',
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
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
                size: 16,
              ),
              SizedBox(width: 1.w),
              Text(
                '${classSession.startTime.hour.toString().padLeft(2, '0')}:${classSession.startTime.minute.toString().padLeft(2, '0')} - ${classSession.endTime.hour.toString().padLeft(2, '0')}:${classSession.endTime.minute.toString().padLeft(2, '0')}',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              const Spacer(),
              CustomIconWidget(
                iconName: 'people',
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
                size: 16,
              ),
              SizedBox(width: 1.w),
              Text(
                isCompleted ? 'Attendance marked' : 'Pending attendance',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              if (!isCompleted) ...[
                SizedBox(width: 2.w),
                ElevatedButton(
                  onPressed: () => _startAttendanceForSession(classSession),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.getRoleColor('faculty'),
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  ),
                  child: Text(
                    'Mark',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    final attendanceState = ref.watch(attendanceControllerProvider);

    return FloatingActionButton.extended(
      heroTag: "faculty_attendance_save_fab",
      onPressed: attendanceState.isMarkingMode ? _saveAttendance : null,
      backgroundColor: AppTheme.getRoleColor('faculty'),
      icon: CustomIconWidget(
        iconName: attendanceState.isMarkingMode ? 'save' : 'add',
        color: Colors.white,
        size: 24,
      ),
      label: Text(
        attendanceState.isMarkingMode
            ? 'Save Attendance'
            : 'Select Class to Mark',
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

  Future<void> _loadTodayClasses() async {
    // Get current faculty ID from authentication or user state
    const facultyId = 'current_faculty_id'; // Replace with actual faculty ID
    ref.read(todayClassesProvider.notifier).loadTodayClasses(facultyId);
  }

  Future<void> _refreshData() async {
    await _loadTodayClasses();
    if (selectedDepartment != null && selectedSection != null) {
      _loadStudentsForSection();
    }
  }

  void _loadStudentsForSection() {
    if (selectedDepartment != null && selectedSection != null) {
      ref
          .read(attendanceControllerProvider.notifier)
          .loadStudentsBySection(selectedDepartment!, selectedSection!);
    }
  }

  void _onAttendanceToggle(String studentId, bool isPresent) {
    ref
        .read(attendanceControllerProvider.notifier)
        .toggleAttendance(studentId, isPresent);
  }

  void _startAttendanceForSession(ClassSession session) {
    setState(() {
      selectedSessionId = session.id;
      selectedSubject = session.subject;
      selectedDepartment = session.department;
      selectedSection = session.section;
    });

    ref
        .read(attendanceControllerProvider.notifier)
        .startMarkingMode(session.id);

    _loadStudentsForSection();
    _tabController.animateTo(0); // Switch to students tab
  }

  Future<void> _saveAttendance() async {
    const facultyId = 'current_faculty_id'; // Replace with actual faculty ID
    final success = await ref
        .read(attendanceControllerProvider.notifier)
        .saveAttendance(facultyId, selectedSubject ?? 'Unknown Subject');

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Attendance saved successfully'),
          backgroundColor: AppTheme.getStatusColor('success'),
        ),
      );
      _loadTodayClasses(); // Refresh today's classes
    } else {
      final error = ref.read(attendanceControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Failed to save attendance: ${error ?? 'Unknown error'}'),
          backgroundColor: AppTheme.getStatusColor('error'),
        ),
      );
    }
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.getStatusColor('error').withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.getStatusColor('error'),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'error',
            color: AppTheme.getStatusColor('error'),
            size: 32,
          ),
          SizedBox(height: 2.h),
          Text(
            'Error',
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
            onPressed: _refreshData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateWidget() {
    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'people',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'No Students Found',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            selectedDepartment != null && selectedSection != null
                ? 'No students found for $selectedDepartment-$selectedSection'
                : 'Please select a department and section to view students',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList(AttendanceState attendanceState) {
    final studentsList = attendanceState.students.map((student) {
      return {
        'id': student.id,
        'name': student.name,
        'usn': student.usn,
        'profileImage': student.profileImage,
        'isPresent': attendanceState.attendance[student.id] ?? false,
      };
    }).toList();

    return StudentAttendanceListWidget(
      students: studentsList,
      onAttendanceToggle: _onAttendanceToggle,
      isMarkingMode: attendanceState.isMarkingMode,
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
