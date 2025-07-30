import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/class_detail_bottom_sheet.dart';
import './widgets/day_column_widget.dart';
import './widgets/filter_bottom_sheet.dart';
import './widgets/quick_actions_bottom_sheet.dart';
import './widgets/week_navigation_widget.dart';

class WeeklyScheduleScreen extends StatefulWidget {
  final bool isEmbedded;
  final VoidCallback? onBackPressed;
  
  const WeeklyScheduleScreen({
    Key? key,
    this.isEmbedded = false,
    this.onBackPressed,
  }) : super(key: key);

  @override
  State<WeeklyScheduleScreen> createState() => _WeeklyScheduleScreenState();
}

class _WeeklyScheduleScreenState extends State<WeeklyScheduleScreen> {
  DateTime _currentWeek = DateTime.now();
  String _selectedDepartment = 'CSE';
  String _selectedSection = 'A';
  bool _isLoading = false;

  // Mock schedule data
  final List<Map<String, dynamic>> _mockScheduleData = [
    {
      "day": "Monday",
      "date": "29",
      "classes": [
        {
          "time": "09:00",
          "subject": "Mathematics",
          "faculty": "Dr. Rajesh Kumar",
          "room": "Room 101",
          "contact": "+91 9876543210",
          "progress": 75,
          "attendance": 85,
          "totalClasses": 24
        },
        {
          "time": "11:00",
          "subject": "Physics",
          "faculty": "Prof. Anita Sharma",
          "room": "Lab 201",
          "contact": "+91 9876543211",
          "progress": 60,
          "attendance": 90,
          "totalClasses": 20
        },
        {
          "time": "14:00",
          "subject": "Computer Science",
          "faculty": "Dr. Vikram Singh",
          "room": "Room 301",
          "contact": "+91 9876543212",
          "progress": 80,
          "attendance": 88,
          "totalClasses": 22
        }
      ]
    },
    {
      "day": "Tuesday",
      "date": "30",
      "classes": [
        {
          "time": "08:00",
          "subject": "Chemistry",
          "faculty": "Dr. Priya Patel",
          "room": "Lab 102",
          "contact": "+91 9876543213",
          "progress": 65,
          "attendance": 82,
          "totalClasses": 18
        },
        {
          "time": "10:00",
          "subject": "English",
          "faculty": "Ms. Sarah Johnson",
          "room": "Room 205",
          "contact": "+91 9876543214",
          "progress": 70,
          "attendance": 95,
          "totalClasses": 16
        },
        {
          "time": "15:00",
          "subject": "Biology",
          "faculty": "Dr. Amit Verma",
          "room": "Lab 301",
          "contact": "+91 9876543215",
          "progress": 55,
          "attendance": 87,
          "totalClasses": 19
        }
      ]
    },
    {
      "day": "Wednesday",
      "date": "31",
      "classes": [
        {
          "time": "09:00",
          "subject": "Mathematics",
          "faculty": "Dr. Rajesh Kumar",
          "room": "Room 101",
          "contact": "+91 9876543210",
          "progress": 75,
          "attendance": 85,
          "totalClasses": 24
        },
        {
          "time": "13:00",
          "subject": "Computer Science",
          "faculty": "Dr. Vikram Singh",
          "room": "Room 301",
          "contact": "+91 9876543212",
          "progress": 80,
          "attendance": 88,
          "totalClasses": 22
        }
      ]
    },
    {
      "day": "Thursday",
      "date": "01",
      "classes": [
        {
          "time": "10:00",
          "subject": "Physics",
          "faculty": "Prof. Anita Sharma",
          "room": "Lab 201",
          "contact": "+91 9876543211",
          "progress": 60,
          "attendance": 90,
          "totalClasses": 20
        },
        {
          "time": "14:00",
          "subject": "English",
          "faculty": "Ms. Sarah Johnson",
          "room": "Room 205",
          "contact": "+91 9876543214",
          "progress": 70,
          "attendance": 95,
          "totalClasses": 16
        }
      ]
    },
    {
      "day": "Friday",
      "date": "02",
      "classes": [
        {
          "time": "08:00",
          "subject": "Chemistry",
          "faculty": "Dr. Priya Patel",
          "room": "Lab 102",
          "contact": "+91 9876543213",
          "progress": 65,
          "attendance": 82,
          "totalClasses": 18
        },
        {
          "time": "11:00",
          "subject": "Biology",
          "faculty": "Dr. Amit Verma",
          "room": "Lab 301",
          "contact": "+91 9876543215",
          "progress": 55,
          "attendance": 87,
          "totalClasses": 19
        },
        {
          "time": "16:00",
          "subject": "Computer Science",
          "faculty": "Dr. Vikram Singh",
          "room": "Room 301",
          "contact": "+91 9876543212",
          "progress": 80,
          "attendance": 88,
          "totalClasses": 22
        }
      ]
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshSchedule,
        child: Column(
          children: [
            WeekNavigationWidget(
              currentWeek: _currentWeek,
              onPreviousWeek: _goToPreviousWeek,
              onNextWeek: _goToNextWeek,
              onFilterTap: _showFilterBottomSheet,
            ),
            Expanded(
              child:
                  _isLoading ? _buildLoadingWidget() : _buildScheduleContent(),
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

  Widget _buildScheduleContent() {
    return Container(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _mockScheduleData.map((dayData) {
            final isToday = _isToday(dayData['day'] as String);
            return DayColumnWidget(
              dayName: dayData['day'] as String,
              dayDate: dayData['date'] as String,
              isToday: isToday,
              classes:
                  (dayData['classes'] as List).cast<Map<String, dynamic>>(),
              onClassTap: _showClassDetails,
              onClassLongPress: _showQuickActions,
            );
          }).toList(),
        ),
      ),
    );
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
    _refreshSchedule();
  }

  void _goToNextWeek() {
    setState(() {
      _currentWeek = _currentWeek.add(Duration(days: 7));
    });
    _refreshSchedule();
  }

  Future<void> _refreshSchedule() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });
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
    _refreshSchedule();
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
