import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class DayColumnWidget extends StatelessWidget {
  final String dayName;
  final String dayDate;
  final bool isToday;
  final List<Map<String, dynamic>> classes;
  final Function(Map<String, dynamic>) onClassTap;
  final Function(Map<String, dynamic>) onClassLongPress;
  final Function(String, String)? onFreePeriodTap; // timeSlot, date

  const DayColumnWidget({
    Key? key,
    required this.dayName,
    required this.dayDate,
    required this.isToday,
    required this.classes,
    required this.onClassTap,
    required this.onClassLongPress,
    this.onFreePeriodTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 35.w,
      margin: EdgeInsets.only(right: 3.w),
      child: Column(
        children: [
          // Day header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 1.5.h),
            decoration: BoxDecoration(
              color: isToday
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  dayName,
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    color: isToday
                        ? Colors.white
                        : AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  dayDate,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: isToday
                        ? Colors.white.withValues(alpha: 0.9)
                        : AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          // Time slots and classes
          Expanded(
            child: _buildTimeSlots(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlots() {
    final timeSlots = _generateTimeSlots();

    return ListView.builder(
      itemCount: timeSlots.length,
      itemBuilder: (context, index) {
        final timeSlot = timeSlots[index];
        final classForSlot = _getClassForTimeSlot(timeSlot);

        return Container(
          height: 12.h,
          margin: EdgeInsets.only(bottom: 1.h),
          child: classForSlot != null
              ? _buildClassCard(classForSlot)
              : _buildEmptySlot(timeSlot, dayDate),
        );
      },
    );
  }

  List<String> _generateTimeSlots() {
    // Generate time slots with 1.5-hour gaps to match class duration
    return [
      '09:00',
      '10:30', 
      '12:00',
      '13:30',
      '15:00',
      '16:30'
    ];
  }

  Map<String, dynamic>? _getClassForTimeSlot(String timeSlot) {
    return classes.cast<Map<String, dynamic>?>().firstWhere(
          (classItem) => classItem != null && classItem['time'].startsWith(timeSlot),
          orElse: () => null,
        );
  }

  Widget _buildClassCard(Map<String, dynamic> classData) {
    final subjectColors = {
      'Mathematics': Colors.blue,
      'Physics': Colors.green,
      'Chemistry': Colors.orange,
      'Computer Science': Colors.purple,
      'English': Colors.red,
      'Biology': Colors.teal,
    };

    final color = subjectColors[classData['subject'] as String] ?? Colors.grey;

    return GestureDetector(
      onTap: () => onClassTap(classData),
      onLongPress: () => onClassLongPress(classData),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              classData['subject'] as String,
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 1.h),
            Text(
              classData['faculty'] as String,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'location_on',
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                  size: 12,
                ),
                SizedBox(width: 1.w),
                Expanded(
                  child: Text(
                    classData['room'] as String,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySlot(String timeSlot, String date) {
    return GestureDetector(
      onTap: onFreePeriodTap != null ? () => onFreePeriodTap!(timeSlot, date) : null,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: onFreePeriodTap != null 
              ? AppTheme.getRoleColor('faculty').withValues(alpha: 0.05)
              : AppTheme.lightTheme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: onFreePeriodTap != null
                ? AppTheme.getRoleColor('faculty').withValues(alpha: 0.2)
                : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
            style: onFreePeriodTap != null ? BorderStyle.solid : BorderStyle.solid,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(
                  timeSlot,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.4),
                  ),
                ),
                if (onFreePeriodTap != null) ...[
                  Spacer(),
                  CustomIconWidget(
                    iconName: 'add_circle_outline',
                    color: AppTheme.getRoleColor('faculty').withValues(alpha: 0.6),
                    size: 16,
                  ),
                ],
              ],
            ),
            SizedBox(height: 0.5.h),
            Text(
              onFreePeriodTap != null ? 'Tap to schedule' : 'Free Period',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: onFreePeriodTap != null
                    ? AppTheme.getRoleColor('faculty').withValues(alpha: 0.7)
                    : AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.3),
                fontStyle: FontStyle.italic,
                fontWeight: onFreePeriodTap != null ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
