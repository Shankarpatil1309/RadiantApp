import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AttendanceCalendarWidget extends StatefulWidget {
  final Map<String, dynamic> calendarData;
  final Function(DateTime) onDateTap;

  const AttendanceCalendarWidget({
    Key? key,
    required this.calendarData,
    required this.onDateTap,
  }) : super(key: key);

  @override
  State<AttendanceCalendarWidget> createState() =>
      _AttendanceCalendarWidgetState();
}

class _AttendanceCalendarWidgetState extends State<AttendanceCalendarWidget> {
  DateTime selectedMonth = DateTime.now();
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
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
          _buildCalendarHeader(),
          SizedBox(height: 3.h),
          _buildWeekdayHeaders(),
          SizedBox(height: 2.h),
          _buildCalendarGrid(),
          SizedBox(height: 3.h),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'calendar_today',
              color: AppTheme.lightTheme.primaryColor,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Attendance Calendar',
              style: AppTheme.lightTheme.textTheme.titleSmall,
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  selectedMonth =
                      DateTime(selectedMonth.year, selectedMonth.month - 1);
                });
              },
              icon: CustomIconWidget(
                iconName: 'chevron_left',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 20,
              ),
            ),
            Text(
              _getMonthYearString(selectedMonth),
              style: AppTheme.lightTheme.textTheme.titleSmall,
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  selectedMonth =
                      DateTime(selectedMonth.year, selectedMonth.month + 1);
                });
              },
              icon: CustomIconWidget(
                iconName: 'chevron_right',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeekdayHeaders() {
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Row(
      children: weekdays
          .map((day) => Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth =
        DateTime(selectedMonth.year, selectedMonth.month, 1);
    final lastDayOfMonth =
        DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    List<Widget> dayWidgets = [];

    // Add empty cells for days before the first day of the month
    for (int i = 0; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }

    // Add day cells
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(selectedMonth.year, selectedMonth.month, day);
      dayWidgets.add(_buildDayCell(date));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: dayWidgets,
    );
  }

  Widget _buildDayCell(DateTime date) {
    final attendanceRecord = _getAttendanceForDate(date);
    final isToday = _isSameDay(date, DateTime.now());
    final isSelected = _isSameDay(date, selectedDate);

    Color? backgroundColor;
    Color? textColor;
    Widget? statusIcon;

    if (attendanceRecord != null) {
      switch (attendanceRecord['status'] as String) {
        case 'present':
          backgroundColor =
              AppTheme.getStatusColor('success').withValues(alpha: 0.2);
          textColor = AppTheme.getStatusColor('success');
          statusIcon = CustomIconWidget(
            iconName: 'check_circle',
            color: AppTheme.getStatusColor('success'),
            size: 12,
          );
          break;
        case 'absent':
          backgroundColor =
              AppTheme.getStatusColor('error').withValues(alpha: 0.2);
          textColor = AppTheme.getStatusColor('error');
          statusIcon = CustomIconWidget(
            iconName: 'cancel',
            color: AppTheme.getStatusColor('error'),
            size: 12,
          );
          break;
        case 'holiday':
          backgroundColor =
              AppTheme.lightTheme.colorScheme.surfaceContainerHighest;
          textColor = AppTheme.lightTheme.colorScheme.onSurfaceVariant;
          statusIcon = CustomIconWidget(
            iconName: 'event',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 12,
          );
          break;
      }
    }

    if (isSelected) {
      backgroundColor = AppTheme.lightTheme.primaryColor;
      textColor = Colors.white;
    } else if (isToday && backgroundColor == null) {
      backgroundColor = AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1);
      textColor = AppTheme.lightTheme.primaryColor;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDate = date;
        });
        widget.onDateTap(date);
      },
      child: Container(
        margin: EdgeInsets.all(1.w),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: isToday && !isSelected
              ? Border.all(color: AppTheme.lightTheme.primaryColor, width: 1)
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                date.day.toString(),
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: textColor ?? AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (statusIcon != null)
              Positioned(
                top: 1,
                right: 1,
                child: statusIcon,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem(
            'Present', AppTheme.getStatusColor('success'), 'check_circle'),
        _buildLegendItem('Absent', AppTheme.getStatusColor('error'), 'cancel'),
        _buildLegendItem('Holiday',
            AppTheme.lightTheme.colorScheme.onSurfaceVariant, 'event'),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, String iconName) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: color,
          size: 16,
        ),
        SizedBox(width: 1.w),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }

  Map<String, dynamic>? _getAttendanceForDate(DateTime date) {
    final attendanceRecords = widget.calendarData['attendanceRecords'] as List;
    try {
      return attendanceRecords.firstWhere(
        (record) => _isSameDay(DateTime.parse(record['date'] as String), date),
      );
    } catch (e) {
      return null;
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getMonthYearString(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
