import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radiant_app/models/announcement_model.dart';
import 'package:radiant_app/models/assignment_model.dart';
import 'package:radiant_app/models/class_session_model.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/student_dashboard_controller.dart';
import '../../models/student_model.dart';
import '../../services/file_download_service.dart';
import './widgets/greeting_header_widget.dart';
import './widgets/pending_assignments_card_widget.dart';
import './widgets/quick_stats_card_widget.dart';
import './widgets/recent_announcements_card_widget.dart';
import './widgets/today_schedule_card_widget.dart';
import '../assignments_screen/widgets/assignment_detail_widget.dart';
import '../common/widgets/announcement_detail_bottom_sheet.dart';

class StudentDashboard extends ConsumerStatefulWidget {
  final Function(int)? onNavigateToTab;

  const StudentDashboard({super.key, this.onNavigateToTab});

  @override
  ConsumerState<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends ConsumerState<StudentDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final String userRole = 'student';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshDashboard() async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Trigger haptic feedback
    HapticFeedback.lightImpact();
  }

  void _onAnnouncementTap(Map<String, dynamic> announcement) {
    // TODO: Implement mark as read functionality with Firebase
    // Show announcement details
    _showAnnouncementDetails(announcement);
  }

  void _onAnnouncementLongPress(Map<String, dynamic> announcement) {
    HapticFeedback.mediumImpact();
    _showAnnouncementContextMenu(announcement);
  }

  void _showAnnouncementDetails(Map<String, dynamic> announcement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AnnouncementDetailBottomSheet(
        announcement: announcement,
        showActions: false,
      ),
    );
  }

  void _showAnnouncementContextMenu(Map<String, dynamic> announcement) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(top: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: announcement['isRead'] == true
                    ? 'mark_as_unread'
                    : 'mark_email_read',
                color: AppTheme.lightTheme.primaryColor,
                size: 24,
              ),
              title: Text(
                announcement['isRead'] == true
                    ? 'Mark as Unread'
                    : 'Mark as Read',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              onTap: () {
                // TODO: Implement mark as read/unread functionality with Firebase
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'star',
                color: AppTheme.getStatusColor('warning'),
                size: 24,
              ),
              title: Text(
                'Mark as Important',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                // Handle mark as important
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Exit App',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'Are you sure you want to exit the app?',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Exit'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showProfileMenu() {
    final studentDataAsync = ref.read(studentDataProvider);

    studentDataAsync.when(
      data: (data) {
        if (data != null) {
          _showProfileMenuBottomSheet(data);
        } else {
          _showComingSoon('Profile data not available');
        }
      },
      loading: () => _showComingSoon('Loading profile data'),
      error: (error, stack) => _showComingSoon('Error loading profile data'),
    );
  }

  void _showProfileMenuBottomSheet(Student studentData) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(top: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: studentData.profileImage != null
                    ? NetworkImage(studentData.profileImage!)
                    : null,
                onBackgroundImageError: studentData.profileImage != null
                    ? (exception, stackTrace) {
                        // Fallback to initials
                      }
                    : null,
                child: studentData.profileImage == null
                    ? Text(studentData.name.substring(0, 1).toUpperCase())
                    : null,
              ),
              title: Text(
                studentData.name,
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                studentData.usn,
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
            ),
            Divider(),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'person',
                color: AppTheme.lightTheme.primaryColor,
                size: 24,
              ),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon('Profile');
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'settings',
                color: AppTheme.lightTheme.primaryColor,
                size: 24,
              ),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon('Settings');
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'logout',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 24,
              ),
              title: Text(
                'Sign Out',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showSignOutConfirmation();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _showSignOutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Sign Out',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Sign out using AuthController
              await ref.read(authControllerProvider.notifier).signOut();
              // Navigate to login screen
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login-screen',
                  (route) => false,
                );
              }
            },
            child: Text(
              'Sign Out',
              style: TextStyle(
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  void _showAssignmentDetail(Assignment assignment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AssignmentDetailWidget(
        assignment: assignment,
        onDownloadAttachment: () => _downloadAttachment(assignment),
        onSubmit: () => _submitAssignment(assignment),
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _downloadAttachment(Assignment assignment) async {
    print('🔄 Download requested for assignment: ${assignment.title}');
    print('🔄 Has file: ${assignment.hasFile}');
    print('🔄 File URL: ${assignment.fileUrl}');
    print('🔄 File name: ${assignment.fileName}');

    if (!assignment.hasFile || assignment.fileUrl?.isEmpty == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No attachment available for ${assignment.title}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      // Show loading snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                    'Downloading ${assignment.fileName.isNotEmpty ? assignment.fileName : 'assignment file'}...'),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(minutes: 2), // Long duration for download
        ),
      );

      final downloadService = FileDownloadService();
      final fileName = assignment.fileName.isNotEmpty
          ? assignment.fileName
          : '${assignment.title}_assignment.${assignment.fileExtension.isNotEmpty ? assignment.fileExtension : 'pdf'}';

      await downloadService.downloadAssignmentAttachment(
        url: assignment.fileUrl!,
        fileName: fileName,
        assignmentTitle: assignment.title,
        onProgress: (progress) {
          // Optional: Update progress in UI if needed
        },
      );

      // Remove loading snackbar and show success
      ScaffoldMessenger.of(context).removeCurrentSnackBar();

      final locationName = await FileDownloadService.getStorageLocationName();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.download_done, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Download completed'),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                'Saved to: $locationName',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      // Remove loading snackbar and show error
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download attachment: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _submitAssignment(Assignment assignment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening submission interface for ${assignment.title}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentData = ref.watch(studentDataProvider);
    final todayClasses = ref.watch(studentTodayClassesProvider);
    final announcements = ref.watch(studentAnnouncementsProvider);
    final assignments = ref.watch(studentAssignmentsProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // Handle back button - show exit confirmation
        final shouldExit = await _showExitConfirmation();
        if (shouldExit && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Student Dashboard',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            studentData.when(
              data: (data) => IconButton(
                onPressed: _showProfileMenu,
                icon: CircleAvatar(
                  radius: 16,
                  backgroundImage: data?.profileImage != null
                      ? NetworkImage(data!.profileImage!)
                      : null,
                  onBackgroundImageError: data?.profileImage != null
                      ? (exception, stackTrace) {
                          // Fallback to initials
                        }
                      : null,
                  child: data?.profileImage == null
                      ? Text(
                          data?.name.substring(0, 1).toUpperCase() ?? 'S',
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                ),
              ),
              loading: () => CircularProgressIndicator(),
              error: (_, __) => Icon(Icons.person),
            ),
            SizedBox(width: 2.w),
          ],
        ),
        body: SafeArea(
          child: studentData.when(
            data: (data) {
              if (data == null) {
                // This should rarely happen now due to login validation
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _signOutAndRedirectToLogin(
                      'Student data not available. Please contact administrator.');
                });
                return const Center(child: CircularProgressIndicator());
              }
              return _buildDashboardTab(
                  data, todayClasses, announcements, assignments);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) {
              // This should rarely happen now due to login validation
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final message = error is StudentValidationException
                    ? error.message
                    : 'Unable to access student dashboard. Please contact administrator.';
                _signOutAndRedirectToLogin(message);
              });
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardTab(
    Student studentData,
    AsyncValue<List<ClassSession>> todayClassesAsync,
    AsyncValue<List<Announcement>> announcementsAsync,
    AsyncValue<List<Assignment>> assignmentsAsync,
  ) {
    final attendancePercentage = ref.watch(studentAttendancePercentageProvider);
    final recentMarks = ref.watch(studentRecentMarksProvider);
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(studentDataProvider);
        ref.invalidate(studentTodayClassesProvider);
        ref.invalidate(studentAnnouncementsProvider);
        ref.invalidate(studentAssignmentsProvider);
        ref.invalidate(studentAttendancePercentageProvider);
        ref.invalidate(studentRecentMarksProvider);
        await _refreshDashboard();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 2.h),
            // Greeting Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: GreetingHeaderWidget(
                studentName: studentData.name,
                usn: studentData.usn,
                department: studentData.department,
                section: studentData.section,
              ),
            ),
            SizedBox(height: 2.h),
            // Today's Schedule Card
            todayClassesAsync.when(
              data: (todayClasses) => TodayScheduleCardWidget(
                todayClasses: todayClasses
                    .map((session) => {
                          'id': session.id,
                          'subject': session.subject,
                          'faculty': session.facultyName,
                          'room': session.room,
                          'startTime': session.startTime.toIso8601String(),
                          'endTime': session.endTime.toIso8601String(),
                          'type': session.type,
                        })
                    .toList(),
                onTap: () {
                  widget.onNavigateToTab?.call(1); // Navigate to Schedule tab
                },
              ),
              loading: () => _buildLoadingCard('Loading today\'s classes...'),
              error: (error, stack) => _buildErrorCard('Error loading classes'),
            ),
            // Recent Announcements Card
            announcementsAsync.when(
              data: (announcements) => RecentAnnouncementsCardWidget(
                announcements: announcements
                    .map((ann) => {
                          'id': ann.id,
                          'title': ann.title,
                          'content': ann.message,
                          'priority': ann.priority,
                          'timestamp': ann.createdAt.toIso8601String(),
                          'author': ann.createdBy,
                          'department': ann.departments.join(', '),
                          'isRead': false, // TODO: Implement read tracking
                        })
                    .toList(),
                onAnnouncementTap: _onAnnouncementTap,
                onAnnouncementLongPress: _onAnnouncementLongPress,
              ),
              loading: () => _buildLoadingCard('Loading announcements...'),
              error: (error, stack) =>
                  _buildErrorCard('Error loading announcements'),
            ),
            // Pending Assignments Card
            assignmentsAsync.when(
              data: (assignments) => PendingAssignmentsCardWidget(
                assignments: assignments
                    .map((assignment) => {
                          'id': assignment.id,
                          'title': assignment.title,
                          'description': assignment.description,
                          'subject': assignment.subject,
                          'faculty': assignment.facultyName,
                          'dueDate': assignment.dueDate.toIso8601String(),
                          'marks': assignment.maxMarks,
                          'status': 'pending',
                          'submissionType': assignment.type,
                        })
                    .toList(),
                onViewAll: () {
                  widget.onNavigateToTab
                      ?.call(3); // Navigate to Assignments tab
                },
                onAssignmentTap: (assignmentMap) {
                  final assignment = assignments
                      .firstWhere((a) => a.id == assignmentMap['id']);
                  _showAssignmentDetail(assignment);
                },
              ),
              loading: () => _buildLoadingCard('Loading assignments...'),
              error: (error, stack) =>
                  _buildErrorCard('Error loading assignments'),
            ),
            // Quick Stats Card
            attendancePercentage.when(
              data: (attendanceData) => recentMarks.when(
                data: (marksData) => QuickStatsCardWidget(
                  attendancePercentage: attendanceData,
                  recentMarks: marksData,
                  onAttendanceTap: () {
                    widget.onNavigateToTab?.call(2); // Navigate to Attendance tab
                  },
                  onMarksTap: () {
                    // Navigate to marks screen
                  },
                ),
                loading: () => QuickStatsCardWidget(
                  attendancePercentage: attendanceData,
                  recentMarks: const [],
                  onAttendanceTap: () {
                    widget.onNavigateToTab?.call(2);
                  },
                  onMarksTap: () {},
                ),
                error: (error, stack) => QuickStatsCardWidget(
                  attendancePercentage: attendanceData,
                  recentMarks: const [],
                  onAttendanceTap: () {
                    widget.onNavigateToTab?.call(2);
                  },
                  onMarksTap: () {},
                ),
              ),
              loading: () => recentMarks.when(
                data: (marksData) => QuickStatsCardWidget(
                  attendancePercentage: 0.0,
                  recentMarks: marksData,
                  onAttendanceTap: () {
                    widget.onNavigateToTab?.call(2);
                  },
                  onMarksTap: () {},
                ),
                loading: () => _buildLoadingCard('Loading quick stats...'),
                error: (error, stack) => _buildErrorCard('Error loading stats'),
              ),
              error: (error, stack) => _buildErrorCard('Error loading attendance'),
            ),
            SizedBox(height: 10.h), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard(String message) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.all(4.w),
      child: Container(
        padding: EdgeInsets.all(4.w),
        height: 20.h,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                  color: AppTheme.lightTheme.primaryColor),
              SizedBox(height: 2.h),
              Text(message, style: AppTheme.lightTheme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.all(4.w),
      child: Container(
        padding: EdgeInsets.all(4.w),
        height: 20.h,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red, size: 48),
              SizedBox(height: 2.h),
              Text(message, style: AppTheme.lightTheme.textTheme.bodyMedium),
              TextButton(
                onPressed: () {
                  ref.invalidate(studentDataProvider);
                  ref.invalidate(studentTodayClassesProvider);
                  ref.invalidate(studentAnnouncementsProvider);
                  ref.invalidate(studentAssignmentsProvider);
                  ref.invalidate(studentAttendancePercentageProvider);
                  ref.invalidate(studentRecentMarksProvider);
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signOutAndRedirectToLogin(String message) async {
    // Sign out the user
    await ref.read(authControllerProvider.notifier).signOut();

    // Show snackbar with message and redirect to login
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.getStatusColor('error'),
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login-screen',
        (route) => false,
      );
    }
  }
}
