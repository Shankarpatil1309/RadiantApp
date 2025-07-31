import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/faculty_dashboard_controller.dart';
import '../../models/announcement_model.dart';
import './widgets/assignment_status_card.dart';
import './widgets/faculty_bottom_sheet.dart';
import './widgets/faculty_header_widget.dart';
import './widgets/quick_actions_card.dart';
import './widgets/recent_announcements_card.dart';
import './widgets/today_classes_card.dart';

class FacultyDashboard extends ConsumerStatefulWidget {
  final Function(int)? onNavigateToTab;
  
  const FacultyDashboard({Key? key, this.onNavigateToTab}) : super(key: key);

  @override
  ConsumerState<FacultyDashboard> createState() => _FacultyDashboardState();
}

class _FacultyDashboardState extends ConsumerState<FacultyDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;


  final Map<String, dynamic> assignmentStats = {
    "total": 12,
    "pendingReview": 8,
    "submissions": 156,
    "overdue": 3,
    "reviewed": 4
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.index = 0; // Dashboard tab active
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => FacultyBottomSheet(onMarkAttendance: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.facultyAttendanceScreen);
            }, onUploadAssignment: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.facultyAssignmentsScreen);
            }, onPostAnnouncement: () {
              Navigator.pop(context);
              // This will be handled by the QuickActionsCard callback
            }));
  }

  void _showAnnouncementDialog(Map<String, dynamic> facultyData) {
    _showCreateAnnouncementBottomSheet(facultyData);
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
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
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await ref.read(authControllerProvider.notifier).signOut();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/login-screen');
                }
              },
              child: Text(
                'Logout',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final facultyData = ref.watch(facultyDataProvider);
    final todayClasses = ref.watch(facultyTodayClassesProvider);
    final announcements = ref.watch(facultyAnnouncementsProvider);

    return Scaffold(
      body: facultyData.when(
        data: (data) {
          if (data == null) {
            return const Center(child: Text('Please complete your profile setup'));
          }
          
          return Column(
            children: [
              FacultyHeaderWidget(
                facultyData: data,
                onProfileTap: () => widget.onNavigateToTab?.call(4),
                onNotificationTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Opening notifications...")),
                  );
                },
                onLogoutTap: () => _showLogoutDialog(),
              ),
              Expanded(
                child: _buildDashboardTab(data, todayClasses, announcements),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Error loading faculty data'),
              TextButton(
                onPressed: () => ref.refresh(facultyDataProvider),
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardTab(
    Map<String, dynamic> facultyData,
    AsyncValue<List<Map<String, dynamic>>> todayClassesAsync,
    AsyncValue<List<dynamic>> announcementsAsync,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(facultyDataProvider);
        ref.refresh(facultyTodayClassesProvider);
        ref.refresh(facultyAnnouncementsProvider);
      },
      color: AppTheme.getRoleColor('faculty'),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 1.h),
            todayClassesAsync.when(
              data: (todayClasses) => TodayClassesCard(
                todayClasses: todayClasses,
                onClassTap: (classData) {
                  widget.onNavigateToTab?.call(1);
                },
                onMarkAttendance: (classData) {
                  widget.onNavigateToTab?.call(3);
                },
              ),
              loading: () => _buildLoadingCard('Loading today\'s classes...'),
              error: (error, stack) => _buildErrorCard('Error loading classes'),
            ),
            announcementsAsync.when(
              data: (announcements) => RecentAnnouncementsCard(
                announcements: announcements.map((ann) => {
                  'id': ann.id,
                  'title': ann.title,
                  'content': ann.message,
                  'priority': ann.priority,
                  'timeAgo': _formatTimeAgo(ann.createdAt),
                  'author': ann.createdBy,
                }).toList(),
                onAnnouncementTap: (announcement) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Opening: ${announcement["title"]}")),
                  );
                },
                onAnnouncementLongPress: (announcement) {
                  _showAnnouncementOptions(announcement);
                },
              ),
              loading: () => _buildLoadingCard('Loading announcements...'),
              error: (error, stack) => _buildErrorCard('Error loading announcements'),
            ),
            AssignmentStatusCard(
              assignmentStats: assignmentStats,
              onViewAssignments: () {
                widget.onNavigateToTab?.call(2);
              },
            ),
            QuickActionsCard(
              onMarkAttendance: () {
                widget.onNavigateToTab?.call(3);
              },
              onPostAnnouncement: () => _showAnnouncementDialog(facultyData),
              onViewSchedule: () {
                widget.onNavigateToTab?.call(1);
              },
              onManageAssignments: () {
                widget.onNavigateToTab?.call(2);
              },
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _buildClassesTab() {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      CustomIconWidget(
          iconName: 'school',
          color: AppTheme.getRoleColor('faculty'),
          size: 64),
      SizedBox(height: 2.h),
      Text("Classes",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.getRoleColor('faculty'),
              fontWeight: FontWeight.w600)),
      SizedBox(height: 1.h),
      Text("Manage your class schedules and sessions",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6)),
          textAlign: TextAlign.center),
    ]));
  }

  Widget _buildAssignmentsTab() {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      CustomIconWidget(
          iconName: 'assignment',
          color: AppTheme.getRoleColor('faculty'),
          size: 64),
      SizedBox(height: 2.h),
      Text("Assignments",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.getRoleColor('faculty'),
              fontWeight: FontWeight.w600)),
      SizedBox(height: 1.h),
      Text("Create and manage student assignments",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6)),
          textAlign: TextAlign.center),
    ]));
  }

  Widget _buildAttendanceTab() {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      CustomIconWidget(
          iconName: 'how_to_reg',
          color: AppTheme.getRoleColor('faculty'),
          size: 64),
      SizedBox(height: 2.h),
      Text("Attendance",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.getRoleColor('faculty'),
              fontWeight: FontWeight.w600)),
      SizedBox(height: 1.h),
      Text("Mark and track student attendance",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6)),
          textAlign: TextAlign.center),
    ]));
  }

  Widget _buildProfileTab() {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      CustomIconWidget(
          iconName: 'person',
          color: AppTheme.getRoleColor('faculty'),
          size: 64),
      SizedBox(height: 2.h),
      Text("Profile",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.getRoleColor('faculty'),
              fontWeight: FontWeight.w600)),
      SizedBox(height: 1.h),
      Text("Manage your faculty profile and settings",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6)),
          textAlign: TextAlign.center),
    ]));
  }

  void _showAnnouncementOptions(Map<String, dynamic> announcement) {
    showModalBottomSheet(
        context: context,
        builder: (context) => Container(
            padding: EdgeInsets.all(4.w),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ListTile(
                  leading: CustomIconWidget(
                      iconName: 'edit',
                      color: AppTheme.getRoleColor('faculty'),
                      size: 24),
                  title: const Text("Edit Announcement"),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Edit functionality coming soon!")));
                  }),
              ListTile(
                  leading: CustomIconWidget(
                      iconName: 'delete',
                      color: AppTheme.getStatusColor('error'),
                      size: 24),
                  title: const Text("Delete Announcement"),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(announcement);
                  }),
            ])));
  }

  void _showDeleteConfirmation(Map<String, dynamic> announcement) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text("Delete Announcement"),
                content: Text(
                    "Are you sure you want to delete '${announcement["title"]}'?"),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel")),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Announcement deleted successfully!")));
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.getStatusColor('error')),
                      child: const Text("Delete")),
                ]));
  }

  Widget _buildLoadingCard(String message) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(4.w),
        height: 20.h,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.getRoleColor('faculty')),
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
                  ref.refresh(facultyDataProvider);
                  ref.refresh(facultyTodayClassesProvider);
                  ref.refresh(facultyAnnouncementsProvider);
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showCreateAnnouncementBottomSheet(Map<String, dynamic> facultyData) {
    final _titleController = TextEditingController();
    final _contentController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    
    String _selectedPriority = 'normal';
    bool _isLoading = false;

    final List<String> _priorities = ['normal', 'important', 'urgent'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: 75.h,
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
                      color: AppTheme.getRoleColor('faculty'),
                      size: 28,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'Post Announcement',
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
                            prefixIcon: Icon(Icons.title, color: AppTheme.getRoleColor('faculty')),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppTheme.getRoleColor('faculty')),
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
                            prefixIcon: Icon(Icons.description, color: AppTheme.getRoleColor('faculty')),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppTheme.getRoleColor('faculty')),
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
                            prefixIcon: Icon(Icons.priority_high, color: AppTheme.getRoleColor('faculty')),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppTheme.getRoleColor('faculty')),
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

                      setModalState(() => _isLoading = true);

                      try {
                        final announcementService = ref.read(announcementServiceProvider);
                        
                        final announcement = Announcement(
                          id: '', // Firestore will generate
                          title: _titleController.text.trim(),
                          message: _contentController.text.trim(),
                          priority: _selectedPriority,
                          department: facultyData['department'],
                          createdBy: facultyData['name'],
                          createdAt: DateTime.now(),
                        );

                        await announcementService.addAnnouncement(announcement);

                        // Refresh announcements
                        ref.refresh(facultyAnnouncementsProvider);

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Announcement "${_titleController.text}" posted successfully!'),
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
                      backgroundColor: AppTheme.getRoleColor('faculty'),
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
                            'Post Announcement',
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
        return AppTheme.getRoleColor('faculty');
    }
  }
}
