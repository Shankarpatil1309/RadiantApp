import 'package:flutter/material.dart';
import 'package:radiant_app/config/app_config.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/admin_service.dart';
import '../../controllers/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './widgets/admin_drawer_widget.dart';
import './widgets/admin_header_widget.dart';
import './widgets/quick_management_card.dart';
import './widgets/recent_activity_card.dart';
import './widgets/system_announcements_card.dart';
import './widgets/user_statistics_card.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AdminService _adminService = AdminService();
  bool _isLoading = true;

  // Firebase data
  Map<String, dynamic>? adminData;
  Map<String, dynamic> statisticsData = {};
  List<Map<String, dynamic>> announcementsData = [];
  List<Map<String, dynamic>> recentActivitiesData = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load data from Firebase in parallel
      final results = await Future.wait([
        _adminService.getAdminData(),
        _adminService.getStatisticsData(),
        _adminService.getAnnouncementsData(),
        _adminService.getRecentActivitiesData(),
      ]);

      setState(() {
        adminData = results[0] as Map<String, dynamic>?;
        statisticsData = results[1] as Map<String, dynamic>;
        announcementsData = results[2] as List<Map<String, dynamic>>;
        recentActivitiesData = results[3] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load dashboard data');
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      drawer: adminData != null
          ? AdminDrawerWidget(
              adminData: adminData!,
              onNavigate: _handleNavigation,
            )
          : null,
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppTheme.getRoleColor('admin'),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Loading dashboard data...',
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshData,
              color: AppTheme.getRoleColor('admin'),
              child: CustomScrollView(
                slivers: [
                  if (adminData != null)
                    SliverToBoxAdapter(
                      child: AdminHeaderWidget(
                        adminData: adminData!,
                        onProfileTap: () => _showAdminProfileMenu(ref),
                        onNotificationTap: () =>
                            _handleNavigation('/notifications'),
                      ),
                    ),
                  SliverPadding(
                    padding: EdgeInsets.all(4.w),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        UserStatisticsCard(
                          statistics: statisticsData,
                          onTap: () => _handleNavigation('/user-statistics'),
                        ),
                        SizedBox(height: 2.h),
                        SystemAnnouncementsCard(
                          announcements: announcementsData,
                          onViewAll: () =>
                              _handleNavigation('/announcement-management'),
                        ),
                        SizedBox(height: 2.h),
                        RecentActivityCard(
                          activities: recentActivitiesData,
                          onViewAll: () => _handleNavigation('/activity-logs'),
                        ),
                        SizedBox(height: 2.h),
                        QuickManagementCard(
                          onAddStudent: () => _handleNavigation('/add-student'),
                          onAddFaculty: () => _handleNavigation('/add-faculty'),
                          onCreateAnnouncement: () =>
                              _handleNavigation('/create-announcement'),
                          onViewReports: () => _handleNavigation('/reports'),
                        ),
                        SizedBox(height: 10.h), // Extra space for FAB
                      ]),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "admin_quick_actions_fab",
        onPressed: _showQuickActions,
        backgroundColor: AppTheme.getRoleColor('admin'),
        foregroundColor: Colors.white,
        icon: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 24,
        ),
        label: Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Quick Actions',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              crossAxisSpacing: 4.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 1,
              children: [
                _buildQuickActionItem('Add Student', 'person_add',
                    AppTheme.getRoleColor('student')),
                _buildQuickActionItem('Add Faculty', 'person_add',
                    AppTheme.getRoleColor('faculty')),
                _buildQuickActionItem(
                    'Announcement', 'campaign', AppTheme.getRoleColor('admin')),
                _buildQuickActionItem('Reports', 'assessment', Colors.purple),
                _buildQuickActionItem('Settings', 'settings', Colors.orange),
                _buildQuickActionItem('Export Data', 'download', Colors.teal),
              ],
            ),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(String title, String iconName, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _handleQuickAction(title);
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: color,
              size: 28,
            ),
            SizedBox(height: 1.h),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    await _loadDashboardData();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dashboard data refreshed successfully'),
        backgroundColor: AppTheme.getStatusColor('success'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.getStatusColor('error'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleNavigation(String route) {
    // Handle navigation based on route
    switch (route) {
      case "/add-student":
      case '/add-faculty':
        Navigator.pushNamed(context, route);
        break;
      case '/create-announcement':
        _showCreateAnnouncementBottomSheet();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Feature coming soon: ${route.replaceAll('/', '').replaceAll('-', ' ')}'),
            backgroundColor: AppTheme.getStatusColor('warning'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  void _handleQuickAction(String action) {
    String route = '';
    switch (action) {
      case 'Add Student':
        route = '/add-student';
        break;
      case 'Add Faculty':
        route = '/add-faculty';
        break;
      case 'Announcement':
        route = '/create-announcement';
        break;
      case 'Reports':
        route = '/reports';
        break;
      case 'Settings':
        route = '/system-settings';
        break;
      case 'Export Data':
        route = '/data-export';
        break;
    }

    if (route.isNotEmpty) {
      _handleNavigation(route);
    }
  }

  void _showCreateAnnouncementBottomSheet() {
    final _titleController = TextEditingController();
    final _contentController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    String _selectedPriority = 'normal';
    List<String> _selectedDepartments = ['All'];
    bool _isLoading = false;

    final List<String> _priorities = ['normal', 'important', 'urgent'];
    final List<String> _departments = ['All', ...AppConfig.departmentCodes];

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
                      color: AppTheme.getRoleColor('admin'),
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
                                color: AppTheme.getRoleColor('admin')),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: AppTheme.getRoleColor('admin')),
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
                                color: AppTheme.getRoleColor('admin')),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: AppTheme.getRoleColor('admin')),
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
                                color: AppTheme.getRoleColor('admin')),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: AppTheme.getRoleColor('admin')),
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
                            children: _departments.map((dept) {
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
                                          _selectedDepartments.add('All');
                                        }
                                      }
                                    }
                                  });
                                },
                                selectedColor: AppTheme.getRoleColor('admin')
                                    .withValues(alpha: 0.2),
                                checkmarkColor: AppTheme.getRoleColor('admin'),
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
                              // Create announcement document
                              final announcementData = {
                                'title': _titleController.text.trim(),
                                'content': _contentController.text.trim(),
                                'priority': _selectedPriority,
                                'departments': _selectedDepartments,
                                'author': adminData?['name'] ?? 'Administrator',
                                'authorId': adminData?['id'] ?? 'admin',
                              };

                              await _adminService
                                  .createAnnouncement(announcementData);

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

                              // Refresh dashboard data to show new announcement
                              _loadDashboardData();
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
                      backgroundColor: AppTheme.getRoleColor('admin'),
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

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return AppTheme.lightTheme.colorScheme.error;
      case 'important':
        return const Color(0xFFFF9800);
      case 'normal':
      default:
        return AppTheme.lightTheme.primaryColor;
    }
  }

  void _showAdminProfileMenu(WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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

            // Admin profile info
            Container(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Container(
                    width: 15.w,
                    height: 15.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.getRoleColor('admin')
                            .withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: adminData?['profileImage'] != null
                          ? CustomImageWidget(
                              imageUrl: adminData!['profileImage'] as String,
                              width: 15.w,
                              height: 15.w,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: AppTheme.getRoleColor('admin')
                                  .withValues(alpha: 0.1),
                              child: CustomIconWidget(
                                iconName: 'person',
                                color: AppTheme.getRoleColor('admin'),
                                size: 8.w,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          adminData?['name'] ?? 'Administrator',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          adminData?['designation'] ?? 'System Administrator',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'ID: ${adminData?['employeeId'] ?? 'ADMIN001'}',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: Colors.grey.withValues(alpha: 0.3)),

            // Menu options
            ListTile(
              leading: CustomIconWidget(
                iconName: 'account_circle',
                color: AppTheme.getRoleColor('admin').withValues(alpha: 0.7),
                size: 24,
              ),
              title: Text(
                'View Profile',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _handleNavigation('/profile-settings');
              },
            ),

            ListTile(
              leading: CustomIconWidget(
                iconName: 'settings',
                color: AppTheme.getRoleColor('admin').withValues(alpha: 0.7),
                size: 24,
              ),
              title: Text(
                'System Settings',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _handleNavigation('/system-settings');
              },
            ),

            ListTile(
              leading: CustomIconWidget(
                iconName: 'admin_panel_settings',
                color: AppTheme.getRoleColor('admin').withValues(alpha: 0.7),
                size: 24,
              ),
              title: Text(
                'Admin Tools',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _handleNavigation('/admin-tools');
              },
            ),

            Divider(color: Colors.grey.withValues(alpha: 0.3)),

            // Sign out option
            ListTile(
              leading: CustomIconWidget(
                iconName: 'logout',
                color: AppTheme.getStatusColor('error'),
                size: 24,
              ),
              title: Text(
                'Sign Out',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.getStatusColor('error'),
                ),
              ),
              onTap: () {
                // Navigator.pop(context);
                _showSignOutConfirmation(ref);
              },
            ),

            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _showSignOutConfirmation(WidgetRef ref) {
    final authController = ref.read(authControllerProvider.notifier);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'warning',
                color: AppTheme.getStatusColor('warning'),
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Sign Out',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to sign out? You will need to log in again to access the admin dashboard.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();

                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Center(
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: AppTheme.getRoleColor('admin'),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Signing out...',
                            style: AppTheme.lightTheme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                );

                try {
                  await authController.signOut();

                  if (context.mounted) {
                    Navigator.of(context).pop(); // Remove loading dialog
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login-screen',
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(context).pop(); // Remove loading dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error signing out: ${e.toString()}'),
                        backgroundColor: AppTheme.getStatusColor('error'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.getStatusColor('error'),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Sign Out',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
