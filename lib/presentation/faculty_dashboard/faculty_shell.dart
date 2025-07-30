import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_export.dart';
import '../attendance_screen/faculty_attendance_screen.dart';
import '../faculty_assignment_management_screen/faculty_assignment_management_screen.dart';
import '../weekly_schedule_screen/weekly_schedule_screen.dart';
import 'faculty_dashboard.dart';

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
    _buildProfileTab(),
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
          if (_selectedBottomNavIndex == 0)
            Positioned(
              bottom: 100, // Above the bottom navigation bar
              right: 16,
              child: FloatingActionButton(
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
        NavigationDestination(
          icon: CustomIconWidget(
            iconName: 'person',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          selectedIcon: CustomIconWidget(
            iconName: 'person',
            color: AppTheme.getRoleColor(userRole),
            size: 24,
          ),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _buildProfileTab() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        titleTextStyle: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.getRoleColor(userRole),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: 100,
              color: AppTheme.getRoleColor(userRole),
            ),
            const SizedBox(height: 20),
            Text(
              'Profile Coming Soon',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.getRoleColor(userRole),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.announcement, color: AppTheme.getRoleColor(userRole)),
              title: const Text('Post Announcement'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon('Post Announcement');
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment_add, color: AppTheme.getRoleColor(userRole)),
              title: const Text('Create Assignment'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon('Create Assignment');
              },
            ),
            ListTile(
              leading: Icon(Icons.schedule, color: AppTheme.getRoleColor(userRole)),
              title: const Text('Schedule Class'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon('Schedule Class');
              },
            ),
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
}