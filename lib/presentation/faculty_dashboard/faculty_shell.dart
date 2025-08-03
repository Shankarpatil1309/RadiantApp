import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:radiant_app/config/app_config.dart';

import '../../core/app_export.dart';
import '../../controllers/faculty_dashboard_controller.dart';
import '../../models/faculty_model.dart';
import '../attendance_screen/faculty_attendance_screen.dart';
import '../faculty_assignment_management_screen/faculty_assignment_management_screen.dart';
import '../faculty_assignment_management_screen/widgets/assignment_upload_bottom_sheet_widget.dart';
import '../weekly_schedule_screen/weekly_schedule_screen.dart';
import 'faculty_dashboard.dart';
import '../../models/assignment_model.dart';
import '../../services/assignment_service.dart';

class FacultyShell extends ConsumerStatefulWidget {
  const FacultyShell({super.key});

  @override
  ConsumerState<FacultyShell> createState() => _FacultyShellState();
}

class _FacultyShellState extends ConsumerState<FacultyShell>
    with TickerProviderStateMixin {
  int _selectedBottomNavIndex = 0;
  final String userRole = 'faculty';

  List<Widget> get _screens => [
        FacultyDashboard(onNavigateToTab: _onBottomNavTap),
        WeeklyScheduleScreen(
          isEmbedded: true,
          onBackPressed: () {
            setState(() {
              _selectedBottomNavIndex = 0;
            });
            HapticFeedback.selectionClick();
          },
        ),
        FacultyAssignmentManagementScreen(
          isEmbedded: true,
          onBackPressed: () {
            setState(() {
              _selectedBottomNavIndex = 0;
            });
            HapticFeedback.selectionClick();
          },
        ),
        FacultyAttendanceScreen(
          isEmbedded: true,
          onBackPressed: () {
            setState(() {
              _selectedBottomNavIndex = 0;
            });
            HapticFeedback.selectionClick();
          },
        ),
      ];

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedBottomNavIndex = index;
    });
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedBottomNavIndex == 0, // Only allow pop when on dashboard
      onPopInvokedWithResult: (didPop, result) {
        // If not on dashboard and pop was invoked, go to dashboard
        if (!didPop && _selectedBottomNavIndex != 0) {
          setState(() {
            _selectedBottomNavIndex = 0;
          });
          HapticFeedback.selectionClick();
        }
      },
      child: Stack(
        children: [
          IndexedStack(
            index: _selectedBottomNavIndex,
            children: _screens,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNavigationBar(),
          ),
          Positioned(
            bottom: 100, // Above the bottom navigation bar
            right: 16,
            child: FloatingActionButton(
              heroTag: "faculty_quick_actions_fab",
              onPressed: () {
                _showQuickActions();
              },
              backgroundColor: AppTheme.getRoleColor(userRole),
              child: CustomIconWidget(
                iconName: 'add',
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return NavigationBar(
      selectedIndex: _selectedBottomNavIndex,
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
            color: AppTheme.getRoleColor(userRole),
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
            color: AppTheme.getRoleColor(userRole),
            size: 24,
          ),
          label: 'Classes',
        ),
        NavigationDestination(
          icon: CustomIconWidget(
            iconName: 'assignment',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          selectedIcon: CustomIconWidget(
            iconName: 'assignment',
            color: AppTheme.getRoleColor(userRole),
            size: 24,
          ),
          label: 'Assignments',
        ),
        NavigationDestination(
          icon: CustomIconWidget(
            iconName: 'how_to_reg',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          selectedIcon: CustomIconWidget(
            iconName: 'how_to_reg',
            color: AppTheme.getRoleColor(userRole),
            size: 24,
          ),
          label: 'Attendance',
        ),
      ],
    );
  }

  void _showQuickActions() {
    // Get faculty data from the provider
    final facultyDataAsync = ref.read(facultyDataProvider);

    facultyDataAsync.when(
      data: (facultyData) {
        if (facultyData != null) {
          _showQuickActionsBottomSheet(facultyData);
        } else {
          _showComingSoon('Faculty data not available');
        }
      },
      loading: () => _showComingSoon('Loading faculty data'),
      error: (error, stack) => _showComingSoon('Error loading faculty data'),
    );
  }

  void _showQuickActionsBottomSheet(Faculty facultyData) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Quick Actions',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.getRoleColor(userRole),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.announcement,
                  color: AppTheme.getRoleColor(userRole)),
              title: const Text('Post Announcement'),
              subtitle: const Text('Share announcements with students'),
              onTap: () {
                Navigator.pop(context);
                _showAnnouncementModal(facultyData);
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment_add,
                  color: AppTheme.getRoleColor(userRole)),
              title: const Text('Create Assignment'),
              subtitle: const Text('Create and upload assignment PDFs'),
              onTap: () {
                Navigator.pop(context);
                _showAssignmentModal(facultyData);
              },
            ),
            ListTile(
              leading:
                  Icon(Icons.schedule, color: AppTheme.getRoleColor(userRole)),
              title: const Text('Schedule Class'),
              subtitle: const Text('Schedule one-time or recurring classes'),
              onTap: () {
                Navigator.pop(context);
                _showScheduleClassModal(facultyData);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        backgroundColor: AppTheme.getRoleColor(userRole),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAnnouncementModal(Faculty facultyData) {
    _showCreateAnnouncementBottomSheet(facultyData);
  }

  void _showAssignmentModal(Faculty facultyData) {
    // Use the reusable AssignmentUploadBottomSheetWidget
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AssignmentUploadBottomSheetWidget(
        onUploadAssignment: (assignmentData) async {
          // Handle assignment creation here
          await _handleAssignmentCreation(assignmentData, facultyData);
        },
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _showScheduleClassModal(Faculty facultyData) {
    _showScheduleClassBottomSheet(facultyData);
  }

  // Announcement Modal - Same as faculty_dashboard.dart
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
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.campaign,
                      color: AppTheme.getRoleColor('faculty'),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Create Announcement',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        const SizedBox(height: 16),

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
                        const SizedBox(height: 16),

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
                                  const SizedBox(width: 8),
                                  Text(priority.toUpperCase()),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              setModalState(() => _selectedPriority = value!),
                        ),
                        const SizedBox(height: 16),

                        // Department selection
                        Text(
                          'Target Departments',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
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
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),

              // Submit button
              Container(
                padding: const EdgeInsets.all(16),
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
                  height: 48,
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
                        ? const SizedBox(
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

  // Schedule Class Modal - Simplified version
  void _showScheduleClassBottomSheet(Faculty facultyData) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
            'Class scheduling feature is available in the dashboard. Please use the Quick Actions card on the dashboard.'),
        backgroundColor: AppTheme.getRoleColor(userRole),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Go to Dashboard',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _selectedBottomNavIndex = 0;
            });
          },
        ),
      ),
    );
  }
}
