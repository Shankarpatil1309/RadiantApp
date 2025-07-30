import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_export.dart';
import '../assignments_screen/assignments_screen.dart';
import '../attendance_screen/student_attendance_screen.dart';
import '../weekly_schedule_screen/weekly_schedule_screen.dart';
import 'student_dashboard.dart';

class StudentShell extends ConsumerStatefulWidget {
  const StudentShell({super.key});

  @override
  ConsumerState<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends ConsumerState<StudentShell>
    with TickerProviderStateMixin {
  int _selectedBottomNavIndex = 0;
  final String userRole = 'student';

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      StudentDashboard(onNavigateToTab: _onBottomNavTap),
      WeeklyScheduleScreen(
        isEmbedded: true,
        onBackPressed: () {
          setState(() {
            _selectedBottomNavIndex = 0;
          });
          HapticFeedback.selectionClick();
        },
      ),
      StudentAttendanceScreen(
        isEmbedded: true,
        onBackPressed: () {
          setState(() {
            _selectedBottomNavIndex = 0;
          });
          HapticFeedback.selectionClick();
        },
      ), 
      AssignmentsScreen(
        isEmbedded: true,
        onBackPressed: () {
          setState(() {
            _selectedBottomNavIndex = 0;
          });
          HapticFeedback.selectionClick();
        },
      ),
    ];
  }

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
              child: FloatingActionButton.extended(
                onPressed: () {
                  // Navigate to marksheet
                  _showComingSoon('Marksheet');
                },
                icon: CustomIconWidget(
                  iconName: 'assessment',
                  color: Colors.white,
                  size: 24,
                ),
                label: Text(
                  'Marksheet',
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                  ),
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
          label: 'Schedule',
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
      ],
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