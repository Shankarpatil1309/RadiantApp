import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radiant_app/config/app_config.dart';
import 'package:radiant_app/models/faculty_model.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';

import '../../core/app_export.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/faculty_dashboard_controller.dart';
import '../../services/storage_service.dart';
import '../../models/assignment_model.dart';
import '../../services/assignment_service.dart';
import '../faculty_assignment_management_screen/widgets/assignment_upload_bottom_sheet_widget.dart';
import '../common/widgets/announcement_detail_bottom_sheet.dart';
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

  void _showAnnouncementDialog(Faculty facultyData) {
    _showCreateAnnouncementBottomSheet(facultyData);
  }

  void _showAssignmentDialog(Faculty facultyData) {
    // Use the reusable AssignmentUploadBottomSheetWidget
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AssignmentUploadBottomSheetWidget(
        onUploadAssignment: (assignmentData) async {
          await _handleAssignmentCreation(assignmentData, facultyData);
        },
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _showScheduleClassDialog(Faculty facultyData) {
    _showScheduleClassBottomSheet(facultyData);
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
            return const Center(
                child: Text('Please complete your profile setup'));
          }

          return Column(
            children: [
              FacultyHeaderWidget(
                facultyData: data,
                onProfileTap: () => {},
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
    Faculty facultyData,
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
                announcements: announcements
                    .map((ann) => {
                          'id': ann.id,
                          'title': ann.title,
                          'content': ann.message,
                          'priority': ann.priority,
                          'timeAgo': _formatTimeAgo(ann.createdAt),
                          'author': ann.createdBy,
                        })
                    .toList(),
                onAnnouncementTap: (announcement) {
                  _showAnnouncementDetail(announcement);
                },
                onAnnouncementLongPress: (announcement) {
                  _showAnnouncementOptions(announcement);
                },
              ),
              loading: () => _buildLoadingCard('Loading announcements...'),
              error: (error, stack) =>
                  _buildErrorCard('Error loading announcements'),
            ),
            // AssignmentStatusCard(
            //   assignmentStats: assignmentStats,
            //   onViewAssignments: () {
            //     widget.onNavigateToTab?.call(2);
            //   },
            // ),
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
              onCreateAssignment: () => _showAssignmentDialog(facultyData),
              onScheduleClass: () => _showScheduleClassDialog(facultyData),
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

  void _showAnnouncementDetail(Map<String, dynamic> announcement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AnnouncementDetailBottomSheet(
        announcement: announcement,
        showActions: true,
        onEdit: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Edit functionality coming soon!")),
          );
        },
        onDelete: () {
          Navigator.pop(context);
          _showDeleteConfirmation(announcement);
        },
      ),
    );
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
              CircularProgressIndicator(
                  color: AppTheme.getRoleColor('faculty')),
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

  void _showCreateAnnouncementBottomSheet(Faculty facultyData) {
    final _titleController = TextEditingController();
    final _contentController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    String _selectedPriority = 'normal';
    List<String> _selectedDepartments = [facultyData.department];
    bool _isLoading = false;

    final List<String> _priorities = ['normal', 'important', 'urgent'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: 85.h,
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
                      'Create Announcement',
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
                            prefixIcon: Icon(Icons.title,
                                color: AppTheme.getRoleColor('faculty')),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: AppTheme.getRoleColor('faculty')),
                            ),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true)
                              return 'Title is required';
                            if (value!.length < 5)
                              return 'Title must be at least 5 characters';
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
                            prefixIcon: Icon(Icons.description,
                                color: AppTheme.getRoleColor('faculty')),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: AppTheme.getRoleColor('faculty')),
                            ),
                          ),
                          maxLines: 4,
                          validator: (value) {
                            if (value?.isEmpty ?? true)
                              return 'Content is required';
                            if (value!.length < 10)
                              return 'Content must be at least 10 characters';
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
                            prefixIcon: Icon(Icons.priority_high,
                                color: AppTheme.getRoleColor('faculty')),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: AppTheme.getRoleColor('faculty')),
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
                          onChanged: (value) =>
                              setModalState(() => _selectedPriority = value!),
                        ),
                        SizedBox(height: 2.h),

                        // Department selection
                        Text(
                          'Target Departments',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Wrap(
                            spacing: 2.w,
                            runSpacing: 1.h,
                            children: AppConfig.departmentCodes.map((dept) {
                              final isSelected =
                                  _selectedDepartments.contains(dept);
                              return FilterChip(
                                label: Text(dept),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setModalState(() {
                                    if (dept == 'All') {
                                      if (selected) {
                                        _selectedDepartments = ['All'];
                                      } else {
                                        _selectedDepartments.remove('All');
                                      }
                                    } else {
                                      if (selected) {
                                        _selectedDepartments.remove('All');
                                        _selectedDepartments.add(dept);
                                      } else {
                                        _selectedDepartments.remove(dept);
                                        if (_selectedDepartments.isEmpty) {
                                          _selectedDepartments
                                              .add(facultyData.department);
                                        }
                                      }
                                    }
                                  });
                                },
                                selectedColor: AppTheme.getRoleColor('faculty')
                                    .withValues(alpha: 0.2),
                                checkmarkColor:
                                    AppTheme.getRoleColor('faculty'),
                              );
                            }).toList(),
                          ),
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
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) {
                              return;
                            }

                            if (_selectedDepartments.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                      'Please select at least one department'),
                                  backgroundColor:
                                      AppTheme.getStatusColor('error'),
                                ),
                              );
                              return;
                            }

                            setModalState(() => _isLoading = true);

                            try {
                              // Create announcement document with same structure as admin
                              final announcementData = {
                                'title': _titleController.text.trim(),
                                'content': _contentController.text.trim(),
                                'priority': _selectedPriority,
                                'departments': _selectedDepartments,
                                'author': facultyData.name,
                                'authorId': facultyData.employeeId,
                                'isActive': true,
                                'readBy': <String>[],
                                'createdAt': FieldValue.serverTimestamp(),
                                'updatedAt': FieldValue.serverTimestamp(),
                              };

                              await FirebaseFirestore.instance
                                  .collection('announcements')
                                  .add(announcementData);

                              // Refresh announcements
                              ref.refresh(facultyAnnouncementsProvider);

                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Announcement "${_titleController.text}" created successfully!'),
                                  backgroundColor:
                                      AppTheme.getStatusColor('success'),
                                ),
                              );

                              // Close bottom sheet
                              Navigator.pop(context);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                  backgroundColor:
                                      AppTheme.getStatusColor('error'),
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
                            'Create Announcement',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
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

  // Handle assignment creation using the reusable component
  Future<void> _handleAssignmentCreation(
      Map<String, dynamic> assignmentData, Faculty facultyData) async {
    final assignment = Assignment(
      id: '', // Will be generated by Firestore
      title: assignmentData['title'] ?? '',
      description: assignmentData['description'] ?? '',
      subject: assignmentData['subject'] ?? '',
      department: assignmentData['department'] ?? '',
      section: assignmentData['section'] ?? 'A',
      semester: assignmentData['semester'] ?? 1,
      dueDate:
          assignmentData['deadline'] ?? DateTime.now().add(Duration(days: 7)),
      facultyId: facultyData.employeeId,
      facultyName: facultyData.name,
      type: assignmentData['type'] ?? 'assignment',
      fileUrl: assignmentData['fileUrl'],
      instructions: assignmentData['instructions'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      final assignmentService = AssignmentService();
      await assignmentService.addAssignment(assignment);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Assignment "${assignmentData['title']}" created successfully'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.getStatusColor('success'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create assignment: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.getStatusColor('error'),
        ),
      );
    }
  }

  void _showCreateAssignmentBottomSheet(Faculty facultyData) {
    final _titleController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _instructionsController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    final _storageService = StorageService();

    String _selectedType = 'assignment';
    String _selectedSubject = '';
    String _selectedSection = '';
    int _selectedSemester = 1;
    int _maxMarks = 100;
    DateTime _dueDate = DateTime.now().add(Duration(days: 7));
    List<String> _allowedFormats = ['pdf', 'docx'];
    bool _isLoading = false;
    File? _selectedFile;
    String? _fileName;
    double _uploadProgress = 0.0;
    bool _isUploading = false;

    final List<String> _types = [
      'assignment',
      'project',
      'lab',
      'quiz',
      'presentation'
    ];
    final List<String> _subjects = [
      'Data Structures',
      'Algorithms',
      'Database',
      'Software Engineering',
      'Computer Networks',
      'Operating Systems'
    ];
    final List<String> _sections = ['A', 'B'];
    final List<String> _formats = ['pdf', 'docx', 'jpg', 'png', 'txt', 'zip'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: 90.h,
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
                      Icons.assignment,
                      color: AppTheme.getRoleColor('faculty'),
                      size: 28,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'Create Assignment',
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
                            labelText: 'Assignment Title',
                            hintText: 'Enter assignment title',
                            prefixIcon: Icon(Icons.title,
                                color: AppTheme.getRoleColor('faculty')),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: AppTheme.getRoleColor('faculty')),
                            ),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true)
                              return 'Title is required';
                            if (value!.length < 5)
                              return 'Title must be at least 5 characters';
                            return null;
                          },
                          maxLength: 100,
                        ),
                        SizedBox(height: 2.h),

                        // Description field
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            hintText: 'Enter assignment description',
                            prefixIcon: Icon(Icons.description,
                                color: AppTheme.getRoleColor('faculty')),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: AppTheme.getRoleColor('faculty')),
                            ),
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value?.isEmpty ?? true)
                              return 'Description is required';
                            if (value!.length < 10)
                              return 'Description must be at least 10 characters';
                            return null;
                          },
                          maxLength: 300,
                        ),
                        SizedBox(height: 2.h),

                        // Type and Subject Row
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedType,
                                decoration: InputDecoration(
                                  labelText: 'Type',
                                  prefixIcon: Icon(Icons.category,
                                      color: AppTheme.getRoleColor('faculty')),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color:
                                            AppTheme.getRoleColor('faculty')),
                                  ),
                                ),
                                items: _types.map((type) {
                                  return DropdownMenuItem<String>(
                                    value: type,
                                    child: Text(type.toUpperCase()),
                                  );
                                }).toList(),
                                onChanged: (value) =>
                                    setModalState(() => _selectedType = value!),
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedSubject.isEmpty
                                    ? null
                                    : _selectedSubject,
                                decoration: InputDecoration(
                                  labelText: 'Subject',
                                  prefixIcon: Icon(Icons.book,
                                      color: AppTheme.getRoleColor('faculty')),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color:
                                            AppTheme.getRoleColor('faculty')),
                                  ),
                                ),
                                items: _subjects.map((subject) {
                                  return DropdownMenuItem<String>(
                                    value: subject,
                                    child: Text(subject),
                                  );
                                }).toList(),
                                onChanged: (value) => setModalState(
                                    () => _selectedSubject = value!),
                                validator: (value) => value == null
                                    ? 'Subject is required'
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),

                        // Section and Semester Row
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedSection.isEmpty
                                    ? null
                                    : _selectedSection,
                                decoration: InputDecoration(
                                  labelText: 'Section',
                                  prefixIcon: Icon(Icons.group,
                                      color: AppTheme.getRoleColor('faculty')),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color:
                                            AppTheme.getRoleColor('faculty')),
                                  ),
                                ),
                                items: _sections.map((section) {
                                  return DropdownMenuItem<String>(
                                    value: section,
                                    child: Text('Section $section'),
                                  );
                                }).toList(),
                                onChanged: (value) => setModalState(
                                    () => _selectedSection = value!),
                                validator: (value) => value == null
                                    ? 'Section is required'
                                    : null,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: _selectedSemester,
                                decoration: InputDecoration(
                                  labelText: 'Semester',
                                  prefixIcon: Icon(Icons.school,
                                      color: AppTheme.getRoleColor('faculty')),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color:
                                            AppTheme.getRoleColor('faculty')),
                                  ),
                                ),
                                items: List.generate(8, (index) => index + 1)
                                    .map((sem) {
                                  return DropdownMenuItem<int>(
                                    value: sem,
                                    child: Text('Semester $sem'),
                                  );
                                }).toList(),
                                onChanged: (value) => setModalState(
                                    () => _selectedSemester = value!),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),

                        // Max Marks field
                        TextFormField(
                          initialValue: _maxMarks.toString(),
                          decoration: InputDecoration(
                            labelText: 'Maximum Marks',
                            hintText: 'Enter maximum marks',
                            prefixIcon: Icon(Icons.grade,
                                color: AppTheme.getRoleColor('faculty')),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: AppTheme.getRoleColor('faculty')),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty ?? true)
                              return 'Max marks is required';
                            final marks = int.tryParse(value!);
                            if (marks == null || marks <= 0)
                              return 'Enter valid marks';
                            return null;
                          },
                          onChanged: (value) {
                            final marks = int.tryParse(value);
                            if (marks != null) _maxMarks = marks;
                          },
                        ),
                        SizedBox(height: 2.h),

                        // Due Date
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _dueDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(Duration(days: 365)),
                            );
                            if (picked != null) {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(_dueDate),
                              );
                              if (time != null) {
                                setModalState(() {
                                  _dueDate = DateTime(
                                    picked.year,
                                    picked.month,
                                    picked.day,
                                    time.hour,
                                    time.minute,
                                  );
                                });
                              }
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.event,
                                    color: AppTheme.getRoleColor('faculty')),
                                SizedBox(width: 3.w),
                                Text(
                                  'Due: ${_dueDate.day}/${_dueDate.month}/${_dueDate.year} at ${_dueDate.hour}:${_dueDate.minute.toString().padLeft(2, '0')}',
                                  style:
                                      AppTheme.lightTheme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),

                        // Allowed Formats
                        Text(
                          'Allowed File Formats',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Wrap(
                            spacing: 2.w,
                            runSpacing: 1.h,
                            children: _formats.map((format) {
                              final isSelected =
                                  _allowedFormats.contains(format);
                              return FilterChip(
                                label: Text(format.toUpperCase()),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setModalState(() {
                                    if (selected) {
                                      _allowedFormats.add(format);
                                    } else {
                                      _allowedFormats.remove(format);
                                    }
                                  });
                                },
                                selectedColor: AppTheme.getRoleColor('faculty')
                                    .withValues(alpha: 0.2),
                                checkmarkColor:
                                    AppTheme.getRoleColor('faculty'),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 2.h),

                        // Instructions field
                        TextFormField(
                          controller: _instructionsController,
                          decoration: InputDecoration(
                            labelText: 'Instructions (Optional)',
                            hintText:
                                'Enter additional instructions for students',
                            prefixIcon: Icon(Icons.info,
                                color: AppTheme.getRoleColor('faculty')),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: AppTheme.getRoleColor('faculty')),
                            ),
                          ),
                          maxLines: 3,
                          maxLength: 200,
                        ),
                        SizedBox(height: 2.h),

                        // PDF Upload Section
                        Text(
                          'Assignment PDF',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        InkWell(
                          onTap: _isLoading || _isUploading
                              ? null
                              : () async {
                                  try {
                                    final result =
                                        await FilePicker.platform.pickFiles(
                                      type: FileType.custom,
                                      allowedExtensions: ['pdf'],
                                      allowMultiple: false,
                                    );

                                    if (result != null &&
                                        result.files.isNotEmpty) {
                                      final file =
                                          File(result.files.single.path!);
                                      final fileSize = await file.length();
                                      const maxSize = 10 * 1024 * 1024; // 10MB

                                      if (fileSize > maxSize) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'File size must be less than 10MB'),
                                            backgroundColor:
                                                AppTheme.getStatusColor(
                                                    'error'),
                                          ),
                                        );
                                        return;
                                      }

                                      setModalState(() {
                                        _selectedFile = file;
                                        _fileName = result.files.single.name;
                                      });
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Error selecting file: ${e.toString()}'),
                                        backgroundColor:
                                            AppTheme.getStatusColor('error'),
                                      ),
                                    );
                                  }
                                },
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedFile != null
                                    ? AppTheme.getRoleColor('faculty')
                                    : Colors.grey,
                                width: _selectedFile != null ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: _selectedFile != null
                                  ? AppTheme.getRoleColor('faculty')
                                      .withValues(alpha: 0.05)
                                  : Colors.grey.withValues(alpha: 0.05),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _selectedFile != null
                                      ? Icons.check_circle
                                      : Icons.upload_file,
                                  color: _selectedFile != null
                                      ? AppTheme.getRoleColor('faculty')
                                      : Colors.grey[600],
                                  size: 28,
                                ),
                                SizedBox(width: 3.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedFile != null
                                            ? _fileName ?? 'Selected PDF'
                                            : 'Select Assignment PDF',
                                        style: AppTheme
                                            .lightTheme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: _selectedFile != null
                                              ? AppTheme.getRoleColor('faculty')
                                              : Colors.grey[700],
                                          fontWeight: _selectedFile != null
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      if (_selectedFile != null) ...[
                                        SizedBox(height: 0.5.h),
                                        FutureBuilder<int>(
                                          future: _selectedFile!.length(),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              return Text(
                                                'Size: ${StorageService.getFileSizeString(snapshot.data!)}',
                                                style: AppTheme.lightTheme
                                                    .textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: Colors.grey[600],
                                                ),
                                              );
                                            }
                                            return SizedBox.shrink();
                                          },
                                        ),
                                      ] else ...[
                                        SizedBox(height: 0.5.h),
                                        Text(
                                          'Tap to select PDF file (Max 10MB)',
                                          style: AppTheme
                                              .lightTheme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (_selectedFile != null)
                                  IconButton(
                                    onPressed: () {
                                      setModalState(() {
                                        _selectedFile = null;
                                        _fileName = null;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // Upload Progress
                        if (_isUploading) ...[
                          SizedBox(height: 2.h),
                          Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: AppTheme.getRoleColor('faculty')
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.getRoleColor('faculty')
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.cloud_upload,
                                      color: AppTheme.getRoleColor('faculty'),
                                      size: 20,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      'Uploading PDF... ${(_uploadProgress * 100).toStringAsFixed(1)}%',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: AppTheme.getRoleColor('faculty'),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 1.h),
                                LinearProgressIndicator(
                                  value: _uploadProgress,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.getRoleColor('faculty'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

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
                    onPressed: _isLoading || _isUploading
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) {
                              return;
                            }

                            if (_allowedFormats.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                      'Please select at least one file format'),
                                  backgroundColor:
                                      AppTheme.getStatusColor('error'),
                                ),
                              );
                              return;
                            }

                            setModalState(() => _isLoading = true);

                            String?
                                fileUrl; // Declare outside try block for cleanup access

                            try {
                              // Upload PDF file if selected
                              if (_selectedFile != null) {
                                setModalState(() => _isUploading = true);

                                fileUrl =
                                    await _storageService.uploadAssignmentPDF(
                                  file: _selectedFile!,
                                  facultyId: facultyData.employeeId,
                                  assignmentTitle: _titleController.text.trim(),
                                  onProgress: (progress) {
                                    setModalState(
                                        () => _uploadProgress = progress);
                                  },
                                );

                                setModalState(() => _isUploading = false);
                              }

                              // Create assignment document
                              final assignmentData = {
                                'title': _titleController.text.trim(),
                                'description':
                                    _descriptionController.text.trim(),
                                'subject': _selectedSubject,
                                'department': facultyData.department,
                                'section': _selectedSection,
                                'semester': _selectedSemester,
                                'dueDate': Timestamp.fromDate(_dueDate),
                                'facultyId': facultyData.employeeId,
                                'facultyName': facultyData.name,
                                'maxMarks': _maxMarks,
                                'type': _selectedType,
                                'isActive': true,
                                'allowedFormats': _allowedFormats,
                                'instructions':
                                    _instructionsController.text.trim().isEmpty
                                        ? null
                                        : _instructionsController.text.trim(),
                                'fileUrl': fileUrl, // Add the uploaded file URL
                                'createdAt': FieldValue.serverTimestamp(),
                                'updatedAt': FieldValue.serverTimestamp(),
                              };

                              await FirebaseFirestore.instance
                                  .collection('assignments')
                                  .add(assignmentData);

                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Assignment "${_titleController.text}" created successfully!'),
                                  backgroundColor:
                                      AppTheme.getStatusColor('success'),
                                ),
                              );

                              // Close bottom sheet
                              Navigator.pop(context);
                            } catch (e) {
                              // Clean up uploaded file if assignment creation fails
                              if (fileUrl != null) {
                                try {
                                  await _storageService.deleteFile(fileUrl);
                                } catch (deleteError) {
                                  print(
                                      'Failed to delete uploaded file: $deleteError');
                                }
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                  backgroundColor:
                                      AppTheme.getStatusColor('error'),
                                ),
                              );
                            } finally {
                              setModalState(() {
                                _isLoading = false;
                                _isUploading = false;
                                _uploadProgress = 0.0;
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.getRoleColor('faculty'),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading || _isUploading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                _isUploading
                                    ? 'Uploading PDF...'
                                    : 'Creating Assignment...',
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Create Assignment',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
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

  void _showScheduleClassBottomSheet(Faculty facultyData) {
    final _titleController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _roomController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    String _selectedType = 'lecture';
    String _selectedSubject = '';
    String _selectedSection = '';
    int _selectedSemester = 1;
    DateTime _startTime = DateTime.now().add(Duration(hours: 1));
    DateTime _endTime = DateTime.now().add(Duration(hours: 2, minutes: 30));
    bool _isRecurring = false;
    String _recurringPattern = 'weekly';
    DateTime? _recurringEndDate;
    bool _isLoading = false;

    final List<String> _types = [
      'lecture',
      'lab',
      'tutorial',
      'exam',
      'seminar'
    ];
    final List<String> _subjects = [
      'Data Structures',
      'Algorithms',
      'Database',
      'Software Engineering',
      'Computer Networks',
      'Operating Systems'
    ];
    final List<String> _sections = ['A', 'B'];
    final List<String> _recurringPatterns = ['daily', 'weekly', 'monthly'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: 85.h,
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
                      Icons.schedule,
                      color: AppTheme.getRoleColor('faculty'),
                      size: 28,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'Schedule Class',
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
                            labelText: 'Class Title',
                            hintText: 'Enter class title',
                            prefixIcon: Icon(Icons.title,
                                color: AppTheme.getRoleColor('faculty')),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: AppTheme.getRoleColor('faculty')),
                            ),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true)
                              return 'Title is required';
                            if (value!.length < 3)
                              return 'Title must be at least 3 characters';
                            return null;
                          },
                          maxLength: 100,
                        ),
                        SizedBox(height: 2.h),

                        // Type and Subject Row
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedType,
                                decoration: InputDecoration(
                                  labelText: 'Type',
                                  prefixIcon: Icon(Icons.category,
                                      color: AppTheme.getRoleColor('faculty')),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color:
                                            AppTheme.getRoleColor('faculty')),
                                  ),
                                ),
                                items: _types.map((type) {
                                  return DropdownMenuItem<String>(
                                    value: type,
                                    child: Text(type.toUpperCase()),
                                  );
                                }).toList(),
                                onChanged: (value) =>
                                    setModalState(() => _selectedType = value!),
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedSubject.isEmpty
                                    ? null
                                    : _selectedSubject,
                                decoration: InputDecoration(
                                  labelText: 'Subject',
                                  prefixIcon: Icon(Icons.book,
                                      color: AppTheme.getRoleColor('faculty')),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color:
                                            AppTheme.getRoleColor('faculty')),
                                  ),
                                ),
                                items: _subjects.map((subject) {
                                  return DropdownMenuItem<String>(
                                    value: subject,
                                    child: Text(subject),
                                  );
                                }).toList(),
                                onChanged: (value) => setModalState(
                                    () => _selectedSubject = value!),
                                validator: (value) => value == null
                                    ? 'Subject is required'
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),

                        // Section and Semester Row
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedSection.isEmpty
                                    ? null
                                    : _selectedSection,
                                decoration: InputDecoration(
                                  labelText: 'Section',
                                  prefixIcon: Icon(Icons.group,
                                      color: AppTheme.getRoleColor('faculty')),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color:
                                            AppTheme.getRoleColor('faculty')),
                                  ),
                                ),
                                items: _sections.map((section) {
                                  return DropdownMenuItem<String>(
                                    value: section,
                                    child: Text('Section $section'),
                                  );
                                }).toList(),
                                onChanged: (value) => setModalState(
                                    () => _selectedSection = value!),
                                validator: (value) => value == null
                                    ? 'Section is required'
                                    : null,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: _selectedSemester,
                                decoration: InputDecoration(
                                  labelText: 'Semester',
                                  prefixIcon: Icon(Icons.school,
                                      color: AppTheme.getRoleColor('faculty')),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color:
                                            AppTheme.getRoleColor('faculty')),
                                  ),
                                ),
                                items: List.generate(8, (index) => index + 1)
                                    .map((sem) {
                                  return DropdownMenuItem<int>(
                                    value: sem,
                                    child: Text('Semester $sem'),
                                  );
                                }).toList(),
                                onChanged: (value) => setModalState(
                                    () => _selectedSemester = value!),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),

                        // Room field
                        TextFormField(
                          controller: _roomController,
                          decoration: InputDecoration(
                            labelText: 'Room/Location',
                            hintText: 'Enter room number or location',
                            prefixIcon: Icon(Icons.location_on,
                                color: AppTheme.getRoleColor('faculty')),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: AppTheme.getRoleColor('faculty')),
                            ),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true)
                              return 'Room is required';
                            return null;
                          },
                        ),
                        SizedBox(height: 2.h),

                        // Start Time
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _startTime,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(Duration(days: 365)),
                            );
                            if (picked != null) {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(_startTime),
                              );
                              if (time != null) {
                                setModalState(() {
                                  _startTime = DateTime(
                                    picked.year,
                                    picked.month,
                                    picked.day,
                                    time.hour,
                                    time.minute,
                                  );
                                  // Auto-adjust end time to 1.5 hours later
                                  _endTime = _startTime
                                      .add(Duration(hours: 1, minutes: 30));
                                });
                              }
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.access_time,
                                    color: AppTheme.getRoleColor('faculty')),
                                SizedBox(width: 3.w),
                                Text(
                                  'Start: ${_startTime.day}/${_startTime.month}/${_startTime.year} at ${_startTime.hour}:${_startTime.minute.toString().padLeft(2, '0')}',
                                  style:
                                      AppTheme.lightTheme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),

                        // End Time
                        InkWell(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(_endTime),
                            );
                            if (time != null) {
                              setModalState(() {
                                _endTime = DateTime(
                                  _startTime.year,
                                  _startTime.month,
                                  _startTime.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.access_time_filled,
                                    color: AppTheme.getRoleColor('faculty')),
                                SizedBox(width: 3.w),
                                Text(
                                  'End: ${_endTime.hour}:${_endTime.minute.toString().padLeft(2, '0')}',
                                  style:
                                      AppTheme.lightTheme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),

                        // Recurring checkbox
                        CheckboxListTile(
                          title: Text('Recurring Class'),
                          subtitle: Text('Schedule this class to repeat'),
                          value: _isRecurring,
                          activeColor: AppTheme.getRoleColor('faculty'),
                          onChanged: (value) =>
                              setModalState(() => _isRecurring = value!),
                        ),

                        if (_isRecurring) ...[
                          SizedBox(height: 1.h),
                          DropdownButtonFormField<String>(
                            value: _recurringPattern,
                            decoration: InputDecoration(
                              labelText: 'Repeat Pattern',
                              prefixIcon: Icon(Icons.repeat,
                                  color: AppTheme.getRoleColor('faculty')),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: AppTheme.getRoleColor('faculty')),
                              ),
                            ),
                            items: _recurringPatterns.map((pattern) {
                              return DropdownMenuItem<String>(
                                value: pattern,
                                child: Text(pattern.toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (value) =>
                                setModalState(() => _recurringPattern = value!),
                          ),
                          SizedBox(height: 2.h),
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _recurringEndDate ??
                                    DateTime.now().add(Duration(days: 30)),
                                firstDate: _startTime,
                                lastDate:
                                    DateTime.now().add(Duration(days: 365)),
                              );
                              if (picked != null) {
                                setModalState(() => _recurringEndDate = picked);
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.event_repeat,
                                      color: AppTheme.getRoleColor('faculty')),
                                  SizedBox(width: 3.w),
                                  Text(
                                    _recurringEndDate == null
                                        ? 'Select recurring end date'
                                        : 'Repeat until: ${_recurringEndDate!.day}/${_recurringEndDate!.month}/${_recurringEndDate!.year}',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: 2.h),

                        // Description field
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description (Optional)',
                            hintText: 'Enter class description or notes',
                            prefixIcon: Icon(Icons.description,
                                color: AppTheme.getRoleColor('faculty')),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: AppTheme.getRoleColor('faculty')),
                            ),
                          ),
                          maxLines: 3,
                          maxLength: 200,
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
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) {
                              return;
                            }

                            if (_endTime.isBefore(_startTime)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                      'End time must be after start time'),
                                  backgroundColor:
                                      AppTheme.getStatusColor('error'),
                                ),
                              );
                              return;
                            }

                            if (_isRecurring && _recurringEndDate == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                      'Please select recurring end date'),
                                  backgroundColor:
                                      AppTheme.getStatusColor('error'),
                                ),
                              );
                              return;
                            }

                            setModalState(() => _isLoading = true);

                            try {
                              // Create class session document
                              final sessionData = {
                                'title': _titleController.text.trim(),
                                'subject': _selectedSubject,
                                'department': facultyData.department,
                                'section': _selectedSection,
                                'semester': _selectedSemester,
                                'facultyId': facultyData.employeeId,
                                'facultyName': facultyData.name,
                                'room': _roomController.text.trim(),
                                'startTime': Timestamp.fromDate(_startTime),
                                'endTime': Timestamp.fromDate(_endTime),
                                'type': _selectedType,
                                'description':
                                    _descriptionController.text.trim().isEmpty
                                        ? null
                                        : _descriptionController.text.trim(),
                                'isActive': true,
                                'isRecurring': _isRecurring,
                                'recurringPattern':
                                    _isRecurring ? _recurringPattern : null,
                                'recurringEndDate':
                                    _isRecurring && _recurringEndDate != null
                                        ? Timestamp.fromDate(_recurringEndDate!)
                                        : null,
                                'attendees': <String>[],
                                'status': 'scheduled',
                                'createdAt': FieldValue.serverTimestamp(),
                                'updatedAt': FieldValue.serverTimestamp(),
                              };

                              await FirebaseFirestore.instance
                                  .collection('class_sessions')
                                  .add(sessionData);

                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Class "${_titleController.text}" scheduled successfully!'),
                                  backgroundColor:
                                      AppTheme.getStatusColor('success'),
                                ),
                              );

                              // Close bottom sheet
                              Navigator.pop(context);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                  backgroundColor:
                                      AppTheme.getStatusColor('error'),
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
                            'Schedule Class',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
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
